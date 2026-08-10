import 'dart:convert';

import 'package:mindly/features/ai_settings/application/cost_estimator.dart';
import 'package:mindly/features/ai_settings/application/provider_key_service.dart';
import 'package:mindly/features/ai_settings/application/spend_guard.dart';
import 'package:mindly/features/ai_settings/data/secure_spend_store.dart';
import 'package:mindly/features/ai_settings/domain/cost_models.dart';
import 'package:mindly/features/memory/data/memory_repository.dart';
import 'package:mindly/features/text_capture/data/ai_provider_transport.dart';
import 'package:mindly/features/text_capture/domain/memory_extraction.dart';
import 'package:mindly/features/text_capture/domain/text_capture_models.dart';

typedef CaptureClock = DateTime Function();
typedef CaptureIdFactory = String Function(DateTime now);

class TextCaptureService {
  factory TextCaptureService({
    required MemoryRepository memoryRepository,
    required ProviderKeyService keyService,
    required SpendCapsRepository capsRepository,
    required SpendLedger spendLedger,
    required SpendGuard spendGuard,
    required CostEstimator costEstimator,
    required AiProviderTransport transport,
    CaptureClock? clock,
    CaptureIdFactory? idFactory,
  }) {
    return TextCaptureService._(
      memoryRepository,
      keyService,
      capsRepository,
      spendLedger,
      spendGuard,
      costEstimator,
      transport,
      clock ?? DateTime.now,
      idFactory ?? _defaultId,
    );
  }

  TextCaptureService._(
    this._memoryRepository,
    this._keyService,
    this._capsRepository,
    this._spendLedger,
    this._spendGuard,
    this._costEstimator,
    this._transport,
    this._clock,
    this._idFactory,
  );

  static const _promptOverheadCharacters = 1200;

  final MemoryRepository _memoryRepository;
  final ProviderKeyService _keyService;
  final SpendCapsRepository _capsRepository;
  final SpendLedger _spendLedger;
  final SpendGuard _spendGuard;
  final CostEstimator _costEstimator;
  final AiProviderTransport _transport;
  final CaptureClock _clock;
  final CaptureIdFactory _idFactory;

  CostEstimate estimate({
    required String text,
    required ExtractionProviderProfile profile,
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(text, 'text', 'Capture text cannot be empty.');
    }
    final estimatedInputTokens =
        ((trimmed.runes.length + _promptOverheadCharacters) / 4).ceil();
    return _costEstimator.estimate(
      rateCard: profile.rateCard,
      inputTokens: estimatedInputTokens,
      outputTokens: profile.maxOutputTokens,
    );
  }

  Future<TextCaptureOutcome> captureAndExtract({
    required String text,
    required ExtractionProviderProfile profile,
  }) async {
    final sourceText = text.trim();
    if (sourceText.isEmpty) {
      throw ArgumentError.value(text, 'text', 'Capture text cannot be empty.');
    }

    final now = _clock().toUtc();
    final captureId = _idFactory(now);
    final preflightEstimate = estimate(text: sourceText, profile: profile);

    await _memoryRepository.saveCapture(
      id: captureId,
      mode: 'text',
      context: ExtractionContext.ambiguous.name,
      rawText: sourceText,
      createdAt: now,
    );

    final apiKey = await _keyService.readKey(profile.configuration.id);
    if (apiKey == null || apiKey.trim().isEmpty) {
      return TextCaptureOutcome(
        kind: TextCaptureOutcomeKind.savedMissingKey,
        captureId: captureId,
        estimate: preflightEstimate,
      );
    }

    final caps = await _capsRepository.load();
    final decision = await _spendGuard.evaluate(
      estimate: preflightEstimate,
      caps: caps,
      now: now,
    );
    if (!decision.isAllowed) {
      return TextCaptureOutcome(
        kind: TextCaptureOutcomeKind.savedSpendBlocked,
        captureId: captureId,
        estimate: preflightEstimate,
        spendBlockReason: decision.blockReason,
      );
    }

    AiProviderResponse response;
    try {
      response = await _transport.extract(
        profile: profile,
        apiKey: apiKey,
        captureId: captureId,
        text: sourceText,
      );
    } on Object {
      return TextCaptureOutcome(
        kind: TextCaptureOutcomeKind.savedProviderFailure,
        captureId: captureId,
        estimate: preflightEstimate,
      );
    }

    final billedEstimate = _costEstimator.estimate(
      rateCard: profile.rateCard,
      inputTokens: response.inputTokens ?? preflightEstimate.inputTokens,
      outputTokens: response.outputTokens ?? preflightEstimate.outputTokens,
    );
    await _spendLedger.record(
      SpendEntry(at: now, usd: billedEstimate.estimatedUsd),
    );

    MemoryExtraction extraction;
    try {
      final decoded = jsonDecode(response.outputText);
      extraction = MemoryExtraction.fromJson(
        Map<String, Object?>.from(decoded as Map),
        expectedCaptureId: captureId,
      );
    } on Object {
      return TextCaptureOutcome(
        kind: TextCaptureOutcomeKind.savedInvalidExtraction,
        captureId: captureId,
        estimate: preflightEstimate,
      );
    }

    await _persistExtraction(
      extraction: extraction,
      sourceText: sourceText,
      createdAt: now,
    );

    return TextCaptureOutcome(
      kind: TextCaptureOutcomeKind.extracted,
      captureId: captureId,
      estimate: preflightEstimate,
      extraction: extraction,
    );
  }

  Future<void> classifyCapture({
    required String captureId,
    required ExtractionContext context,
  }) {
    if (context == ExtractionContext.ambiguous) {
      throw ArgumentError.value(
        context,
        'context',
        'Choose work or personal for manual classification.',
      );
    }
    return _memoryRepository.updateCaptureContext(
      id: captureId,
      context: context.name,
    );
  }

  Future<void> _persistExtraction({
    required MemoryExtraction extraction,
    required String sourceText,
    required DateTime createdAt,
  }) async {
    await _memoryRepository.saveCapture(
      id: extraction.captureId,
      mode: 'text',
      context: extraction.context.name,
      rawText: sourceText,
      summary: extraction.summary,
      createdAt: createdAt,
    );

    for (final person in extraction.people) {
      final personId = _entityId('person', person);
      await _memoryRepository.savePerson(id: personId, displayName: person);
      await _memoryRepository.link(
        id: 'rel_${extraction.captureId}_$personId',
        fromType: 'person',
        fromId: personId,
        relationType: 'mentioned_in',
        toType: 'capture',
        toId: extraction.captureId,
      );
    }

    for (final topic in extraction.topics) {
      final topicId = _entityId('topic', topic);
      await _memoryRepository.saveTopic(id: topicId, label: topic);
      await _memoryRepository.link(
        id: 'rel_${extraction.captureId}_$topicId',
        fromType: 'topic',
        fromId: topicId,
        relationType: 'mentioned_in',
        toType: 'capture',
        toId: extraction.captureId,
      );
    }

    for (var index = 0; index < extraction.commitments.length; index += 1) {
      final commitmentId = 'commitment_${extraction.captureId}_$index';
      await _memoryRepository.saveCommitment(
        id: commitmentId,
        text: extraction.commitments[index],
        captureId: extraction.captureId,
      );
      await _memoryRepository.link(
        id: 'rel_${extraction.captureId}_$commitmentId',
        fromType: 'commitment',
        fromId: commitmentId,
        relationType: 'related_to',
        toType: 'capture',
        toId: extraction.captureId,
      );
    }
  }

  static String _defaultId(DateTime now) {
    return 'capture_${now.toUtc().microsecondsSinceEpoch.toRadixString(36)}';
  }

  String _entityId(String prefix, String value) {
    var hash = 0x811c9dc5;
    for (final codeUnit in value.trim().toLowerCase().codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return '${prefix}_${hash.toRadixString(16).padLeft(8, '0')}';
  }
}
