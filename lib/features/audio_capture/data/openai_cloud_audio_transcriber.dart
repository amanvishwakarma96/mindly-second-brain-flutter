import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

abstract interface class CloudAudioTranscriber {
  Future<String> transcribe({
    required Uint8List wavBytes,
    required String apiKey,
  });
}

class AudioProviderException implements Exception {
  const AudioProviderException(this.statusCode);

  final int statusCode;

  @override
  String toString() => 'Audio transcription provider request failed.';
}

class OpenAiCloudAudioTranscriber implements CloudAudioTranscriber {
  OpenAiCloudAudioTranscriber(this._client);

  static final endpoint = Uri.https(
    'api.openai.com',
    '/v1/audio/transcriptions',
  );
  static const model = 'gpt-4o-mini-transcribe';

  final http.Client _client;

  @override
  Future<String> transcribe({
    required Uint8List wavBytes,
    required String apiKey,
  }) async {
    final request = http.MultipartRequest('POST', endpoint)
      ..headers['Authorization'] = 'Bearer $apiKey'
      ..fields['model'] = model
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          wavBytes,
          filename: 'mindly-recording.wav',
        ),
      );

    final response = await _client.send(request);
    final body = await response.stream.bytesToString();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AudioProviderException(response.statusCode);
    }

    try {
      final decoded = Map<String, Object?>.from(jsonDecode(body) as Map);
      final text = decoded['text'];
      if (text is! String) {
        throw const FormatException('Missing transcription text.');
      }
      return text;
    } on FormatException {
      throw const AudioProviderException(200);
    } on TypeError {
      throw const AudioProviderException(200);
    }
  }
}
