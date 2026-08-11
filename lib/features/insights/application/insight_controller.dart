import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mindly/core/database/mindly_database.dart';
import 'package:mindly/core/security/flutter_secure_secret_store.dart';
import 'package:mindly/features/ai_settings/application/cost_estimator.dart';
import 'package:mindly/features/ai_settings/application/provider_key_service.dart';
import 'package:mindly/features/ai_settings/application/spend_guard.dart';
import 'package:mindly/features/ai_settings/data/provider_key_repository.dart';
import 'package:mindly/features/ai_settings/data/secure_spend_store.dart';
import 'package:mindly/features/ai_settings/domain/cost_models.dart';
import 'package:mindly/features/insights/application/proactive_insight_service.dart';
import 'package:mindly/features/insights/application/tier3_insight_service.dart';
import 'package:mindly/features/insights/data/http_tier3_insight_transport.dart';
import 'package:mindly/features/insights/data/insight_evidence_repository.dart';
import 'package:mindly/features/insights/data/insight_preference_store.dart';
import 'package:mindly/features/insights/data/tier3_context_repository.dart';
import 'package:mindly/features/insights/data/tier3_insight_store.dart';
import 'package:mindly/features/insights/domain/insight_models.dart';
import 'package:mindly/features/memory/data/memory_browser_repository.dart';
import 'package:mindly/features/memory/domain/memory_models.dart';

abstract class InsightController {
  factory InsightController.production() {
    final database = MindlyDatabase.defaults();
    final browserRepository = MemoryBrowserRepository(database);
    final secureStore = FlutterSecureSecretStore();
    final preferenceStore = SecureInsightPreferenceStore(secureStore);
    final spendStore = SecureSpendStore(secureStore);
    final keyService = ProviderKeyService(
      repository: ProviderKeyRepository(secureStore),
      isWeb: kIsWeb,
    );

    final proactiveService = ProactiveInsightService(
      evidenceRepository: InsightEvidenceRepository(
        database: database,
        browserRepository: browserRepository,
      ),
      preferenceStore: preferenceStore,
    );
    final tier3Service = Tier3InsightService(
      contextRepository: Tier3ContextRepository(browserRepository),
      insightStore: SecureTier3InsightStore(secureStore),
      preferenceStore: preferenceStore,
      keyService: keyService,
      capsRepository: spendStore,
      spendLedger: spendStore,
      spendGuard: SpendGuard(spendStore),
      costEstimator: const CostEstimator(),
      transport: HttpTier3InsightTransport(http.Client()),
    );
    return DefaultInsightController(proactiveService, tier3Service);
  }

  Future<List<ProactiveInsight>> load();

  Future<List<ProactiveInsight>> dismiss(String fingerprint);

  Future<List<ProactiveInsight>> setMuted(InsightKind kind, bool muted);

  Future<Set<InsightKind>> mutedKinds();

  Future<MemoryDetail?> sourceDetail(InsightSourceReference source);

  Future<CostEstimate?> estimateTier3(Tier3ProviderProfile profile) async => null;

  Future<Tier3GenerationOutcome> generateTier3(
    Tier3ProviderProfile profile,
  ) async {
    throw UnsupportedError('Tier 3 generation is not available on this controller.');
  }
}

class DefaultInsightController implements InsightController {
  const DefaultInsightController(this._service, [this._tier3Service]);

  final ProactiveInsightService _service;
  final Tier3InsightService? _tier3Service;

  @override
  Future<List<ProactiveInsight>> load() async {
    final local = await _service.load();
    final tier3 = await _tier3Service?.load() ?? const <ProactiveInsight>[];
    final combined = <String, ProactiveInsight>{};
    for (final insight in [...local, ...tier3]) {
      final current = combined[insight.fingerprint];
      if (current == null || insight.evidenceAt.isAfter(current.evidenceAt)) {
        combined[insight.fingerprint] = insight;
      }
    }
    final values = combined.values.toList(growable: false);
    values.sort(_compareInsights);
    return values;
  }

  @override
  Future<List<ProactiveInsight>> dismiss(String fingerprint) async {
    await _service.dismiss(fingerprint);
    return load();
  }

  @override
  Future<List<ProactiveInsight>> setMuted(InsightKind kind, bool muted) async {
    await _service.setMuted(kind, muted);
    return load();
  }

  @override
  Future<Set<InsightKind>> mutedKinds() => _service.mutedKinds();

  @override
  Future<MemoryDetail?> sourceDetail(InsightSourceReference source) {
    return _service.sourceDetail(source);
  }

  @override
  Future<CostEstimate?> estimateTier3(Tier3ProviderProfile profile) {
    final tier3Service = _tier3Service;
    if (tier3Service == null) return Future<CostEstimate?>.value();
    return tier3Service.estimate(profile);
  }

  @override
  Future<Tier3GenerationOutcome> generateTier3(
    Tier3ProviderProfile profile,
  ) {
    final tier3Service = _tier3Service;
    if (tier3Service == null) {
      return Future<Tier3GenerationOutcome>.value(
        const Tier3GenerationOutcome(
          kind: Tier3GenerationOutcomeKind.providerFailure,
          estimate: null,
        ),
      );
    }
    return tier3Service.generate(profile);
  }

  int _compareInsights(ProactiveInsight left, ProactiveInsight right) {
    final severity = right.severity.priority.compareTo(left.severity.priority);
    if (severity != 0) return severity;
    final evidence = right.evidenceAt.compareTo(left.evidenceAt);
    if (evidence != 0) return evidence;
    return left.fingerprint.compareTo(right.fingerprint);
  }
}
