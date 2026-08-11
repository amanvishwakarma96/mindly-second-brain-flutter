import 'package:mindly/features/insights/data/insight_evidence_repository.dart';
import 'package:mindly/features/insights/data/insight_preference_store.dart';
import 'package:mindly/features/insights/domain/insight_models.dart';
import 'package:mindly/features/memory/domain/memory_models.dart';

class ProactiveInsightService {
  ProactiveInsightService({
    required InsightEvidenceRepository evidenceRepository,
    required InsightPreferenceStore preferenceStore,
    DateTime Function()? clock,
  }) : _evidenceRepository = evidenceRepository,
       _preferenceStore = preferenceStore,
       _clock = clock ?? DateTime.now;

  static const Duration dueSoonHorizon = Duration(days: 3);
  static const Duration staleCommitmentAge = Duration(days: 14);

  final InsightEvidenceRepository _evidenceRepository;
  final InsightPreferenceStore _preferenceStore;
  final DateTime Function() _clock;

  Future<List<ProactiveInsight>> load() async {
    final preferences = await _preferenceStore.load();
    final candidates = <String, ProactiveInsight>{};

    for (final relation in await _evidenceRepository.loadTier1Relationships()) {
      final candidate = relation.relationType == 'follows_up_on'
          ? _followUpInsight(relation)
          : _relatedMemoryInsight(relation);
      _keepNewest(candidates, candidate);
    }

    final now = _clock().toUtc();
    for (final commitment in await _evidenceRepository.loadOpenCommitments()) {
      final candidate = _commitmentInsight(commitment, now);
      if (candidate != null) {
        _keepNewest(candidates, candidate);
      }
    }

    final visible = candidates.values
        .where(
          (insight) =>
              !preferences.dismissedFingerprints.contains(insight.fingerprint) &&
              !preferences.mutedKinds.contains(insight.kind),
        )
        .toList(growable: false);
    visible.sort(_compareInsights);
    return visible;
  }

  Future<void> dismiss(String fingerprint) async {
    if (fingerprint.trim().isEmpty) {
      return;
    }
    final preferences = await _preferenceStore.load();
    await _preferenceStore.save(
      preferences.copyWith(
        dismissedFingerprints: <String>{
          ...preferences.dismissedFingerprints,
          fingerprint,
        },
      ),
    );
  }

  Future<void> setMuted(InsightKind kind, bool muted) async {
    final preferences = await _preferenceStore.load();
    final kinds = <InsightKind>{...preferences.mutedKinds};
    if (muted) {
      kinds.add(kind);
    } else {
      kinds.remove(kind);
    }
    await _preferenceStore.save(preferences.copyWith(mutedKinds: kinds));
  }

  Future<Set<InsightKind>> mutedKinds() async {
    final preferences = await _preferenceStore.load();
    return Set<InsightKind>.unmodifiable(preferences.mutedKinds);
  }

  Future<MemoryDetail?> sourceDetail(InsightSourceReference source) {
    return _evidenceRepository.sourceDetail(source);
  }

  ProactiveInsight _relatedMemoryInsight(
    InsightRelationshipEvidence relation,
  ) {
    final sources = <InsightSourceReference>[relation.from, relation.to]
      ..sort((left, right) => left.stableKey.compareTo(right.stableKey));
    return ProactiveInsight(
      fingerprint: 'relatedMemory|${sources[0].stableKey}|${sources[1].stableKey}',
      kind: InsightKind.relatedMemory,
      tier: InsightTier.tier1,
      severity: InsightSeverity.info,
      title: 'These memories are connected',
      body: '${sources[0].title} is related to ${sources[1].title}.',
      evidenceAt: relation.createdAt.toUtc(),
      sources: List<InsightSourceReference>.unmodifiable(sources),
    );
  }

  ProactiveInsight _followUpInsight(InsightRelationshipEvidence relation) {
    return ProactiveInsight(
      fingerprint:
          'followUp|${relation.from.stableKey}|${relation.to.stableKey}',
      kind: InsightKind.followUp,
      tier: InsightTier.tier1,
      severity: InsightSeverity.recommendation,
      title: 'A thought follows up on another',
      body: '${relation.from.title} follows up on ${relation.to.title}.',
      evidenceAt: relation.createdAt.toUtc(),
      sources: <InsightSourceReference>[relation.from, relation.to],
    );
  }

  ProactiveInsight? _commitmentInsight(
    InsightCommitmentEvidence commitment,
    DateTime now,
  ) {
    final dueDate = commitment.dueDate?.toUtc();
    if (dueDate != null && dueDate.isBefore(now)) {
      return ProactiveInsight(
        fingerprint:
            'overdueCommitment|${commitment.id}|${dueDate.toIso8601String()}|${Uri.encodeComponent(commitment.text.trim())}',
        kind: InsightKind.overdueCommitment,
        tier: InsightTier.tier2,
        severity: InsightSeverity.warning,
        title: 'This commitment is overdue',
        body: commitment.text,
        evidenceAt: dueDate,
        sources: commitment.sources,
      );
    }

    if (dueDate != null && !dueDate.isAfter(now.add(dueSoonHorizon))) {
      return ProactiveInsight(
        fingerprint:
            'dueSoonCommitment|${commitment.id}|${dueDate.toIso8601String()}|${Uri.encodeComponent(commitment.text.trim())}',
        kind: InsightKind.dueSoonCommitment,
        tier: InsightTier.tier2,
        severity: InsightSeverity.recommendation,
        title: 'A commitment is due soon',
        body: commitment.text,
        evidenceAt: dueDate,
        sources: commitment.sources,
      );
    }

    final createdAt = commitment.createdAt.toUtc();
    if (dueDate == null && !createdAt.isAfter(now.subtract(staleCommitmentAge))) {
      return ProactiveInsight(
        fingerprint:
            'staleCommitment|${commitment.id}|${createdAt.toIso8601String()}|${Uri.encodeComponent(commitment.text.trim())}',
        kind: InsightKind.staleCommitment,
        tier: InsightTier.tier2,
        severity: InsightSeverity.recommendation,
        title: 'This commitment has been open for a while',
        body: commitment.text,
        evidenceAt: createdAt,
        sources: commitment.sources,
      );
    }
    return null;
  }

  void _keepNewest(
    Map<String, ProactiveInsight> candidates,
    ProactiveInsight candidate,
  ) {
    final current = candidates[candidate.fingerprint];
    if (current == null || candidate.evidenceAt.isAfter(current.evidenceAt)) {
      candidates[candidate.fingerprint] = candidate;
    }
  }

  int _compareInsights(ProactiveInsight left, ProactiveInsight right) {
    final severity = right.severity.priority.compareTo(left.severity.priority);
    if (severity != 0) {
      return severity;
    }
    final evidence = right.evidenceAt.compareTo(left.evidenceAt);
    if (evidence != 0) {
      return evidence;
    }
    return left.fingerprint.compareTo(right.fingerprint);
  }
}
