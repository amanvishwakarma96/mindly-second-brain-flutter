import 'dart:math' as math;

import 'package:mindly/features/ai_settings/domain/cost_models.dart';
import 'package:mindly/features/audio_capture/data/openai_cloud_audio_transcriber.dart';

class AudioCostEstimator {
  const AudioCostEstimator();

  // Conservative preflight estimate based on OpenAI's current asynchronous
  // transcription list price. The exact billed amount is provider-controlled.
  static const estimatedUsdPerMinute = 0.0045;

  CostEstimate estimate(Duration duration) {
    final billedMilliseconds = math.max(duration.inMilliseconds, 1000);
    final estimatedUsd =
        billedMilliseconds / Duration.millisecondsPerMinute *
        estimatedUsdPerMinute;
    return CostEstimate(
      providerId: 'openai',
      model: OpenAiCloudAudioTranscriber.model,
      inputTokens: 0,
      outputTokens: 0,
      estimatedUsd: estimatedUsd,
    );
  }
}
