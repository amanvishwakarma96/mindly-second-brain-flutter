import 'package:mindly/features/text_capture/domain/text_capture_models.dart';

class AiProviderResponse {
  const AiProviderResponse({
    required this.outputText,
    this.inputTokens,
    this.outputTokens,
  });

  final String outputText;
  final int? inputTokens;
  final int? outputTokens;
}

class AiProviderRequestException implements Exception {
  const AiProviderRequestException({required this.providerId, this.statusCode});

  final String providerId;
  final int? statusCode;

  @override
  String toString() {
    final status = statusCode == null ? '' : ' (HTTP $statusCode)';
    return 'AI provider request failed for $providerId$status.';
  }
}

abstract interface class AiProviderTransport {
  Future<AiProviderResponse> extract({
    required ExtractionProviderProfile profile,
    required String apiKey,
    required String captureId,
    required String text,
  });
}
