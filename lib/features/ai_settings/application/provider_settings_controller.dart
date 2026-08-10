import 'package:flutter/foundation.dart';
import 'package:mindly/core/security/flutter_secure_secret_store.dart';
import 'package:mindly/features/ai_settings/application/provider_key_service.dart';
import 'package:mindly/features/ai_settings/data/provider_key_repository.dart';
import 'package:mindly/features/ai_settings/data/secure_spend_store.dart';
import 'package:mindly/features/ai_settings/domain/cost_models.dart';

class ProviderSettingsController {
  ProviderSettingsController({
    required ProviderKeyService keyService,
    required SpendCapsRepository capsRepository,
  }) : _keyService = keyService,
       _capsRepository = capsRepository;

  factory ProviderSettingsController.production() {
    final store = FlutterSecureSecretStore();
    return ProviderSettingsController(
      keyService: ProviderKeyService(
        repository: ProviderKeyRepository(store),
        isWeb: kIsWeb,
      ),
      capsRepository: SecureSpendStore(store),
    );
  }

  final ProviderKeyService _keyService;
  final SpendCapsRepository _capsRepository;

  Future<void> saveKey(
    String providerId,
    String apiKey, {
    bool webRiskAccepted = false,
  }) {
    return _keyService.saveKey(
      providerId,
      apiKey,
      webRiskAccepted: webRiskAccepted,
    );
  }

  Future<void> rotateKey(
    String providerId,
    String apiKey, {
    bool webRiskAccepted = false,
  }) {
    return _keyService.rotateKey(
      providerId,
      apiKey,
      webRiskAccepted: webRiskAccepted,
    );
  }

  Future<void> removeKey(String providerId) {
    return _keyService.removeKey(providerId);
  }

  Future<bool> hasKey(String providerId) {
    return _keyService.hasKey(providerId);
  }

  Future<SpendCaps> loadCaps() {
    return _capsRepository.load();
  }

  Future<void> saveCaps(SpendCaps caps) {
    return _capsRepository.save(caps);
  }
}
