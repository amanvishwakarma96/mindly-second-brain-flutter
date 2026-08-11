import 'package:mindly/features/insights/domain/tier3_models.dart';
import 'package:mindly/features/text_capture/domain/text_capture_models.dart';

abstract final class Tier3UiPresenter {
  static ExtractionProviderProfile profileFor(String providerId) {
    return switch (providerId) {
      'anthropic' => ExtractionProviderProfile.anthropicDefault,
      _ => ExtractionProviderProfile.openAiDefault,
    };
  }

  static String previewMessage(Tier3GenerationPreview preview) {
    final estimate = preview.estimate;
    return switch (preview.status) {
      Tier3PreviewStatus.ready =>
        '${preview.sourceCount} local source(s) · estimated \$${estimate!.estimatedUsd.toStringAsFixed(4)}',
      Tier3PreviewStatus.insufficientEvidence =>
        'Add or connect more memories before asking AI to synthesize an insight.',
      Tier3PreviewStatus.missingKey =>
        'Add the ${preview.profile.configuration.displayName} API key in Settings first.',
      Tier3PreviewStatus.spendBlocked =>
        'Your spend cap blocks this estimated request.',
      Tier3PreviewStatus.muted =>
        'AI synthesis is muted. Unmute it from Muted types first.',
    };
  }

  static String outcomeMessage(Tier3GenerationOutcome outcome) {
    return switch (outcome.kind) {
      Tier3GenerationOutcomeKind.generated =>
        'AI synthesis is grounded in the linked local sources below.',
      Tier3GenerationOutcomeKind.insufficientEvidence =>
        'There is not enough connected local evidence yet.',
      Tier3GenerationOutcomeKind.missingKey =>
        'The selected provider key is missing.',
      Tier3GenerationOutcomeKind.spendBlocked =>
        'Your spend cap blocked this AI request.',
      Tier3GenerationOutcomeKind.muted => 'AI synthesis is muted.',
      Tier3GenerationOutcomeKind.providerFailure =>
        'The provider request failed. Your local insights are still available.',
      Tier3GenerationOutcomeKind.invalidResponse =>
        'The provider response could not be safely traced to local sources.',
    };
  }
}
