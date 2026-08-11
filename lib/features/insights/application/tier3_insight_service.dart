import 'dart:convert';

import 'package:mindly/features/ai_settings/application/cost_estimator.dart';
import 'package:mindly/features/ai_settings/application/provider_key_service.dart';
import 'package:mindly/features/ai_settings/application/spend_guard.dart';
import 'package:mindly/features/ai_settings/data/secure_spend_store.dart';
import 'package:mindly/features/ai_settings/domain/cost_models.dart';
import 'package:mindly/features/insights/application/tier3_evidence_builder.dart';
import 'package:mindly/features/insights/data/insight_preference_store.dart';
import 'package:mindly/features/insights/data/tier3_insight_transport.dart';
import 'package:mindly/features/insights/domain/insight_models.dart';
import 'package:mindly/features/insights/domain/tier3_models.dart';
import 'package:mindly/features/text_capture/domain/text_capture_models.dart';

typedef Tier3Clock = DateTime Function();

class Tier3InsightService {
  factory Tier3InsightService({
    required Tier3EvidenceBuilder evidenceBuilder,
    required ProviderKeyService keyService,
    required SpendCapsRepository capsRepository,
    required SpendLedger spendLedger,
    required SpendGuard spendGuard,
    required CostEstimator costEstimator,
    required Tier3InsightTransport transport,
    required InsightPreferenceStore preferenceStore,
    Tier3Clock? clock,
  }) {
    return Tier3InsightService._(
      evidenceBuilder,
      keyService,
      capsRepository,
      spendLedger,
      spendGuard,
      costEstimator,
      transport,
      preferenceStore,
      clock ?? DateTime.now,
    );
  }

  Tier3InsightService._(
    this._evidenceBuilder,
    this._keyService,
    this._capsRepository,
    this._spendLedger,
    this._spendGuard,
    this._costEstimator,
    this._transport,
    this._preferenceStore,
    this._clock,
  );

  static const _promptOverheadCharacters = 1800;

  final Tier3EvidenceBuilder _evidenceBuilder;
  final ProviderKeyService _keyService;
  final SpendCapsRepository _capsRepository;
  final SpendLedger _spendLedger;
  final SpendGuard _spendGuard;
  final CostEstimator _costEstimator;
  final Tier3InsightTransport _transport;
  final InsightPreferenceStore _preferenceStore;
  final Tier3Clock _clock;

  Future<Tier3GenerationPreview> preview(
    ExtractionProviderProfile profile,
  ) async {
    final bundle = await _evidenceBuilder.build();
    if (bundle.isEmpty) {
      return Tier3GenerationPreview(
        status: Tier3PreviewStatus.insufficientEvidence,
        profile: profile,
        bundle: bundle,
      );
    }

    final estimate = _estimate(bundle: bundle, profile: profile);
    final preferences = await _preferenceStore.load();
    if (preferences.mutedKinds.contains(InsightKind.aiSynthesis)) {
      return Tier3GenerationPreview(
        status: Tier3PreviewStatus.muted,
        profile: profile,
        bundle: bundle,
        estimate: estimate,
      );
    }

    final key = await _keyService.readKey(profile.configuration.id);
    if (key == null || key.trim().isEmpty) {
      return Tier3GenerationPreview(
        status: Tier3PreviewStatus.missingKey,
        profile: profile,
        bundle: bundle,
        estimate: estimate,
      );
    }

    final caps = await _capsRepository.load();
    final decision = await _spendGuard.evaluate(
      estimate: estimate,
      caps: caps,
      now: _clock().toUtc(),
    );
    if (!decision.isAllowed) {
      return Tier3GenerationPreview(
        status: Tier3PreviewStatus.spendBlocked,
        profile: profile,
        bundle: bundle,
        estimate: estimate,
        spendBlockReason: decision.blockReason,
      );
    }

    return Tier3GenerationPreview(
      status: Tier3PreviewStatus.ready,
      profile: profile,
      bundle: bundle,
      estimate: estimate,
    );
  }

  Future<Tier3GenerationOutcome> generate(
    ExtractionProviderProfile profile,
  ) async {
    final preflight = await preview(profile);
    final blockedKind = switch (preflight.status) {
      Tier3PreviewStatus.ready => null,
      Tier3PreviewStatus.insufficientEvidence =>
        Tier3GenerationOutcomeKind.insufficientEvidence,
      Tier3PreviewStatus.missingKey => Tier3GenerationOutcomeKind.missingKey,
      Tier3PreviewStatus.spendBlocked =>
        Tier3GenerationOutcomeKind.spendBlocked,
      Tier3PreviewStatus.muted => Tier3GenerationOutcomeKind.muted,
    };
    if (blockedKind != null) {
      return Tier3GenerationOutcome(kind: blockedKind, preview: preflight);
    }

    final apiKey = await _keyService.readKey(profile.configuration.id);
    if (apiKey == null || apiKey.trim().isEmpty) {
      return Tier3GenerationOutcome(
        kind: Tier3GenerationOutcomeKind.missingKey,
        preview: preflight,
      );
    }

    Tier3ProviderResponse response;
    try {
      response = await _transport.synthesize(
        profile: profile,
        apiKey: apiKey,
        evidence: preflight.bundle,
      );
    } on Object {
      return Tier3GenerationOutcome(
        kind: Tier3GenerationOutcomeKind.providerFailure,
        preview: preflight,
      );
    }

    final preflightEstimate = preflight.estimate!;
    final billedEstimate = _costEstimator.estimate(
      rateCard: profile.rateCard,
      inputTokens: response.inputTokens ?? preflightEstimate.inputTokens,
      outputTokens: response.outputTokens ?? preflightEstimate.outputTokens,
    );
    await _spendLedger.record(
      SpendEntry(at: _clock().toUtc(), usd: billedEstimate.estimatedUsd),
    );

    try {
      final decoded = jsonDecode(response.outputText);
      final draft = Tier3InsightDraft.fromJson(
        Map<String, Object?>.from(decoded as Map),
      );
      final sourceMap = <String, InsightSourceReference>{
        for (final source in preflight.bundle.sources)
          source.sourceId: source.reference,
      };
      if (draft.sourceIds.any((id) => !sourceMap.containsKey(id))) {
        throw const FormatException('Unknown Tier 3 source reference.');
      }
      final sources = draft.sourceIds
          .map((id) => sourceMap[id]!)
          .toList(growable: false);
      final insight = ProactiveInsight(
        fingerprint: _fingerprint(
          providerId: profile.configuration.id,
          model: profile.configuration.defaultModel ?? profile.rateCard.model,
          draft: draft,
          sources: sources,
        ),
        kind: InsightKind.aiSynthesis,
        tier: InsightTier.tier3,
        severity: draft.severity,
        title: draft.title,
        body: draft.body,
        explanation: draft.explanation,
        evidenceAt: _clock().toUtc(),
        sources: sources,
      );
      return Tier3GenerationOutcome(
        kind: Tier3GenerationOutcomeKind.generated,
        preview: preflight,
        insight: insight,
      );
    } on Object {
      return Tier3GenerationOutcome(
        kind: Tier3GenerationOutcomeKind.invalidResponse,
        preview: preflight,
      );
    }
  }

  CostEstimate _estimate({
    required Tier3EvidenceBundle bundle,
    required ExtractionProviderProfile profile,
  }) {
    final estimatedInputTokens =
        ((bundle.totalCharacters + _promptOverheadCharacters) / 4).ceil();
    return _costEstimator.estimate(
      rateCard: profile.rateCard,
      inputTokens: estimatedInputTokens,
      outputTokens: profile.maxOutputTokens,
    );
  }

  String _fingerprint({
    required String providerId,
    required String model,
    required Tier3InsightDraft draft,
    required List<InsightSourceReference> sources,
  }) {
    final sourceKeys = sources.map((source) => source.stableKey).toList()
      ..sort();
    final value = [
      providerId,
      model,
      draft.title.trim(),
      draft.body.trim(),
      draft.explanation.trim(),
      draft.severity.name,
      ...sourceKeys,
    ].join('|');
    var hash = 0x811c9dc5;
    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return 'aiSynthesis|${hash.toRadixString(16).padLeft(8, '0')}';
  }
}
