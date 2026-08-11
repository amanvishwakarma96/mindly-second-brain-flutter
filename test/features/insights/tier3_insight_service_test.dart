import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindly/core/database/mindly_database.dart';
import 'package:mindly/features/ai_settings/application/cost_estimator.dart';
import 'package:mindly/features/ai_settings/application/provider_key_service.dart';
import 'package:mindly/features/ai_settings/application/spend_guard.dart';
import 'package:mindly/features/ai_settings/data/provider_key_repository.dart';
import 'package:mindly/features/ai_settings/data/secure_spend_store.dart';
import 'package:mindly/features/ai_settings/domain/cost_models.dart';
import 'package:mindly/features/insights/application/tier3_insight_service.dart';
import 'package:mindly/features/insights/data/insight_preference_store.dart';
import 'package:mindly/features/insights/data/tier3_context_repository.dart';
import 'package:mindly/features/insights/data/tier3_insight_store.dart';
import 'package:mindly/features/insights/data/tier3_insight_transport.dart';
import 'package:mindly/features/insights/domain/insight_models.dart';
import 'package:mindly/features/memory/data/memory_browser_repository.dart';
import 'package:mindly/features/memory/data/memory_repository.dart';

import '../../helpers/in_memory_secret_store.dart';

void main() {
  final now = DateTime.utc(2026, 8, 11, 12);
  late MindlyDatabase database;
  late MemoryRepository memoryRepository;
  late InMemorySecretStore secrets;
  late ProviderKeyService keyService;
  late SecureSpendStore spendStore;
  late SecureInsightPreferenceStore preferences;
  late SecureTier3InsightStore tier3Store;
  late _FakeTier3Transport transport;
  late Tier3InsightService service;

  setUp(() {
    database = MindlyDatabase(NativeDatabase.memory());
    memoryRepository = MemoryRepository(database);
    secrets = InMemorySecretStore();
    keyService = ProviderKeyService(
      repository: ProviderKeyRepository(secrets),
      isWeb: false,
    );
    spendStore = SecureSpendStore(secrets);
    preferences = SecureInsightPreferenceStore(secrets);
    tier3Store = SecureTier3InsightStore(secrets);
    transport = _FakeTier3Transport();
    final browserRepository = MemoryBrowserRepository(database);
    service = Tier3InsightService(
      contextRepository: Tier3ContextRepository(browserRepository),
      insightStore: tier3Store,
      preferenceStore: preferences,
      keyService: keyService,
      capsRepository: spendStore,
      spendLedger: spendStore,
      spendGuard: SpendGuard(spendStore),
      costEstimator: const CostEstimator(),
      transport: transport,
      clock: () => now,
    );
  });

  tearDown(() => database.close());

  test('insufficient evidence never dispatches a provider request', () async {
    await memoryRepository.saveCapture(
      id: 'c1',
      mode: 'text',
      context: 'work',
      summary: 'One isolated memory',
      createdAt: now,
    );

    expect(await service.estimate(Tier3ProviderProfile.openAiDefault), isNull);
    final outcome = await service.generate(Tier3ProviderProfile.openAiDefault);

    expect(outcome.kind, Tier3GenerationOutcomeKind.insufficientEvidence);
    expect(transport.calls, 0);
    expect(await tier3Store.load(), isEmpty);
  });

  test('missing key blocks before provider dispatch', () async {
    await _seedTwoCaptures(memoryRepository, now);

    final outcome = await service.generate(Tier3ProviderProfile.openAiDefault);

    expect(outcome.kind, Tier3GenerationOutcomeKind.missingKey);
    expect(outcome.estimate, isNotNull);
    expect(transport.calls, 0);
  });

  test('spend cap blocks before provider dispatch', () async {
    await _seedTwoCaptures(memoryRepository, now);
    await keyService.saveKey('openai', 'test-key');
    await spendStore.saveCaps(const SpendCaps(dailyUsd: 0.000001));

    final outcome = await service.generate(Tier3ProviderProfile.openAiDefault);

    expect(outcome.kind, Tier3GenerationOutcomeKind.spendBlocked);
    expect(outcome.spendBlockReason, SpendBlockReason.dailyCap);
    expect(transport.calls, 0);
  });

  test('valid provider output persists grounded recommendation and warning', () async {
    await _seedTwoCaptures(memoryRepository, now);
    await keyService.saveKey('openai', 'test-key');
    transport.response = const Tier3ProviderResponse(
      outputText: '''
{"insights":[
  {"kind":"warning","title":"A deadline may be getting close","body":"Review the launch follow-up before it slips further.","sourceKeys":["capture:c1","capture:c2"]},
  {"kind":"recommendation","title":"Bundle the launch notes","body":"Consider turning these related notes into one short action list.","sourceKeys":["capture:c1","capture:c2"]}
]}
''',
      inputTokens: 220,
      outputTokens: 90,
    );

    final outcome = await service.generate(Tier3ProviderProfile.openAiDefault);
    final persisted = await service.load();

    expect(outcome.kind, Tier3GenerationOutcomeKind.generated);
    expect(outcome.insights, hasLength(2));
    expect(transport.calls, 1);
    expect(transport.lastContext?.allowedSourceKeys, containsAll(['capture:c1', 'capture:c2']));
    expect(persisted, hasLength(2));
    expect(persisted.every((item) => item.tier == InsightTier.tier3), isTrue);
    expect(persisted.every((item) => item.sources.length == 2), isTrue);
    expect(persisted.first.kind, InsightKind.aiWarning);
    expect((await spendStore.entriesSince(now.subtract(const Duration(days: 1)))), hasLength(1));
  });

  test('unknown source keys reject the whole provider output', () async {
    await _seedTwoCaptures(memoryRepository, now);
    await keyService.saveKey('openai', 'test-key');
    transport.response = const Tier3ProviderResponse(
      outputText: '''
{"insights":[{"kind":"recommendation","title":"Unsupported","body":"This should be rejected.","sourceKeys":["capture:not-supplied"]}]}
''',
    );

    final outcome = await service.generate(Tier3ProviderProfile.openAiDefault);

    expect(outcome.kind, Tier3GenerationOutcomeKind.invalidOutput);
    expect(transport.calls, 1);
    expect(await tier3Store.load(), isEmpty);
  });

  test('stored Tier 3 cards obey dismiss and independent kind mute preferences', () async {
    await _seedTwoCaptures(memoryRepository, now);
    await tier3Store.save([
      ProactiveInsight(
        fingerprint: 'tier3_rec',
        kind: InsightKind.aiRecommendation,
        tier: InsightTier.tier3,
        severity: InsightSeverity.recommendation,
        title: 'Recommendation',
        body: 'Try one small next step.',
        evidenceAt: now,
        sources: const [
          InsightSourceReference(
            type: MemoryEntityType.capture,
            id: 'c1',
            title: 'Launch plan',
          ),
        ],
      ),
      ProactiveInsight(
        fingerprint: 'tier3_warn',
        kind: InsightKind.aiWarning,
        tier: InsightTier.tier3,
        severity: InsightSeverity.warning,
        title: 'Warning',
        body: 'Review this soon.',
        evidenceAt: now,
        sources: const [
          InsightSourceReference(
            type: MemoryEntityType.capture,
            id: 'c2',
            title: 'Launch follow-up',
          ),
        ],
      ),
    ]);
    await preferences.save(
      const InsightPreferences(
        dismissedFingerprints: {'tier3_warn'},
        mutedKinds: {InsightKind.aiRecommendation},
      ),
    );

    expect(await service.load(), isEmpty);
    expect(await database.select(database.captures).get(), hasLength(2));
  });
}

Future<void> _seedTwoCaptures(MemoryRepository repository, DateTime now) async {
  await repository.saveCapture(
    id: 'c1',
    mode: 'text',
    context: 'work',
    summary: 'Launch plan',
    rawText: 'Prepare the launch plan and confirm the review date.',
    createdAt: now.subtract(const Duration(days: 2)),
  );
  await repository.saveCapture(
    id: 'c2',
    mode: 'text',
    context: 'work',
    summary: 'Launch follow-up',
    rawText: 'The launch review still needs a final owner and checklist.',
    createdAt: now.subtract(const Duration(days: 1)),
  );
  await repository.link(
    id: 'launch-related',
    fromType: 'capture',
    fromId: 'c1',
    relationType: 'related_to',
    toType: 'capture',
    toId: 'c2',
  );
}

class _FakeTier3Transport implements Tier3InsightTransport {
  int calls = 0;
  Tier3GenerationContext? lastContext;
  Object? error;
  Tier3ProviderResponse response = const Tier3ProviderResponse(
    outputText: '{"insights":[]}',
  );

  @override
  Future<Tier3ProviderResponse> generate({
    required Tier3ProviderProfile profile,
    required String apiKey,
    required Tier3GenerationContext context,
  }) async {
    calls += 1;
    lastContext = context;
    if (error != null) throw error!;
    return response;
  }
}
