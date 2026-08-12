import 'package:mindly/features/insights/domain/insight_models.dart';

class Tier3ProviderResponse {
  const Tier3ProviderResponse({
    required this.outputText,
    this.inputTokens,
    this.outputTokens,
  });

  final String outputText;
  final int? inputTokens;
  final int? outputTokens;
}

class Tier3ProviderRequestException implements Exception {
  const Tier3ProviderRequestException({
    required this.providerId,
    this.statusCode,
  });

  final String providerId;
  final int? statusCode;

  @override
  String toString() {
    final status = statusCode == null ? '' : ' (HTTP $statusCode)';
    return 'Tier 3 AI provider request failed for $providerId$status.';
  }
}

abstract interface class Tier3InsightTransport {
  Future<Tier3ProviderResponse> generate({
    required Tier3ProviderProfile profile,
    required String apiKey,
    required Tier3GenerationContext context,
  });
}
