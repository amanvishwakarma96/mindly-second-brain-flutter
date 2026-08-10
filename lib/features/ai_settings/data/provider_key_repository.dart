import 'package:mindly/core/security/secret_store.dart';

class ProviderKeyRepository {
  ProviderKeyRepository(this._store);

  static const _prefix = 'mindly.provider-key.v1.';

  final SecretStore _store;

  Future<void> save(String providerId, String apiKey) {
    final normalized = apiKey.trim();
    if (normalized.isEmpty) {
      throw ArgumentError('API key cannot be empty.');
    }
    return _store.write(key: '$_prefix$providerId', value: normalized);
  }

  Future<String?> read(String providerId) {
    return _store.read(key: '$_prefix$providerId');
  }

  Future<void> remove(String providerId) {
    return _store.delete(key: '$_prefix$providerId');
  }

  Future<bool> hasKey(String providerId) async {
    final value = await read(providerId);
    return value != null && value.isNotEmpty;
  }
}
