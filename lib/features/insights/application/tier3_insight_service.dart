import 'dart:convert';

import 'package:mindly/features/ai_settings/application/cost_estimator.dart';
import 'package:mindly/features/ai_settings/application/provider_key_service.dart';
import 'package:mindly/features/ai_settings/application/spend_guard.dart';
import 'package:mindly/features/ai_settings/data/secure_spend_store.dart';
import 'package:mindly/features/ai_settings/domain/cost_models.dart';
import 'package:mindly/features/insights/data/insight_preference_store.dart';
import 'package:mindly/features/insights/data/tier3_context_repository.dart';
import 'package:mindly/features/insights/data/tier3_insight_store.dart';
import 'package:mindly/features/insights/data/tier3_insight_transport.dart';
import 'package:mindly/features/insights/domain/insight_models.dart';

typedef Tier3Clock = DateTime Function();

class Tier3InsightService {
  factory Tier3InsightService({
    required Tier3ContextRepository contextRepository,
    required Tier3InsightStore insightStore,
    required InsightPreferenceStore preferenceStore,
    required ProviderKeyService keyService,
    required SpendCapsRepository capsRepository,
    required SpendLedger spendLedger,
    required SpendGuard spendGuard,
    required CostEstimator costEstimator,
    required Tier3InsightTransport transport,
    Tier3Clock? clock,
  }) {
    return Tier3InsightService._(
      contextRepository,
      insightStore,
      preferenceStore,
      keyService,
      capsRepository,
      spendLedger,
      spendGuard,
      costEstimator,
      transport,
      clock ?? DateTime.now,
    );
  }

  Tier3InsightService._(
    this._contextRepository,
    this._insightStore,
    this._preferenceStore,
    this._keyService,
    this._capsRepository,
    this._spendLedger,
    this._spendGuard,
    this._costEstimator,
    this._transport,
    this._clock,
  );

  static const int _promptOverheadCharacters = 1800;

  final Tier3ContextRepository _contextRepository;
  final Tier3InsightStore _insightStore;
  final InsightPreferenceStore _preferenceStore;
  final ProviderKeyService _keyService;
  final SpendCapsRepository _capsRepository;
  final SpendLedger _spendLedger;
  final SpendGuard _spendGuard;
  final CostEstimator _costEstimator;
  final Tier3InsightTransport _transport;
  final Tier3Clock _clock;

  Future<List<ProactiveInsight>> load() async {
    final insights = await _insightStore.load();
    final preferences = await _preferenceStore.load();
    return insights
        .where(
          (insight) =>
              !preferences.dismissedFingerprints.contains(insight.fingerprint) &&
              !preferences.mutedKinds.contains(insight.kind),
        )
        .toList(growable: false);
  }

  Future<CostEstimate?> estimate(Tier3ProviderProfile profile) async {
    final context = await _contextRepository.load();
    if (!context.hasEnoughEvidence) return null;
    return _estimateForContext(context, profile);
  }

  Future<Tier3GenerationOutcome> generate(
    Tier3ProviderProfile profile,
  ) async {
    final context = await _contextRepository.load();
    if (!context.hasEnoughEvidence) {
      return const Tier3GenerationOutcome(
        kind: Tier3GenerationOutcomeKind.insufficientEvidence,
        estimate: null,
      );
    }

    final estimate = _estimateForContext(context, profile);
    final apiKey = await _keyService.readKey(profile.configuration.id);
    if (apiKey == null || apiKey.trim().isEmpty) {
      return Tier3GenerationOutcome(
        kind: Tier3GenerationOutcomeKind.missingKey,
        estimate: estimate,
      );
    }

    final now = _clock().toUtc();
    final caps = await _capsRepository.load();
    final decision = await _spendGuard.evaluate(
      estimate: estimate,
      caps: caps,
      now: now,
    );
    if (!decision.isAllowed) {
      return Tier3GenerationOutcome(
        kind: Tier3GenerationOutcomeKind.spendBlocked,
        estimate: estimate,
        spendBlockReason: decision.blockReason,
      );
    }

    Tier3ProviderResponse response;
    try {
      response = await _transport.generate(
        profile: profile,
        apiKey: apiKey,
        context: context,
      );
    } on Object {
      return Tier3GenerationOutcome(
        kind: Tier3GenerationOutcomeKind.providerFailure,
        estimate: estimate,
      );
    }

    final billedEstimate = _costEstimator.estimate(
      rateCard: profile.rateCard,
      inputTokens: response.inputTokens ?? estimate.inputTokens,
      outputTokens: response.outputTokens ?? estimate.outputTokens,
    );
    await _spendLedger.record(
      SpendEntry(at: now, usd: billedEstimate.estimatedUsd),
    );

    final insights = _parseAndValidate(response.outputText, context, now);
    if (insights == null) {
      return Tier3GenerationOutcome(
        kind: Tier3GenerationOutcomeKind.invalidOutput,
        estimate: estimate,
      );
    }

    await _insightStore.save(insights);
    return Tier3GenerationOutcome(
      kind: Tier3GenerationOutcomeKind.generated,
      estimate: estimate,
      insights: insights,
    );
  }

  CostEstimate _estimateForContext(
    Tier3GenerationContext context,
    Tier3ProviderProfile profile,
  ) {
    final estimatedInputTokens =
        ((context.characterCount + _promptOverheadCharacters) / 4).ceil();
    return _costEstimator.estimate(
      rateCard: profile.rateCard,
      inputTokens: estimatedInputTokens,
      outputTokens: profile.maxOutputTokens,
    );
  }

  List<ProactiveInsight>? _parseAndValidate(
    String outputText,
    Tier3GenerationContext context,
    DateTime generatedAt,
  ) {
    try {
      final decoded = jsonDecode(outputText);
      if (decoded is! Map) return null;
      final values = decoded['insights'];
      if (values is! List || values.length > 3) return null;

      final sourceByKey = {
        for (final item in context.items) item.source.stableKey: item,
      };
      final insights = <ProactiveInsight>[];
      final fingerprints = <String>{};

      for (final value in values) {
        if (value is! Map) return null;
        final json = Map<String, Object?>.from(value);
        final kindValue = json['kind'];
        final titleValue = json['title'];
        final bodyValue = json['body'];
        final sourceKeysValue = json['sourceKeys'];
        if (kindValue is! String ||
            titleValue is! String ||
            bodyValue is! String ||
            sourceKeysValue is! List) {
          return null;
        }

        final title = titleValue.trim();
        final body = bodyValue.trim();
        if (title.isEmpty ||
            body.isEmpty ||
            title.runes.length > 160 ||
            body.runes.length > 700 ||
            sourceKeysValue.isEmpty ||
            sourceKeysValue.length > 4) {
          return null;
        }

        final kind = switch (kindValue.trim().toLowerCase()) {
          'recommendation' => InsightKind.aiRecommendation,
          'warning' => InsightKind.aiWarning,
          _ => null,
        };
        if (kind == null) return null;

        final sources = <InsightSourceReference>[];
        final sourceItems = <Tier3ContextItem>[];
        final seenKeys = <String>{};
        for (final keyValue in sourceKeysValue) {
          if (keyValue is! String) return null;
          final key = keyValue.trim();
          final item = sourceByKey[key];
          if (item == null) return null;
          if (seenKeys.add(key)) {
            sources.add(item.source);
            sourceItems.add(item);
          }
        }
        if (sources.isEmpty) return null;

        final sortedKeys = sources.map((source) => source.stableKey).toList()
          ..sort();
        final fingerprint = _fingerprint(
          kind: kind,
          title: title,
          body: body,
          sourceKeys: sortedKeys,
        );
        if (!fingerprints.add(fingerprint)) continue;

        final evidenceAt = sourceItems
            .map((item) => item.createdAt.toUtc())
            .reduce((left, right) => left.isAfter(right) ? left : right);
        insights.add(
          ProactiveInsight(
            fingerprint: fingerprint,
            kind: kind,
            tier: InsightTier.tier3,
            severity: kind == InsightKind.aiWarning
                ? InsightSeverity.warning
                : InsightSeverity.recommendation,
            title: title,
            body: body,
            evidenceAt: evidenceAt.isAfter(generatedAt)
                ? generatedAt
                : evidenceAt,
            sources: List<InsightSourceReference>.unmodifiable(sources),
          ),
        );
      }

      insights.sort((left, right) {
        final severity = right.severity.priority.compareTo(left.severity.priority);
        if (severity != 0) return severity;
        final evidence = right.evidenceAt.compareTo(left.evidenceAt);
        if (evidence != 0) return evidence;
        return left.fingerprint.compareTo(right.fingerprint);
      });
      return List<ProactiveInsight>.unmodifiable(insights);
    } on Object {
      return null;
    }
  }

  String _fingerprint({
    required InsightKind kind,
    required String title,
    required String body,
    required List<String> sourceKeys,
  }) {
    final canonical = [
      kind.name,
      title.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim(),
      body.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim(),
      ...sourceKeys,
    ].join('|');
    var hash = 0x811c9dc5;
    for (final codeUnit in canonical.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return 'tier3_${hash.toRadixString(16).padLeft(8, '0')}';
  }
}
