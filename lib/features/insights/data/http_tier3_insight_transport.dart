import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mindly/features/ai_settings/domain/provider_configuration.dart';
import 'package:mindly/features/insights/data/tier3_insight_transport.dart';
import 'package:mindly/features/insights/domain/insight_models.dart';

class HttpTier3InsightTransport implements Tier3InsightTransport {
  HttpTier3InsightTransport(this._client, {bool? isWeb})
    : _isWeb = isWeb ?? kIsWeb;

  final http.Client _client;
  final bool _isWeb;

  static const Map<String, Object?> _jsonSchema = {
    'type': 'object',
    'additionalProperties': false,
    'required': ['insights'],
    'properties': {
      'insights': {
        'type': 'array',
        'maxItems': 3,
        'items': {
          'type': 'object',
          'additionalProperties': false,
          'required': ['kind', 'title', 'body', 'sourceKeys'],
          'properties': {
            'kind': {
              'type': 'string',
              'enum': ['recommendation', 'warning'],
            },
            'title': {'type': 'string'},
            'body': {'type': 'string'},
            'sourceKeys': {
              'type': 'array',
              'minItems': 1,
              'maxItems': 4,
              'items': {'type': 'string'},
            },
          },
        },
      },
    },
  };

  static const _systemPrompt = '''
You generate a small set of predictive insights for Mindly, a private second-brain app.
Use only the supplied local-memory context. Never invent facts, deadlines, people,
relationships, risks, or commitments. Return zero insights when evidence is too weak.
Recommendations should be practical and optional. Warnings require stronger evidence and
must not use alarmist or surveillance-style language. Every insight must cite one or more
exact source keys from the context that directly support it. Keep titles and bodies concise.
The user must be able to understand why each insight appeared from those cited memories.
Return only the requested structured object.
''';

  @override
  Future<Tier3ProviderResponse> generate({
    required Tier3ProviderProfile profile,
    required String apiKey,
    required Tier3GenerationContext context,
  }) {
    final key = apiKey.trim();
    if (key.isEmpty) {
      throw ArgumentError('A provider API key is required.');
    }
    if (!context.hasEnoughEvidence) {
      throw ArgumentError(
        'Tier 3 generation requires at least two context items.',
      );
    }

    return switch (profile.configuration.kind) {
      AiProviderKind.openAi => _openAi(
        profile: profile,
        apiKey: key,
        context: context,
      ),
      AiProviderKind.anthropic => _anthropic(
        profile: profile,
        apiKey: key,
        context: context,
      ),
      AiProviderKind.compatible => _compatible(
        profile: profile,
        apiKey: key,
        context: context,
      ),
    };
  }

  Future<Tier3ProviderResponse> _openAi({
    required Tier3ProviderProfile profile,
    required String apiKey,
    required Tier3GenerationContext context,
  }) async {
    final response = await _client.post(
      Uri.parse('https://api.openai.com/v1/responses'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _model(profile),
        'store': false,
        'max_output_tokens': profile.maxOutputTokens,
        'instructions': _systemPrompt,
        'input': [
          {
            'role': 'user',
            'content': [
              {'type': 'input_text', 'text': _contextPrompt(context)},
            ],
          },
        ],
        'text': {
          'format': {
            'type': 'json_schema',
            'name': 'mindly_tier3_insights',
            'strict': true,
            'schema': _jsonSchema,
          },
        },
      }),
    );

    final body = _successfulBody(response, profile.configuration.id);
    return Tier3ProviderResponse(
      outputText: _openAiOutputText(body),
      inputTokens: _nestedInt(body, 'usage', 'input_tokens'),
      outputTokens: _nestedInt(body, 'usage', 'output_tokens'),
    );
  }

  Future<Tier3ProviderResponse> _anthropic({
    required Tier3ProviderProfile profile,
    required String apiKey,
    required Tier3GenerationContext context,
  }) async {
    final headers = <String, String>{
      'x-api-key': apiKey,
      'anthropic-version': '2023-06-01',
      'Content-Type': 'application/json',
    };
    if (_isWeb) {
      headers['anthropic-dangerous-direct-browser-access'] = 'true';
    }

    final response = await _client.post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: headers,
      body: jsonEncode({
        'model': _model(profile),
        'max_tokens': profile.maxOutputTokens,
        'system': _systemPrompt,
        'messages': [
          {'role': 'user', 'content': _contextPrompt(context)},
        ],
        'output_config': {
          'format': {'type': 'json_schema', 'schema': _jsonSchema},
        },
      }),
    );

    final body = _successfulBody(response, profile.configuration.id);
    return Tier3ProviderResponse(
      outputText: _anthropicOutputText(body),
      inputTokens: _nestedInt(body, 'usage', 'input_tokens'),
      outputTokens: _nestedInt(body, 'usage', 'output_tokens'),
    );
  }

  Future<Tier3ProviderResponse> _compatible({
    required Tier3ProviderProfile profile,
    required String apiKey,
    required Tier3GenerationContext context,
  }) async {
    final baseUrl = profile.configuration.baseUrl;
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      throw const Tier3ProviderRequestException(providerId: 'compatible');
    }
    final endpoint = Uri.parse(
      '${baseUrl.replaceFirst(RegExp(r'/+$'), '')}/chat/completions',
    );
    final response = await _client.post(
      endpoint,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _model(profile),
        'max_tokens': profile.maxOutputTokens,
        'messages': [
          {'role': 'system', 'content': _systemPrompt},
          {'role': 'user', 'content': _contextPrompt(context)},
        ],
        'response_format': {'type': 'json_object'},
      }),
    );

    final body = _successfulBody(response, profile.configuration.id);
    return Tier3ProviderResponse(
      outputText: _compatibleOutputText(body),
      inputTokens: _nestedInt(body, 'usage', 'prompt_tokens'),
      outputTokens: _nestedInt(body, 'usage', 'completion_tokens'),
    );
  }

  Map<String, Object?> _successfulBody(
    http.Response response,
    String providerId,
  ) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Tier3ProviderRequestException(
        providerId: providerId,
        statusCode: response.statusCode,
      );
    }
    try {
      return Map<String, Object?>.from(jsonDecode(response.body) as Map);
    } on Object {
      throw Tier3ProviderRequestException(
        providerId: providerId,
        statusCode: response.statusCode,
      );
    }
  }

  String _openAiOutputText(Map<String, Object?> body) {
    final direct = body['output_text'];
    if (direct is String && direct.trim().isNotEmpty) return direct.trim();
    final output = body['output'];
    if (output is List) {
      for (final item in output) {
        if (item is! Map) continue;
        final content = item['content'];
        if (content is! List) continue;
        for (final block in content) {
          if (block is! Map || block['type'] != 'output_text') continue;
          final text = block['text'];
          if (text is String && text.trim().isNotEmpty) return text.trim();
        }
      }
    }
    throw const Tier3ProviderRequestException(providerId: 'openai');
  }

  String _anthropicOutputText(Map<String, Object?> body) {
    final content = body['content'];
    if (content is List) {
      for (final block in content) {
        if (block is! Map || block['type'] != 'text') continue;
        final text = block['text'];
        if (text is String && text.trim().isNotEmpty) return text.trim();
      }
    }
    throw const Tier3ProviderRequestException(providerId: 'anthropic');
  }

  String _compatibleOutputText(Map<String, Object?> body) {
    final choices = body['choices'];
    if (choices is List && choices.isNotEmpty) {
      final first = choices.first;
      if (first is Map) {
        final message = first['message'];
        if (message is Map) {
          final content = message['content'];
          if (content is String && content.trim().isNotEmpty) {
            return content.trim();
          }
        }
      }
    }
    throw const Tier3ProviderRequestException(providerId: 'compatible');
  }

  int? _nestedInt(
    Map<String, Object?> body,
    String objectKey,
    String fieldKey,
  ) {
    final object = body[objectKey];
    if (object is! Map) return null;
    final value = object[fieldKey];
    return value is num ? value.toInt() : null;
  }

  String _model(Tier3ProviderProfile profile) {
    final model = profile.configuration.defaultModel?.trim();
    if (model == null || model.isEmpty) {
      throw Tier3ProviderRequestException(providerId: profile.configuration.id);
    }
    return model;
  }

  String _contextPrompt(Tier3GenerationContext context) {
    final buffer = StringBuffer()
      ..writeln(
        'Use only these memory items. Source keys must be copied exactly:',
      );
    for (final item in context.items) {
      buffer
        ..writeln('\nSOURCE ${item.source.stableKey}')
        ..writeln('Title: ${item.source.title}')
        ..writeln('Created: ${item.createdAt.toUtc().toIso8601String()}')
        ..writeln(item.content);
    }
    return buffer.toString();
  }
}
