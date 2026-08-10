import 'package:flutter_test/flutter_test.dart';
import 'package:mindly/features/ai_settings/domain/provider_configuration.dart';

void main() {
  test('provider configurations serialize only non-secret metadata', () {
    const configurations = <ProviderConfiguration>[
      ProviderConfiguration.openAi(defaultModel: 'openai-model'),
      ProviderConfiguration.anthropic(defaultModel: 'anthropic-model'),
      ProviderConfiguration.compatible(
        baseUrl: 'https://example.invalid/v1',
        defaultModel: 'compatible-model',
      ),
    ];

    for (final configuration in configurations) {
      final encoded = configuration.toJson();
      expect(encoded['id'], configuration.id);
      expect(encoded['kind'], configuration.kind.name);
      expect(encoded.containsKey('apiKey'), isFalse);
      expect(encoded.containsKey('key'), isFalse);
      expect(encoded.containsKey('secret'), isFalse);
      expect(configuration.toString(), isNot(contains('fake-secret')));
    }
  });
}
