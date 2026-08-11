import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mindly/core/database/mindly_database.dart';
import 'package:mindly/core/security/flutter_secure_secret_store.dart';
import 'package:mindly/features/ai_settings/application/cost_estimator.dart';
import 'package:mindly/features/ai_settings/application/provider_key_service.dart';
import 'package:mindly/features/ai_settings/application/spend_guard.dart';
import 'package:mindly/features/ai_settings/data/provider_key_repository.dart';
import 'package:mindly/features/ai_settings/data/secure_spend_store.dart';
import 'package:mindly/features/insights/application/proactive_insight_service.dart';
import 'package:mindly/features/insights/application/tier3_evidence_builder.dart';
import 'package:mindly/features/insights/application/tier3_insight_service.dart';
import 'package:mindly/features/insights/data/http_tier3_insight_transport.dart';
import 'package:mindly/features/insights/data/insight_evidence_repository.dart';
import 'package:mindly/features/insights/data/insight_preference_store.dart';
import 'package:mindly/features/insights/domain/tier3_models.dart';
import 'package:mindly/features/memory/data/memory_browser_repository.dart';
import 'package:mindly/features/text_capture/domain/text_capture_models.dart';

abstract class Tier3InsightController {
  factory Tier3InsightController.production() {
    final database = MindlyDatabase.defaults();
    final browserRepository = MemoryBrowserRepository(database);
    final secretStore = FlutterSecureSecretStore();
    final preferenceStore = SecureInsightPreferenceStore(secretStore);
    final localService = ProactiveInsightService(
      evidenceRepository: InsightEvidenceRepository(
        database: database,
        browserRepository: browserRepository,
      ),
      preferenceStore: preferenceStore,
    );
    final spendStore = SecureSpendStore(secretStore);
    final service = Tier3InsightService(
      evidenceBuilder: Tier3EvidenceBuilder(
        insightLoader: localService.load,
        sourceDetailLoader: localService.sourceDetail,
      ),
      keyService: ProviderKeyService(
        repository: ProviderKeyRepository(secretStore),
        isWeb: kIsWeb,
      ),
      capsRepository: spendStore,
      spendLedger: spendStore,
      spendGuard: SpendGuard(spendStore),
      costEstimator: const CostEstimator(),
      transport: HttpTier3InsightTransport(http.Client()),
      preferenceStore: preferenceStore,
    );
    return DefaultTier3InsightController(service);
  }

  Future<Tier3GenerationPreview> preview(
    ExtractionProviderProfile profile,
  );

  Future<Tier3GenerationOutcome> generate(
    ExtractionProviderProfile profile,
  );
}

class DefaultTier3InsightController implements Tier3InsightController {
  const DefaultTier3InsightController(this._service);

  final Tier3InsightService _service;

  @override
  Future<Tier3GenerationPreview> preview(ExtractionProviderProfile profile) {
    return _service.preview(profile);
  }

  @override
  Future<Tier3GenerationOutcome> generate(ExtractionProviderProfile profile) {
    return _service.generate(profile);
  }
}
