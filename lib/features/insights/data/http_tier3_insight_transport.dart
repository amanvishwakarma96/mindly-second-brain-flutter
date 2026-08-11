import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mindly/features/ai_settings/domain/provider_configuration.dart';
import 'package:mindly/features/insights/data/tier3_insight_transport.dart';
import 'package:mindly/features/insights/domain/tier3_models.dart';
import 'package:mindly/features/text_capture/domain/text_capture_models.dart';

class HttpTier3InsightTransport implements Tier3InsightTransport {
  HttpTier3InsightTransport(this._client, {bool? isWeb})
    : _isWeb = isWeb ?? kIsWeb;

  final http.Client _client;
  final bool _isWeb;

  static const _systemPrompt = '''
You synthesize one explainable insight for a private second-brain app.
Use only the supplied evidence. Do not invent facts, people, commitments, dates,
or source identifiers. Return a concise recommendation, warning, or informational
connection only when supported by the evidence. The explanation is a short
user-facing explanation of why the insight is grounded; do not provide hidden
chain-of-thought or private reasoning. source_ids must contain only identifiers
that appear verbatim in the supplied evidence. Return only the requested object.
''';

  @override
  Future<Tier3ProviderResponse> synthesize({
    required ExtractionProviderProfile profile,
    required String apiKey,
    required Tier3EvidenceBundle evidence,
  }) {
    final key = apiKey.trim();
    if (key.isEmpty) {
      throw ArgumentError('A provider API key is required.');
    }
    if (evidence.isEmpty) {
      throw ArgumentError('Tier 3 evidence cannot be empty.');
    }

    return switch (profile.configuration.kind) {
      AiProviderKind.openAi => _openAi(
        profile: profile,
        apiKey: key,
        evidence: evidence,
      ),
      AiProviderKind.anthropic => _anthropic(
        profile: profile,
        apiKey: key,
        evidence: evidence,
      ),
      AiProviderKind.compatible => _compatible(
        profile: profile,
        apiKey: key,
        evidence: evidence,
      ),
    };
  }

  Future<Tier3ProviderResponse> _openAi({
    required ExtractionProviderProfile profile,
    required String apiKey,
    required Tier3EvidenceBundle evidence,
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
              {'type': 'input_text', 'text': _evidencePrompt(evidence)},
            ],
          },
        ],
        'text': {
          'format': {
            'type': 'json_schema',
            'name': 'mindly_tier3_insight',
            'strict': true,
            'schema': Tier3InsightDraft.jsonSchema,
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
    required ExtractionProviderProfile profile,
    required String apiKey,
    required Tier3EvidenceBundle evidence,
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
          {'role': 'user', 'content': _evidencePrompt(evidence)},
        ],
        'output_config': {
          'format': {
            'type': 'json_schema',
            'schema': Tier3InsightDraft.jsonSchema,
          },
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
    required ExtractionProviderProfile profile,
    required String apiKey,
    required Tier3EvidenceBundle evidence,
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
          {'role': 'user', 'content': _evidencePrompt(evidence)},
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

  String _model(ExtractionProviderProfile profile) {
    final model = profile.configuration.defaultModel?.trim();
    if (model == null || model.isEmpty) {
      throw Tier3ProviderRequestException(providerId: profile.configuration.id);
    }
    return model;
  }

  String _evidencePrompt(Tier3EvidenceBundle evidence) =>
      '''
Use this bounded local evidence bundle. Every source_ids value in your response must be one of the source_id values below.

${evidence.toPromptJson()}
''';
}
