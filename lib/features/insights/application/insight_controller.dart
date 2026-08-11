import 'package:mindly/core/database/mindly_database.dart';
import 'package:mindly/core/security/flutter_secure_secret_store.dart';
import 'package:mindly/features/insights/application/proactive_insight_service.dart';
import 'package:mindly/features/insights/data/insight_evidence_repository.dart';
import 'package:mindly/features/insights/data/insight_preference_store.dart';
import 'package:mindly/features/insights/domain/insight_models.dart';
import 'package:mindly/features/memory/data/memory_browser_repository.dart';
import 'package:mindly/features/memory/domain/memory_models.dart';

abstract class InsightController {
  factory InsightController.production() {
    final database = MindlyDatabase.defaults();
    final browserRepository = MemoryBrowserRepository(database);
    return DefaultInsightController(
      ProactiveInsightService(
        evidenceRepository: InsightEvidenceRepository(
          database: database,
          browserRepository: browserRepository,
        ),
        preferenceStore: SecureInsightPreferenceStore(
          FlutterSecureSecretStore(),
        ),
      ),
    );
  }

  Future<List<ProactiveInsight>> load();

  Future<List<ProactiveInsight>> dismiss(String fingerprint);

  Future<List<ProactiveInsight>> setMuted(InsightKind kind, bool muted);

  Future<Set<InsightKind>> mutedKinds();

  Future<MemoryDetail?> sourceDetail(InsightSourceReference source);
}

class DefaultInsightController implements InsightController {
  const DefaultInsightController(this._service);

  final ProactiveInsightService _service;

  @override
  Future<List<ProactiveInsight>> load() => _service.load();

  @override
  Future<List<ProactiveInsight>> dismiss(String fingerprint) async {
    await _service.dismiss(fingerprint);
    return _service.load();
  }

  @override
  Future<List<ProactiveInsight>> setMuted(InsightKind kind, bool muted) async {
    await _service.setMuted(kind, muted);
    return _service.load();
  }

  @override
  Future<Set<InsightKind>> mutedKinds() => _service.mutedKinds();

  @override
  Future<MemoryDetail?> sourceDetail(InsightSourceReference source) {
    return _service.sourceDetail(source);
  }
}
