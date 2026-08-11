import 'package:flutter_test/flutter_test.dart';
import 'package:mindly/features/ai_settings/application/cost_estimator.dart';
import 'package:mindly/features/ai_settings/application/provider_key_service.dart';
import 'package:mindly/features/ai_settings/application/spend_guard.dart';
import 'package:mindly/features/ai_settings/data/provider_key_repository.dart';
import 'package:mindly/features/ai_settings/data/secure_spend_store.dart';
import 'package:mindly/features/ai_settings/domain/cost_models.dart';
import 'package:mindly/features/insights/application/tier3_evidence_builder.dart';
import 'package:mindly/features/insights/application/tier3_insight_service.dart';
import 'package:mindly/features/insights/data/insight_preference_store.dart';
import 'package:mindly/features/insights/data/tier3_insight_transport.dart';
import 'package:mindly/features/insights/domain/insight_models.dart';
import 'package:mindly/features/insights/domain/tier3_models.dart';
import 'package:mindly/features/memory/domain/memory_models.dart';
import 'package:mindly/features/text_capture/domain/text_capture_models.dart';
import '../../helpers/in_memory_secret_store.dart';

void main() {
  final now = DateTime.utc(2026, 8, 11, 12);
  const source = InsightSourceReference(
    type: MemoryEntityType.capture,
    id: 'c1',
    title: 'Launch plan',
  );
  final localInsight = ProactiveInsight(
    fingerprint: 'local-1',
    kind: InsightKind.relatedMemory,
    tier: InsightTier.tier1,
    severity: InsightSeverity.info,
    title: 'Connected launch memory',
    body: 'The launch memories are related.',
    evidenceAt: now,
    sources: const [source],
  );

  Tier3EvidenceBuilder evidenceBuilder() => Tier3EvidenceBuilder(
    insightLoader: () async => [localInsight],
    sourceDetailLoader: (_) async => const MemoryDetail(
      item: MemoryListItem(
        type: MemoryEntityType.capture,
        id: 'c1',
        title: 'Launch plan',
      ),
      rawText:
          'Launch is Friday. Review the rollout checklist before Thursday.',
    ),
  );

  test(
    'preview is local-only and reports missing key before dispatch',
    () async {
      final store = InMemorySecretStore();
      final spendStore = SecureSpendStore(store);
      final transport = _FakeTier3Transport();
      final service = _service(
        store: store,
        spendStore: spendStore,
        transport: transport,
        evidenceBuilder: evidenceBuilder(),
        now: now,
      );

      final preview = await service.preview(
        ExtractionProviderProfile.openAiDefault,
      );

      expect(preview.status, Tier3PreviewStatus.missingKey);
      expect(preview.sourceCount, 1);
      expect(preview.estimate, isNotNull);
      expect(transport.calls, 0);
    },
  );

  test('spend cap denial blocks before provider dispatch', () async {
    final store = InMemorySecretStore();
    final spendStore = SecureSpendStore(store);
    final keyService = ProviderKeyService(
      repository: ProviderKeyRepository(store),
      isWeb: false,
    );
    await keyService.saveKey('openai', 'test-key');
    await spendStore.save(const SpendCaps(dailyUsd: 0.000001));
    final transport = _FakeTier3Transport();
    final service = _service(
      store: store,
      spendStore: spendStore,
      transport: transport,
      evidenceBuilder: evidenceBuilder(),
      now: now,
    );

    final outcome = await service.generate(
      ExtractionProviderProfile.openAiDefault,
    );

    expect(outcome.kind, Tier3GenerationOutcomeKind.spendBlocked);
    expect(transport.calls, 0);
    expect(
      await spendStore.entriesSince(now.subtract(const Duration(days: 1))),
      isEmpty,
    );
  });

  test(
    'valid provider response surfaces only locally rebuilt source refs',
    () async {
      final store = InMemorySecretStore();
      final spendStore = SecureSpendStore(store);
      final keyService = ProviderKeyService(
        repository: ProviderKeyRepository(store),
        isWeb: false,
      );
      await keyService.saveKey('openai', 'test-key');
      final transport = _FakeTier3Transport(
        response: const Tier3ProviderResponse(
          outputText:
              '{"title":"Review rollout","body":"Review the rollout checklist before launch.","explanation":"The local launch source says the checklist should be reviewed before Thursday.","severity":"recommendation","source_ids":["capture:c1"]}',
          inputTokens: 100,
          outputTokens: 40,
        ),
      );
      final service = _service(
        store: store,
        spendStore: spendStore,
        transport: transport,
        evidenceBuilder: evidenceBuilder(),
        now: now,
      );

      final outcome = await service.generate(
        ExtractionProviderProfile.openAiDefault,
      );

      expect(outcome.kind, Tier3GenerationOutcomeKind.generated);
      expect(outcome.insight?.tier, InsightTier.tier3);
      expect(outcome.insight?.kind, InsightKind.aiSynthesis);
      expect(outcome.insight?.sources.single.id, 'c1');
      expect(outcome.insight?.sources.single.title, 'Launch plan');
      expect(outcome.insight?.explanation, contains('local launch source'));
      expect(transport.calls, 1);
      expect(
        await spendStore.entriesSince(now.subtract(const Duration(days: 1))),
        hasLength(1),
      );
    },
  );

  test('unknown provider source ID rejects the generated insight', () async {
    final store = InMemorySecretStore();
    final spendStore = SecureSpendStore(store);
    final keyService = ProviderKeyService(
      repository: ProviderKeyRepository(store),
      isWeb: false,
    );
    await keyService.saveKey('openai', 'test-key');
    final transport = _FakeTier3Transport(
      response: const Tier3ProviderResponse(
        outputText:
            '{"title":"Invented source","body":"Do something.","explanation":"Unsupported citation.","severity":"warning","source_ids":["capture:not-supplied"]}',
      ),
    );
    final service = _service(
      store: store,
      spendStore: spendStore,
      transport: transport,
      evidenceBuilder: evidenceBuilder(),
      now: now,
    );

    final outcome = await service.generate(
      ExtractionProviderProfile.openAiDefault,
    );

    expect(outcome.kind, Tier3GenerationOutcomeKind.invalidResponse);
    expect(outcome.insight, isNull);
  });

  test('provider failure records no spend and exposes no raw key', () async {
    final store = InMemorySecretStore();
    final spendStore = SecureSpendStore(store);
    final keyService = ProviderKeyService(
      repository: ProviderKeyRepository(store),
      isWeb: false,
    );
    const rawKey = 'super-secret-provider-key';
    await keyService.saveKey('openai', rawKey);
    final transport = _FakeTier3Transport(error: StateError('network failed'));
    final service = _service(
      store: store,
      spendStore: spendStore,
      transport: transport,
      evidenceBuilder: evidenceBuilder(),
      now: now,
    );

    final outcome = await service.generate(
      ExtractionProviderProfile.openAiDefault,
    );

    expect(outcome.kind, Tier3GenerationOutcomeKind.providerFailure);
    expect(outcome.toString(), isNot(contains(rawKey)));
    expect(
      await spendStore.entriesSince(now.subtract(const Duration(days: 1))),
      isEmpty,
    );
  });

  test('muted AI synthesis blocks before dispatch', () async {
    final store = InMemorySecretStore();
    final spendStore = SecureSpendStore(store);
    final keyService = ProviderKeyService(
      repository: ProviderKeyRepository(store),
      isWeb: false,
    );
    await keyService.saveKey('openai', 'test-key');
    final preferences = SecureInsightPreferenceStore(store);
    await preferences.save(
      const InsightPreferences(mutedKinds: {InsightKind.aiSynthesis}),
    );
    final transport = _FakeTier3Transport();
    final service = _service(
      store: store,
      spendStore: spendStore,
      transport: transport,
      evidenceBuilder: evidenceBuilder(),
      now: now,
    );

    final outcome = await service.generate(
      ExtractionProviderProfile.openAiDefault,
    );

    expect(outcome.kind, Tier3GenerationOutcomeKind.muted);
    expect(transport.calls, 0);
  });
}

Tier3InsightService _service({
  required InMemorySecretStore store,
  required SecureSpendStore spendStore,
  required _FakeTier3Transport transport,
  required Tier3EvidenceBuilder evidenceBuilder,
  required DateTime now,
}) {
  return Tier3InsightService(
    evidenceBuilder: evidenceBuilder,
    keyService: ProviderKeyService(
      repository: ProviderKeyRepository(store),
      isWeb: false,
    ),
    capsRepository: spendStore,
    spendLedger: spendStore,
    spendGuard: SpendGuard(spendStore),
    costEstimator: const CostEstimator(),
    transport: transport,
    preferenceStore: SecureInsightPreferenceStore(store),
    clock: () => now,
  );
}

class _FakeTier3Transport implements Tier3InsightTransport {
  _FakeTier3Transport({this.response, this.error});

  final Tier3ProviderResponse? response;
  final Object? error;
  int calls = 0;

  @override
  Future<Tier3ProviderResponse> synthesize({
    required ExtractionProviderProfile profile,
    required String apiKey,
    required Tier3EvidenceBundle evidence,
  }) async {
    calls += 1;
    if (error != null) throw error!;
    return response ??
        const Tier3ProviderResponse(
          outputText:
              '{"title":"Insight","body":"Body","explanation":"Explanation","severity":"info","source_ids":["capture:c1"]}',
        );
  }
}
