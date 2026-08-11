import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mindly/features/insights/data/http_tier3_insight_transport.dart';
import 'package:mindly/features/insights/domain/insight_models.dart';
import 'package:mindly/features/insights/domain/tier3_models.dart';
import 'package:mindly/features/memory/domain/memory_models.dart';
import 'package:mindly/features/text_capture/domain/text_capture_models.dart';

void main() {
  const source = Tier3EvidenceSource(
    sourceId: 'capture:c1',
    reference: InsightSourceReference(
      type: MemoryEntityType.capture,
      id: 'c1',
      title: 'Launch plan',
    ),
    content: 'Launch on Friday.',
  );
  const evidence = Tier3EvidenceBundle(
    sources: [source],
    totalCharacters: 17,
  );
  const validPayload =
      '{"title":"Check launch","body":"Review the launch plan.","explanation":"The source mentions the Friday launch.","severity":"recommendation","source_ids":["capture:c1"]}';

  test('OpenAI Tier 3 request disables storage and uses strict schema', () async {
    late http.Request request;
    final client = MockClient((incoming) async {
      request = incoming;
      return http.Response(
        jsonEncode({
          'output_text': validPayload,
          'usage': {'input_tokens': 40, 'output_tokens': 20},
        }),
        200,
      );
    });
    final transport = HttpTier3InsightTransport(client, isWeb: false);

    final response = await transport.synthesize(
      profile: ExtractionProviderProfile.openAiDefault,
      apiKey: 'secret-openai-key',
      evidence: evidence,
    );

    final body = Map<String, Object?>.from(jsonDecode(request.body) as Map);
    final text = Map<String, Object?>.from(body['text']! as Map);
    final format = Map<String, Object?>.from(text['format']! as Map);
    expect(request.url.toString(), 'https://api.openai.com/v1/responses');
    expect(body['store'], isFalse);
    expect(format['type'], 'json_schema');
    expect(format['strict'], isTrue);
    expect(request.headers['Authorization'], 'Bearer secret-openai-key');
    expect(response.outputText, validPayload);
    expect(response.inputTokens, 40);
  });

  test('Anthropic Tier 3 request uses structured output configuration', () async {
    late http.Request request;
    final client = MockClient((incoming) async {
      request = incoming;
      return http.Response(
        jsonEncode({
          'content': [
            {'type': 'text', 'text': validPayload},
          ],
          'usage': {'input_tokens': 50, 'output_tokens': 25},
        }),
        200,
      );
    });
    final transport = HttpTier3InsightTransport(client, isWeb: true);

    await transport.synthesize(
      profile: ExtractionProviderProfile.anthropicDefault,
      apiKey: 'secret-anthropic-key',
      evidence: evidence,
    );

    final body = Map<String, Object?>.from(jsonDecode(request.body) as Map);
    final outputConfig = Map<String, Object?>.from(
      body['output_config']! as Map,
    );
    final format = Map<String, Object?>.from(outputConfig['format']! as Map);
    expect(request.url.toString(), 'https://api.anthropic.com/v1/messages');
    expect(format['type'], 'json_schema');
    expect(request.headers['x-api-key'], 'secret-anthropic-key');
    expect(
      request.headers['anthropic-dangerous-direct-browser-access'],
      'true',
    );
  });

  test('compatible Tier 3 request honors configured endpoint and model', () async {
    late http.Request request;
    final client = MockClient((incoming) async {
      request = incoming;
      return http.Response(
        jsonEncode({
          'choices': [
            {
              'message': {'content': validPayload},
            },
          ],
          'usage': {'prompt_tokens': 30, 'completion_tokens': 10},
        }),
        200,
      );
    });
    final transport = HttpTier3InsightTransport(client, isWeb: false);
    final profile = ExtractionProviderProfile.compatible(
      baseUrl: 'https://example.test/v1',
      model: 'local-model',
      inputUsdPerMillionTokens: 0.2,
      outputUsdPerMillionTokens: 0.4,
    );

    await transport.synthesize(
      profile: profile,
      apiKey: 'compatible-key',
      evidence: evidence,
    );

    final body = Map<String, Object?>.from(jsonDecode(request.body) as Map);
    final responseFormat = Map<String, Object?>.from(
      body['response_format']! as Map,
    );
    expect(
      request.url.toString(),
      'https://example.test/v1/chat/completions',
    );
    expect(body['model'], 'local-model');
    expect(responseFormat['type'], 'json_object');
  });

  test('provider error text never includes the raw API key', () async {
    final client = MockClient((_) async => http.Response('denied', 401));
    final transport = HttpTier3InsightTransport(client, isWeb: false);
    const rawKey = 'never-print-this-secret';

    Object? error;
    try {
      await transport.synthesize(
        profile: ExtractionProviderProfile.openAiDefault,
        apiKey: rawKey,
        evidence: evidence,
      );
    } on Object catch (caught) {
      error = caught;
    }

    expect(error, isNotNull);
    expect(error.toString(), isNot(contains(rawKey)));
  });
}
