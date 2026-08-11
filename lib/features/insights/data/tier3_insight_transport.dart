import 'package:mindly/features/insights/domain/tier3_models.dart';
import 'package:mindly/features/text_capture/domain/text_capture_models.dart';

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
    return 'Tier 3 provider request failed for $providerId$status.';
  }
}

abstract interface class Tier3InsightTransport {
  Future<Tier3ProviderResponse> synthesize({
    required ExtractionProviderProfile profile,
    required String apiKey,
    required Tier3EvidenceBundle evidence,
  });
}
