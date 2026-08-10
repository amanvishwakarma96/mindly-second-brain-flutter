import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mindly/features/text_capture/data/http_ai_provider_transport.dart';
import 'package:mindly/features/text_capture/domain/text_capture_models.dart';

void main() {
  const extraction = {
    'capture_id': 'capture-1',
    'summary': 'Discussed launch timing with Priya.',
    'context': 'work',
    'people': ['Priya'],
    'topics': ['Launch'],
    'commitments': ['Send rollout plan'],
    'tone': 'focused',
  };

  test(
    'OpenAI uses Responses structured output without response storage',
    () async {
      late http.Request captured;
      final client = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'output': [
              {
                'type': 'message',
                'content': [
                  {'type': 'output_text', 'text': jsonEncode(extraction)},
                ],
              },
            ],
            'usage': {'input_tokens': 100, 'output_tokens': 30},
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final transport = HttpAiProviderTransport(client, isWeb: false);

      final response = await transport.extract(
        profile: ExtractionProviderProfile.openAiDefault,
        apiKey: 'test-openai-key',
        captureId: 'capture-1',
        text: 'Discuss launch timing with Priya.',
      );

      expect(captured.method, 'POST');
      expect(captured.url.toString(), 'https://api.openai.com/v1/responses');
      expect(captured.headers['authorization'], 'Bearer test-openai-key');
      final body = Map<String, Object?>.from(jsonDecode(captured.body) as Map);
      expect(body['store'], isFalse);
      final text = Map<String, Object?>.from(body['text']! as Map);
      final format = Map<String, Object?>.from(text['format']! as Map);
      expect(format['type'], 'json_schema');
      expect(format['strict'], isTrue);
      expect(captured.body, isNot(contains('test-openai-key')));
      expect(response.outputText, contains('capture-1'));
      expect(response.inputTokens, 100);
      expect(response.outputTokens, 30);
    },
  );

  test(
    'Anthropic uses Messages structured output and web direct-access opt in',
    () async {
      late http.Request captured;
      final client = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'content': [
              {'type': 'text', 'text': jsonEncode(extraction)},
            ],
            'usage': {'input_tokens': 110, 'output_tokens': 25},
          }),
          200,
        );
      });
      final transport = HttpAiProviderTransport(client, isWeb: true);

      final response = await transport.extract(
        profile: ExtractionProviderProfile.anthropicDefault,
        apiKey: 'test-anthropic-key',
        captureId: 'capture-1',
        text: 'Discuss launch timing with Priya.',
      );

      expect(captured.url.toString(), 'https://api.anthropic.com/v1/messages');
      expect(captured.headers['x-api-key'], 'test-anthropic-key');
      expect(captured.headers['anthropic-version'], '2023-06-01');
      expect(
        captured.headers['anthropic-dangerous-direct-browser-access'],
        'true',
      );
      final body = Map<String, Object?>.from(jsonDecode(captured.body) as Map);
      final outputConfig = Map<String, Object?>.from(
        body['output_config']! as Map,
      );
      final format = Map<String, Object?>.from(outputConfig['format']! as Map);
      expect(format['type'], 'json_schema');
      expect(captured.body, isNot(contains('test-anthropic-key')));
      expect(response.inputTokens, 110);
      expect(response.outputTokens, 25);
    },
  );

  test(
    'compatible provider uses configured chat-completions endpoint',
    () async {
      late http.Request captured;
      final client = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {'content': jsonEncode(extraction)},
              },
            ],
            'usage': {'prompt_tokens': 90, 'completion_tokens': 20},
          }),
          200,
        );
      });
      final transport = HttpAiProviderTransport(client, isWeb: false);
      final profile = ExtractionProviderProfile.compatible(
        baseUrl: 'https://example.test/v1/',
        model: 'example-model',
        inputUsdPerMillionTokens: 0.5,
        outputUsdPerMillionTokens: 1.5,
      );

      final response = await transport.extract(
        profile: profile,
        apiKey: 'compatible-key',
        captureId: 'capture-1',
        text: 'Discuss launch timing with Priya.',
      );

      expect(
        captured.url.toString(),
        'https://example.test/v1/chat/completions',
      );
      expect(captured.headers['authorization'], 'Bearer compatible-key');
      final body = Map<String, Object?>.from(jsonDecode(captured.body) as Map);
      expect(body['model'], 'example-model');
      expect(
        Map<String, Object?>.from(body['response_format']! as Map)['type'],
        'json_object',
      );
      expect(captured.body, isNot(contains('compatible-key')));
      expect(response.inputTokens, 90);
      expect(response.outputTokens, 20);
    },
  );

  test(
    'provider errors never expose raw response bodies or API keys',
    () async {
      final client = MockClient(
        (_) async => http.Response('server leaked test-secret-key', 401),
      );
      final transport = HttpAiProviderTransport(client, isWeb: false);

      Object? error;
      try {
        await transport.extract(
          profile: ExtractionProviderProfile.openAiDefault,
          apiKey: 'test-secret-key',
          captureId: 'capture-1',
          text: 'A note',
        );
      } on Object catch (caught) {
        error = caught;
      }

      expect(error, isNotNull);
      expect(error.toString(), isNot(contains('test-secret-key')));
      expect(error.toString(), isNot(contains('server leaked')));
    },
  );
}
