import 'package:mindly/features/ai_settings/domain/cost_models.dart';
import 'package:mindly/features/ai_settings/domain/provider_configuration.dart';
import 'package:mindly/features/text_capture/domain/memory_extraction.dart';

class ExtractionProviderProfile {
  const ExtractionProviderProfile({
    required this.configuration,
    required this.rateCard,
    required this.maxOutputTokens,
  });

  static const openAiDefault = ExtractionProviderProfile(
    configuration: ProviderConfiguration.openAi(defaultModel: 'gpt-5.6-luna'),
    rateCard: ModelRateCard(
      providerId: 'openai',
      model: 'gpt-5.6-luna',
      inputUsdPerMillionTokens: 1,
      outputUsdPerMillionTokens: 6,
    ),
    maxOutputTokens: 600,
  );

  static const anthropicDefault = ExtractionProviderProfile(
    configuration: ProviderConfiguration.anthropic(
      defaultModel: 'claude-haiku-4-5-20251001',
    ),
    rateCard: ModelRateCard(
      providerId: 'anthropic',
      model: 'claude-haiku-4-5-20251001',
      inputUsdPerMillionTokens: 1,
      outputUsdPerMillionTokens: 5,
    ),
    maxOutputTokens: 600,
  );

  factory ExtractionProviderProfile.compatible({
    required String baseUrl,
    required String model,
    required double inputUsdPerMillionTokens,
    required double outputUsdPerMillionTokens,
    int maxOutputTokens = 600,
  }) {
    final uri = Uri.tryParse(baseUrl.trim());
    if (uri == null ||
        !uri.hasScheme ||
        !uri.hasAuthority ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.userInfo.isNotEmpty) {
      throw ArgumentError.value(
        baseUrl,
        'baseUrl',
        'Enter a valid HTTP(S) API base URL.',
      );
    }
    if (model.trim().isEmpty) {
      throw ArgumentError.value(model, 'model', 'Model is required.');
    }
    if (inputUsdPerMillionTokens < 0 || outputUsdPerMillionTokens < 0) {
      throw ArgumentError(
        'Compatible-provider token prices cannot be negative.',
      );
    }
    if (maxOutputTokens <= 0) {
      throw ArgumentError.value(
        maxOutputTokens,
        'maxOutputTokens',
        'Output token limit must be positive.',
      );
    }

    final normalizedBaseUrl = baseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
    final normalizedModel = model.trim();
    return ExtractionProviderProfile(
      configuration: ProviderConfiguration.compatible(
        baseUrl: normalizedBaseUrl,
        defaultModel: normalizedModel,
      ),
      rateCard: ModelRateCard(
        providerId: 'compatible',
        model: normalizedModel,
        inputUsdPerMillionTokens: inputUsdPerMillionTokens,
        outputUsdPerMillionTokens: outputUsdPerMillionTokens,
      ),
      maxOutputTokens: maxOutputTokens,
    );
  }

  final ProviderConfiguration configuration;
  final ModelRateCard rateCard;
  final int maxOutputTokens;
}

enum TextCaptureOutcomeKind {
  extracted,
  savedMissingKey,
  savedSpendBlocked,
  savedProviderFailure,
  savedInvalidExtraction,
}

class TextCaptureOutcome {
  const TextCaptureOutcome({
    required this.kind,
    required this.captureId,
    required this.estimate,
    this.extraction,
    this.spendBlockReason,
  });

  final TextCaptureOutcomeKind kind;
  final String captureId;
  final CostEstimate estimate;
  final MemoryExtraction? extraction;
  final SpendBlockReason? spendBlockReason;

  bool get extracted => kind == TextCaptureOutcomeKind.extracted;
}
