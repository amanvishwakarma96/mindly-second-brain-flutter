import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mindly/features/ai_settings/domain/provider_configuration.dart';
import 'package:mindly/features/text_capture/data/ai_provider_transport.dart';
import 'package:mindly/features/text_capture/domain/memory_extraction.dart';
import 'package:mindly/features/text_capture/domain/text_capture_models.dart';

class HttpAiProviderTransport implements AiProviderTransport {
  HttpAiProviderTransport(this._client, {bool? isWeb})
    : _isWeb = isWeb ?? kIsWeb;

  final http.Client _client;
  final bool _isWeb;

  static const _systemPrompt = '''
You extract structured memory from one user-authored note for a private second-brain app.
Summarize only what the note supports. Do not invent people, topics, commitments, or tone.
Classify context as work, personal, or ambiguous. Use ambiguous whenever the note does not
provide enough evidence to choose safely. Commitments must be short action/obligation strings.
Return only the requested structured object.
''';

  @override
  Future<AiProviderResponse> extract({
    required ExtractionProviderProfile profile,
    required String apiKey,
    required String captureId,
    required String text,
  }) {
    final key = apiKey.trim();
    if (key.isEmpty) {
      throw ArgumentError('A provider API key is required.');
    }

    return switch (profile.configuration.kind) {
      AiProviderKind.openAi => _openAi(
        profile: profile,
        apiKey: key,
        captureId: captureId,
        text: text,
      ),
      AiProviderKind.anthropic => _anthropic(
        profile: profile,
        apiKey: key,
        captureId: captureId,
        text: text,
      ),
      AiProviderKind.compatible => _compatible(
        profile: profile,
        apiKey: key,
        captureId: captureId,
        text: text,
      ),
    };
  }

  Future<AiProviderResponse> _openAi({
    required ExtractionProviderProfile profile,
    required String apiKey,
    required String captureId,
    required String text,
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
              {'type': 'input_text', 'text': _capturePrompt(captureId, text)},
            ],
          },
        ],
        'text': {
          'format': {
            'type': 'json_schema',
            'name': 'mindly_memory_extraction',
            'strict': true,
            'schema': MemoryExtraction.jsonSchema,
          },
        },
      }),
    );

    final body = _successfulBody(response, profile.configuration.id);
    return AiProviderResponse(
      outputText: _openAiOutputText(body),
      inputTokens: _nestedInt(body, 'usage', 'input_tokens'),
      outputTokens: _nestedInt(body, 'usage', 'output_tokens'),
    );
  }

  Future<AiProviderResponse> _anthropic({
    required ExtractionProviderProfile profile,
    required String apiKey,
    required String captureId,
    required String text,
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
          {'role': 'user', 'content': _capturePrompt(captureId, text)},
        ],
        'output_config': {
          'format': {
            'type': 'json_schema',
            'schema': MemoryExtraction.jsonSchema,
          },
        },
      }),
    );

    final body = _successfulBody(response, profile.configuration.id);
    return AiProviderResponse(
      outputText: _anthropicOutputText(body),
      inputTokens: _nestedInt(body, 'usage', 'input_tokens'),
      outputTokens: _nestedInt(body, 'usage', 'output_tokens'),
    );
  }

  Future<AiProviderResponse> _compatible({
    required ExtractionProviderProfile profile,
    required String apiKey,
    required String captureId,
    required String text,
  }) async {
    final baseUrl = profile.configuration.baseUrl;
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      throw const AiProviderRequestException(providerId: 'compatible');
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
          {'role': 'user', 'content': _capturePrompt(captureId, text)},
        ],
        'response_format': {'type': 'json_object'},
      }),
    );

    final body = _successfulBody(response, profile.configuration.id);
    return AiProviderResponse(
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
      throw AiProviderRequestException(
        providerId: providerId,
        statusCode: response.statusCode,
      );
    }
    try {
      return Map<String, Object?>.from(jsonDecode(response.body) as Map);
    } on Object {
      throw AiProviderRequestException(
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
    throw const AiProviderRequestException(providerId: 'openai');
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
    throw const AiProviderRequestException(providerId: 'anthropic');
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
    throw const AiProviderRequestException(providerId: 'compatible');
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

  String _model(ExtractionProviderProfile profile) {
    final model = profile.configuration.defaultModel?.trim();
    if (model == null || model.isEmpty) {
      throw AiProviderRequestException(providerId: profile.configuration.id);
    }
    return model;
  }

  String _capturePrompt(String captureId, String text) =>
      '''
Capture ID: $captureId

Source note:
$text
''';
}
