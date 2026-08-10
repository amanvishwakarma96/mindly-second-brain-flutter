import 'package:mindly/features/ai_settings/domain/cost_models.dart';

class CostEstimator {
  const CostEstimator();

  CostEstimate estimate({
    required ModelRateCard rateCard,
    required int inputTokens,
    required int outputTokens,
  }) {
    if (inputTokens < 0 || outputTokens < 0) {
      throw ArgumentError('Token counts cannot be negative.');
    }

    final inputCost =
        inputTokens * rateCard.inputUsdPerMillionTokens / 1000000;
    final outputCost =
        outputTokens * rateCard.outputUsdPerMillionTokens / 1000000;

    return CostEstimate(
      providerId: rateCard.providerId,
      model: rateCard.model,
      inputTokens: inputTokens,
      outputTokens: outputTokens,
      estimatedUsd: inputCost + outputCost,
    );
  }
}
