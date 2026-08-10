import 'package:mindly/features/ai_settings/data/provider_key_repository.dart';

class WebKeyConsentRequiredException implements Exception {
  const WebKeyConsentRequiredException();

  @override
  String toString() => 'Web API-key risk acknowledgement is required.';
}

class ProviderKeyService {
  factory ProviderKeyService({
    required ProviderKeyRepository repository,
    required bool isWeb,
  }) {
    return ProviderKeyService._(repository, isWeb);
  }

  ProviderKeyService._(this._repository, this._isWeb);

  final ProviderKeyRepository _repository;
  final bool _isWeb;

  Future<void> saveKey(
    String providerId,
    String apiKey, {
    bool webRiskAccepted = false,
  }) {
    _requireWebConsent(webRiskAccepted);
    return _repository.save(providerId, apiKey);
  }

  Future<void> rotateKey(
    String providerId,
    String apiKey, {
    bool webRiskAccepted = false,
  }) {
    _requireWebConsent(webRiskAccepted);
    return _repository.save(providerId, apiKey);
  }

  Future<void> removeKey(String providerId) {
    return _repository.remove(providerId);
  }

  Future<String?> readKey(String providerId) {
    return _repository.read(providerId);
  }

  Future<bool> hasKey(String providerId) {
    return _repository.hasKey(providerId);
  }

  void _requireWebConsent(bool accepted) {
    if (_isWeb && !accepted) {
      throw const WebKeyConsentRequiredException();
    }
  }
}
