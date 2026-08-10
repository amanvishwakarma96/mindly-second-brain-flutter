import 'package:flutter_test/flutter_test.dart';
import 'package:mindly/features/ai_settings/application/provider_key_service.dart';
import 'package:mindly/features/ai_settings/data/provider_key_repository.dart';

import '../../helpers/in_memory_secret_store.dart';

void main() {
  group('ProviderKeyService', () {
    test('saves, reads, rotates, and removes a native provider key', () async {
      final store = InMemorySecretStore();
      final service = ProviderKeyService(
        repository: ProviderKeyRepository(store),
        isWeb: false,
      );

      await service.saveKey('openai', '  fake-key-one  ');
      expect(await service.readKey('openai'), 'fake-key-one');
      expect(await service.hasKey('openai'), isTrue);

      await service.rotateKey('openai', 'fake-key-two');
      expect(await service.readKey('openai'), 'fake-key-two');
      expect(store.values.values, isNot(contains('fake-key-one')));

      await service.removeKey('openai');
      expect(await service.readKey('openai'), isNull);
      expect(await service.hasKey('openai'), isFalse);
    });

    test('web save is blocked until browser risk is acknowledged', () async {
      final store = InMemorySecretStore();
      final service = ProviderKeyService(
        repository: ProviderKeyRepository(store),
        isWeb: true,
      );

      await expectLater(
        service.saveKey('anthropic', 'fake-web-key'),
        throwsA(isA<WebKeyConsentRequiredException>()),
      );
      expect(store.values, isEmpty);

      await service.saveKey('anthropic', 'fake-web-key', webRiskAccepted: true);
      expect(await service.readKey('anthropic'), 'fake-web-key');
    });

    test('credential-related errors and object strings do not expose keys', () {
      const exception = WebKeyConsentRequiredException();
      expect(exception.toString(), isNot(contains('fake-secret')));
      expect(exception.toString(), isNot(contains('sk-test')));
    });
  });
}
