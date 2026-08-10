import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindly/core/database/mindly_database.dart';
import 'package:mindly/features/ai_settings/application/cost_estimator.dart';
import 'package:mindly/features/ai_settings/application/provider_key_service.dart';
import 'package:mindly/features/ai_settings/application/spend_guard.dart';
import 'package:mindly/features/ai_settings/data/provider_key_repository.dart';
import 'package:mindly/features/ai_settings/data/secure_spend_store.dart';
import 'package:mindly/features/ai_settings/domain/cost_models.dart';
import 'package:mindly/features/memory/data/memory_repository.dart';
import 'package:mindly/features/text_capture/application/text_capture_service.dart';
import 'package:mindly/features/text_capture/data/ai_provider_transport.dart';
import 'package:mindly/features/text_capture/domain/memory_extraction.dart';
import 'package:mindly/features/text_capture/domain/text_capture_models.dart';

import '../../helpers/in_memory_secret_store.dart';

void main() {
  late MindlyDatabase database;
  late MemoryRepository memoryRepository;
  late InMemorySecretStore secretStore;
  late ProviderKeyService keyService;
  late SecureSpendStore spendStore;
  late FakeAiProviderTransport transport;
  late TextCaptureService service;

  final fixedNow = DateTime.utc(2026, 8, 10, 12);

  setUp(() {
    database = MindlyDatabase(NativeDatabase.memory());
    memoryRepository = MemoryRepository(database);
    secretStore = InMemorySecretStore();
    keyService = ProviderKeyService(
      repository: ProviderKeyRepository(secretStore),
      isWeb: false,
    );
    spendStore = SecureSpendStore(secretStore);
    transport = FakeAiProviderTransport();
    service = TextCaptureService(
      memoryRepository: memoryRepository,
      keyService: keyService,
      capsRepository: spendStore,
      spendLedger: spendStore,
      spendGuard: SpendGuard(spendStore),
      costEstimator: const CostEstimator(),
      transport: transport,
      clock: () => fixedNow,
      idFactory: (_) => 'capture-1',
    );
  });

  tearDown(() => database.close());

  test('empty text is rejected before persistence or provider dispatch', () async {
    await expectLater(
      service.captureAndExtract(
        text: '   ',
        profile: ExtractionProviderProfile.openAiDefault,
      ),
      throwsArgumentError,
    );
    expect(await database.select(database.captures).get(), isEmpty);
    expect(transport.calls, 0);
  });

  test('capture is saved locally before provider dispatch', () async {
    await keyService.saveKey('openai', 'test-key');
    transport.onExtract = ({
      required profile,
      required apiKey,
      required captureId,
      required text,
    }) async {
      final captures = await database.select(database.captures).get();
      expect(captures, hasLength(1));
      expect(captures.single.id, 'capture-1');
      expect(captures.single.rawText, 'Discuss launch with Priya.');
      return _validResponse(captureId);
    };

    final outcome = await service.captureAndExtract(
      text: ' Discuss launch with Priya. ',
      profile: ExtractionProviderProfile.openAiDefault,
    );

    expect(outcome.kind, TextCaptureOutcomeKind.extracted);
    expect(transport.calls, 1);
  });

  test('missing provider key leaves capture saved and skips transport', () async {
    final outcome = await service.captureAndExtract(
      text: 'Remember this even without an API key.',
      profile: ExtractionProviderProfile.openAiDefault,
    );

    expect(outcome.kind, TextCaptureOutcomeKind.savedMissingKey);
    expect(transport.calls, 0);
    final captures = await database.select(database.captures).get();
    expect(captures.single.rawText, 'Remember this even without an API key.');
  });

  test('spend-cap preflight blocks transport but keeps the local capture', () async {
    await keyService.saveKey('openai', 'test-key');
    await spendStore.save(const SpendCaps(dailyUsd: 0.000001));

    final outcome = await service.captureAndExtract(
      text: 'A note that should be saved before cost controls are evaluated.',
      profile: ExtractionProviderProfile.openAiDefault,
    );

    expect(outcome.kind, TextCaptureOutcomeKind.savedSpendBlocked);
    expect(outcome.spendBlockReason, SpendBlockReason.dailyCap);
    expect(transport.calls, 0);
    expect(await database.select(database.captures).get(), hasLength(1));
  });

  test('provider failure preserves local source text for retry', () async {
    await keyService.saveKey('openai', 'test-key');
    transport.onExtract = ({
      required profile,
      required apiKey,
      required captureId,
      required text,
    }) async {
      throw const AiProviderRequestException(
        providerId: 'openai',
        statusCode: 503,
      );
    };

    final outcome = await service.captureAndExtract(
      text: 'Provider outages must never eat this note.',
      profile: ExtractionProviderProfile.openAiDefault,
    );

    expect(outcome.kind, TextCaptureOutcomeKind.savedProviderFailure);
    expect(transport.calls, 1);
    final capture = (await database.select(database.captures).get()).single;
    expect(capture.rawText, 'Provider outages must never eat this note.');
    expect(capture.summary, isNull);
  });

  test('invalid extraction is controlled and raw provider body is not persisted', () async {
    await keyService.saveKey('openai', 'test-key');
    transport.onExtract = ({
      required profile,
      required apiKey,
      required captureId,
      required text,
    }) async {
      return const AiProviderResponse(
        outputText: '{"capture_id":"wrong","summary":"bad"}',
        inputTokens: 10,
        outputTokens: 5,
      );
    };

    final outcome = await service.captureAndExtract(
      text: 'Keep the source; reject malformed AI memory.',
      profile: ExtractionProviderProfile.openAiDefault,
    );

    expect(outcome.kind, TextCaptureOutcomeKind.savedInvalidExtraction);
    final capture = (await database.select(database.captures).get()).single;
    expect(capture.rawText, 'Keep the source; reject malformed AI memory.');
    expect(capture.summary, isNull);
    expect(await memoryRepository.keywordSearch('wrong'), isEmpty);
  });

  test('successful extraction persists structured memory and source links', () async {
    await keyService.saveKey('openai', 'test-key');
    transport.onExtract = ({
      required profile,
      required apiKey,
      required captureId,
      required text,
    }) async => _validResponse(captureId);

    final outcome = await service.captureAndExtract(
      text: 'Discuss launch timing with Priya and send the rollout plan.',
      profile: ExtractionProviderProfile.openAiDefault,
    );

    expect(outcome.kind, TextCaptureOutcomeKind.extracted);
    expect(outcome.extraction?.context, ExtractionContext.work);

    final capture = (await database.select(database.captures).get()).single;
    expect(capture.summary, 'Discussed launch timing with Priya.');
    expect(capture.context, 'work');
    expect(await database.select(database.people).get(), hasLength(1));
    expect(await database.select(database.topics).get(), hasLength(1));
    expect(await database.select(database.commitments).get(), hasLength(1));
    expect(
      await database.select(database.memoryRelationships).get(),
      hasLength(3),
    );
    expect(await memoryRepository.keywordSearch('rollout'), isNotEmpty);
    expect(await spendStore.entriesSince(fixedNow), hasLength(1));
  });

  test('ambiguous extraction can be explicitly classified later', () async {
    await keyService.saveKey('openai', 'test-key');
    transport.onExtract = ({
      required profile,
      required apiKey,
      required captureId,
      required text,
    }) async {
      return AiProviderResponse(
        outputText: jsonEncode({
          'capture_id': captureId,
          'summary': 'Call Alex tomorrow.',
          'context': 'ambiguous',
          'people': ['Alex'],
          'topics': ['Follow-up'],
          'commitments': ['Call Alex tomorrow'],
          'tone': null,
        }),
        inputTokens: 20,
        outputTokens: 10,
      );
    };

    final outcome = await service.captureAndExtract(
      text: 'Call Alex tomorrow.',
      profile: ExtractionProviderProfile.openAiDefault,
    );
    expect(outcome.extraction?.context, ExtractionContext.ambiguous);

    await service.classifyCapture(
      captureId: outcome.captureId,
      context: ExtractionContext.personal,
    );
    final capture = (await database.select(database.captures).get()).single;
    expect(capture.context, 'personal');
  });

  test('cost estimate is available before any provider request', () {
    final estimate = service.estimate(
      text: 'A small note.',
      profile: ExtractionProviderProfile.openAiDefault,
    );

    expect(estimate.estimatedUsd, greaterThan(0));
    expect(estimate.providerId, 'openai');
    expect(transport.calls, 0);
  });
}

AiProviderResponse _validResponse(String captureId) {
  return AiProviderResponse(
    outputText: jsonEncode({
      'capture_id': captureId,
      'summary': 'Discussed launch timing with Priya.',
      'context': 'work',
      'people': ['Priya'],
      'topics': ['Launch'],
      'commitments': ['Send rollout plan'],
      'tone': 'focused',
    }),
    inputTokens: 100,
    outputTokens: 30,
  );
}

typedef ExtractCallback =
    Future<AiProviderResponse> Function({
      required ExtractionProviderProfile profile,
      required String apiKey,
      required String captureId,
      required String text,
    });

class FakeAiProviderTransport implements AiProviderTransport {
  int calls = 0;
  ExtractCallback? onExtract;

  @override
  Future<AiProviderResponse> extract({
    required ExtractionProviderProfile profile,
    required String apiKey,
    required String captureId,
    required String text,
  }) async {
    calls += 1;
    final callback = onExtract;
    if (callback != null) {
      return callback(
        profile: profile,
        apiKey: apiKey,
        captureId: captureId,
        text: text,
      );
    }
    return _validResponse(captureId);
  }
}
