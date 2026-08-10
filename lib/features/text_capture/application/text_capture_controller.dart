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
import 'package:mindly/features/memory/data/memory_repository.dart';
import 'package:mindly/features/text_capture/application/text_capture_service.dart';
import 'package:mindly/features/text_capture/data/http_ai_provider_transport.dart';
import 'package:mindly/features/text_capture/domain/memory_extraction.dart';
import 'package:mindly/features/text_capture/domain/text_capture_models.dart';

class TextCaptureController {
  const TextCaptureController(this._service);

  factory TextCaptureController.production() {
    final store = FlutterSecureSecretStore();
    final spendStore = SecureSpendStore(store);
    final database = MindlyDatabase.defaults();
    final keyService = ProviderKeyService(
      repository: ProviderKeyRepository(store),
      isWeb: kIsWeb,
    );
    final service = TextCaptureService(
      memoryRepository: MemoryRepository(database),
      keyService: keyService,
      capsRepository: spendStore,
      spendLedger: spendStore,
      spendGuard: SpendGuard(spendStore),
      costEstimator: const CostEstimator(),
      transport: HttpAiProviderTransport(http.Client()),
    );
    return TextCaptureController(service);
  }

  final TextCaptureService _service;

  CostEstimate estimate({
    required String text,
    required ExtractionProviderProfile profile,
  }) {
    return _service.estimate(text: text, profile: profile);
  }

  Future<TextCaptureOutcome> capture({
    required String text,
    required ExtractionProviderProfile profile,
  }) {
    return _service.captureAndExtract(text: text, profile: profile);
  }

  Future<void> classify({
    required String captureId,
    required ExtractionContext context,
  }) {
    return _service.classifyCapture(captureId: captureId, context: context);
  }
}
