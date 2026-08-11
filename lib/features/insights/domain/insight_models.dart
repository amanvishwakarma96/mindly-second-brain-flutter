import 'package:mindly/features/ai_settings/domain/cost_models.dart';
import 'package:mindly/features/ai_settings/domain/provider_configuration.dart';
import 'package:mindly/features/memory/domain/memory_models.dart';

enum InsightTier { tier1, tier2, tier3 }

enum InsightSeverity {
  info(1),
  recommendation(2),
  warning(3);

  const InsightSeverity(this.priority);

  final int priority;
}

enum InsightKind {
  relatedMemory,
  followUp,
  overdueCommitment,
  dueSoonCommitment,
  staleCommitment,
  aiRecommendation,
  aiWarning;

  String get displayName => switch (this) {
    InsightKind.relatedMemory => 'Related memories',
    InsightKind.followUp => 'Follow-ups',
    InsightKind.overdueCommitment => 'Overdue commitments',
    InsightKind.dueSoonCommitment => 'Due soon',
    InsightKind.staleCommitment => 'Stale commitments',
    InsightKind.aiRecommendation => 'AI recommendations',
    InsightKind.aiWarning => 'AI warnings',
  };
}

class InsightSourceReference {
  const InsightSourceReference({
    required this.type,
    required this.id,
    required this.title,
  });

  final MemoryEntityType type;
  final String id;
  final String title;

  String get stableKey => '${type.wireName}:$id';
}

class ProactiveInsight {
  const ProactiveInsight({
    required this.fingerprint,
    required this.kind,
    required this.tier,
    required this.severity,
    required this.title,
    required this.body,
    required this.evidenceAt,
    required this.sources,
  });

  final String fingerprint;
  final InsightKind kind;
  final InsightTier tier;
  final InsightSeverity severity;
  final String title;
  final String body;
  final DateTime evidenceAt;
  final List<InsightSourceReference> sources;

  bool get isAiGenerated => tier == InsightTier.tier3;
}

class InsightPreferences {
  const InsightPreferences({
    this.dismissedFingerprints = const <String>{},
    this.mutedKinds = const <InsightKind>{},
  });

  final Set<String> dismissedFingerprints;
  final Set<InsightKind> mutedKinds;

  InsightPreferences copyWith({
    Set<String>? dismissedFingerprints,
    Set<InsightKind>? mutedKinds,
  }) {
    return InsightPreferences(
      dismissedFingerprints:
          dismissedFingerprints ?? this.dismissedFingerprints,
      mutedKinds: mutedKinds ?? this.mutedKinds,
    );
  }
}

class Tier3ProviderProfile {
  const Tier3ProviderProfile({
    required this.configuration,
    required this.rateCard,
    this.maxOutputTokens = 900,
  });

  static const openAiDefault = Tier3ProviderProfile(
    configuration: ProviderConfiguration.openAi(defaultModel: 'gpt-5.6-luna'),
    rateCard: ModelRateCard(
      providerId: 'openai',
      model: 'gpt-5.6-luna',
      inputUsdPerMillionTokens: 1,
      outputUsdPerMillionTokens: 6,
    ),
  );

  static const anthropicDefault = Tier3ProviderProfile(
    configuration: ProviderConfiguration.anthropic(
      defaultModel: 'claude-haiku-4-5-20251001',
    ),
    rateCard: ModelRateCard(
      providerId: 'anthropic',
      model: 'claude-haiku-4-5-20251001',
      inputUsdPerMillionTokens: 1,
      outputUsdPerMillionTokens: 5,
    ),
  );

  factory Tier3ProviderProfile.compatible({
    required String baseUrl,
    required String model,
    required double inputUsdPerMillionTokens,
    required double outputUsdPerMillionTokens,
    int maxOutputTokens = 900,
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
      throw ArgumentError('Compatible-provider token prices cannot be negative.');
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
    return Tier3ProviderProfile(
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

class Tier3ContextItem {
  const Tier3ContextItem({
    required this.source,
    required this.content,
    required this.createdAt,
  });

  final InsightSourceReference source;
  final String content;
  final DateTime createdAt;
}

class Tier3GenerationContext {
  const Tier3GenerationContext(this.items);

  final List<Tier3ContextItem> items;

  bool get hasEnoughEvidence => items.length >= 2;

  Set<String> get allowedSourceKeys =>
      items.map((item) => item.source.stableKey).toSet();

  int get characterCount =>
      items.fold<int>(0, (total, item) => total + item.content.runes.length);
}

enum Tier3GenerationOutcomeKind {
  generated,
  insufficientEvidence,
  missingKey,
  spendBlocked,
  providerFailure,
  invalidOutput,
}

class Tier3GenerationOutcome {
  const Tier3GenerationOutcome({
    required this.kind,
    required this.estimate,
    this.insights = const <ProactiveInsight>[],
    this.spendBlockReason,
  });

  final Tier3GenerationOutcomeKind kind;
  final CostEstimate? estimate;
  final List<ProactiveInsight> insights;
  final SpendBlockReason? spendBlockReason;

  bool get generated => kind == Tier3GenerationOutcomeKind.generated;
}
