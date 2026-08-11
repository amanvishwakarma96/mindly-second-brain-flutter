import 'dart:convert';

import 'package:mindly/features/ai_settings/domain/cost_models.dart';
import 'package:mindly/features/insights/domain/insight_models.dart';
import 'package:mindly/features/text_capture/domain/text_capture_models.dart';

class Tier3EvidenceSource {
  const Tier3EvidenceSource({
    required this.sourceId,
    required this.reference,
    required this.content,
  });

  final String sourceId;
  final InsightSourceReference reference;
  final String content;

  Map<String, Object?> toPromptJson() => {
    'source_id': sourceId,
    'type': reference.type.wireName,
    'title': reference.title,
    'content': content,
  };
}

class Tier3EvidenceBundle {
  const Tier3EvidenceBundle({
    required this.sources,
    required this.totalCharacters,
  });

  final List<Tier3EvidenceSource> sources;
  final int totalCharacters;

  bool get isEmpty => sources.isEmpty;

  String toPromptJson() => jsonEncode({
    'sources': sources.map((source) => source.toPromptJson()).toList(),
  });
}

enum Tier3PreviewStatus {
  ready,
  insufficientEvidence,
  missingKey,
  spendBlocked,
  muted,
}

class Tier3GenerationPreview {
  const Tier3GenerationPreview({
    required this.status,
    required this.profile,
    required this.bundle,
    this.estimate,
    this.spendBlockReason,
  });

  final Tier3PreviewStatus status;
  final ExtractionProviderProfile profile;
  final Tier3EvidenceBundle bundle;
  final CostEstimate? estimate;
  final SpendBlockReason? spendBlockReason;

  bool get isReady => status == Tier3PreviewStatus.ready;
  int get sourceCount => bundle.sources.length;
}

enum Tier3GenerationOutcomeKind {
  generated,
  insufficientEvidence,
  missingKey,
  spendBlocked,
  muted,
  providerFailure,
  invalidResponse,
}

class Tier3GenerationOutcome {
  const Tier3GenerationOutcome({
    required this.kind,
    required this.preview,
    this.insight,
  });

  final Tier3GenerationOutcomeKind kind;
  final Tier3GenerationPreview preview;
  final ProactiveInsight? insight;

  bool get generated => kind == Tier3GenerationOutcomeKind.generated;
}

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

class Tier3InsightDraft {
  const Tier3InsightDraft({
    required this.title,
    required this.body,
    required this.explanation,
    required this.severity,
    required this.sourceIds,
  });

  static const jsonSchema = <String, Object?>{
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'title': {'type': 'string', 'minLength': 1, 'maxLength': 120},
      'body': {'type': 'string', 'minLength': 1, 'maxLength': 900},
      'explanation': {'type': 'string', 'minLength': 1, 'maxLength': 700},
      'severity': {
        'type': 'string',
        'enum': ['info', 'recommendation', 'warning'],
      },
      'source_ids': {
        'type': 'array',
        'minItems': 1,
        'maxItems': 8,
        'uniqueItems': true,
        'items': {'type': 'string'},
      },
    },
    'required': ['title', 'body', 'explanation', 'severity', 'source_ids'],
  };

  final String title;
  final String body;
  final String explanation;
  final InsightSeverity severity;
  final List<String> sourceIds;

  factory Tier3InsightDraft.fromJson(Map<String, Object?> json) {
    final title = (json['title'] as String?)?.trim() ?? '';
    final body = (json['body'] as String?)?.trim() ?? '';
    final explanation = (json['explanation'] as String?)?.trim() ?? '';
    final severityValue = (json['severity'] as String?)?.trim() ?? '';
    final rawSourceIds = json['source_ids'];
    if (title.isEmpty ||
        body.isEmpty ||
        explanation.isEmpty ||
        rawSourceIds is! List ||
        rawSourceIds.isEmpty ||
        rawSourceIds.length > 8) {
      throw const FormatException('Invalid Tier 3 insight payload.');
    }

    final sourceIds = <String>[];
    final seen = <String>{};
    for (final raw in rawSourceIds) {
      if (raw is! String || raw.trim().isEmpty || !seen.add(raw.trim())) {
        throw const FormatException('Invalid Tier 3 source references.');
      }
      sourceIds.add(raw.trim());
    }

    final severity = switch (severityValue) {
      'info' => InsightSeverity.info,
      'recommendation' => InsightSeverity.recommendation,
      'warning' => InsightSeverity.warning,
      _ => throw const FormatException('Invalid Tier 3 severity.'),
    };

    return Tier3InsightDraft(
      title: title,
      body: body,
      explanation: explanation,
      severity: severity,
      sourceIds: List<String>.unmodifiable(sourceIds),
    );
  }
}
