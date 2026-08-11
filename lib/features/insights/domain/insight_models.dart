import 'package:mindly/features/memory/domain/memory_models.dart';

enum InsightTier { tier1, tier2 }

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
  staleCommitment;

  String get displayName => switch (this) {
    InsightKind.relatedMemory => 'Related memories',
    InsightKind.followUp => 'Follow-ups',
    InsightKind.overdueCommitment => 'Overdue commitments',
    InsightKind.dueSoonCommitment => 'Due soon',
    InsightKind.staleCommitment => 'Stale commitments',
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
