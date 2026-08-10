import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mindly/features/audio_capture/data/openai_cloud_audio_transcriber.dart';

void main() {
  test('Web transcription request is direct BYOK multipart OpenAI traffic', () async {
    final client = _CapturingClient(
      statusCode: 200,
      responseBody: jsonEncode({'text': 'hello from audio'}),
    );
    final transcriber = OpenAiCloudAudioTranscriber(client);

    final transcript = await transcriber.transcribe(
      wavBytes: Uint8List.fromList([82, 73, 70, 70, 1, 2, 3]),
      apiKey: 'sk-contract-test',
    );

    final request = client.request!;
    expect(request.url, OpenAiCloudAudioTranscriber.endpoint);
    expect(request.url.host, 'api.openai.com');
    expect(request.url.path, '/v1/audio/transcriptions');
    expect(request.headers['Authorization'], 'Bearer sk-contract-test');
    expect(request.fields['model'], OpenAiCloudAudioTranscriber.model);
    expect(request.files, hasLength(1));
    expect(request.files.single.field, 'file');
    expect(request.files.single.filename, 'mindly-recording.wav');
    expect(transcript, 'hello from audio');
  });

  test('provider error text never contains response body or API key', () async {
    final client = _CapturingClient(
      statusCode: 401,
      responseBody: '{"error":"secret provider payload"}',
    );
    final transcriber = OpenAiCloudAudioTranscriber(client);

    try {
      await transcriber.transcribe(
        wavBytes: Uint8List.fromList([1, 2, 3]),
        apiKey: 'sk-do-not-leak',
      );
      fail('Expected provider failure.');
    } on AudioProviderException catch (error) {
      expect(error.toString(), isNot(contains('secret provider payload')));
      expect(error.toString(), isNot(contains('sk-do-not-leak')));
    }
  });
}

class _CapturingClient extends http.BaseClient {
  _CapturingClient({required this.statusCode, required this.responseBody});

  final int statusCode;
  final String responseBody;
  http.MultipartRequest? request;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    this.request = request as http.MultipartRequest;
    return http.StreamedResponse(
      Stream<List<int>>.value(utf8.encode(responseBody)),
      statusCode,
    );
  }
}
