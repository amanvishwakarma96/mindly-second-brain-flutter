import 'package:mindly/features/ai_settings/application/provider_key_service.dart';
import 'package:mindly/features/ai_settings/application/spend_guard.dart';
import 'package:mindly/features/ai_settings/data/secure_spend_store.dart';
import 'package:mindly/features/ai_settings/domain/cost_models.dart';
import 'package:mindly/features/audio_capture/application/audio_cost_estimator.dart';
import 'package:mindly/features/audio_capture/data/audio_artifact_cleaner.dart';
import 'package:mindly/features/audio_capture/data/native_audio_transcriber.dart';
import 'package:mindly/features/audio_capture/data/openai_cloud_audio_transcriber.dart';
import 'package:mindly/features/audio_capture/domain/audio_capture_models.dart';
import 'package:mindly/features/text_capture/domain/text_capture_models.dart';

typedef TranscriptCaptureHandler =
    Future<TextCaptureOutcome> Function({
      required String text,
      required ExtractionProviderProfile profile,
    });

abstract interface class AudioTranscriptionGateway {
  Future<bool> isNativeModelReady();

  Future<void> downloadNativeModel();

  Future<AudioProcessOutcome> transcribeAndCapture({
    required AudioRecording recording,
    required ExtractionProviderProfile extractionProfile,
    required bool webCloudConsent,
    required bool deleteAfterTranscription,
  });
}

class AudioTranscriptionService implements AudioTranscriptionGateway {
  AudioTranscriptionService({
    required bool isWeb,
    required NativeAudioTranscriber nativeTranscriber,
    required CloudAudioTranscriber cloudTranscriber,
    required ProviderKeyService keyService,
    required SpendCapsRepository capsRepository,
    required SpendLedger spendLedger,
    required SpendGuard spendGuard,
    required AudioCostEstimator costEstimator,
    required AudioArtifactCleaner artifactCleaner,
    required TranscriptCaptureHandler transcriptCaptureHandler,
    DateTime Function()? clock,
  }) : this._(
         isWeb,
         nativeTranscriber,
         cloudTranscriber,
         keyService,
         capsRepository,
         spendLedger,
         spendGuard,
         costEstimator,
         artifactCleaner,
         transcriptCaptureHandler,
         clock ?? DateTime.now,
       );

  AudioTranscriptionService._(
    this.isWeb,
    this._nativeTranscriber,
    this._cloudTranscriber,
    this._keyService,
    this._capsRepository,
    this._spendLedger,
    this._spendGuard,
    this._costEstimator,
    this._artifactCleaner,
    this._transcriptCaptureHandler,
    this._clock,
  );

  final bool isWeb;
  final NativeAudioTranscriber _nativeTranscriber;
  final CloudAudioTranscriber _cloudTranscriber;
  final ProviderKeyService _keyService;
  final SpendCapsRepository _capsRepository;
  final SpendLedger _spendLedger;
  final SpendGuard _spendGuard;
  final AudioCostEstimator _costEstimator;
  final AudioArtifactCleaner _artifactCleaner;
  final TranscriptCaptureHandler _transcriptCaptureHandler;
  final DateTime Function() _clock;

  @override
  Future<bool> isNativeModelReady() {
    if (isWeb) {
      return Future<bool>.value(false);
    }
    return _nativeTranscriber.isModelReady();
  }

  @override
  Future<void> downloadNativeModel() {
    if (isWeb) {
      throw UnsupportedError(
        'Native transcription models are unavailable on Web.',
      );
    }
    return _nativeTranscriber.downloadModel();
  }

  @override
  Future<AudioProcessOutcome> transcribeAndCapture({
    required AudioRecording recording,
    required ExtractionProviderProfile extractionProfile,
    required bool webCloudConsent,
    required bool deleteAfterTranscription,
  }) async {
    String transcript;
    CostEstimate? estimate;

    if (isWeb) {
      if (!webCloudConsent) {
        return const AudioProcessOutcome(
          kind: AudioProcessOutcomeKind.webConsentRequired,
        );
      }
      final bytes = recording.bytes;
      if (bytes == null || bytes.isEmpty) {
        return const AudioProcessOutcome(
          kind: AudioProcessOutcomeKind.transcriptionFailed,
        );
      }

      final apiKey = await _keyService.readKey('openai');
      if (apiKey == null || apiKey.trim().isEmpty) {
        return const AudioProcessOutcome(
          kind: AudioProcessOutcomeKind.missingWebKey,
        );
      }

      estimate = _costEstimator.estimate(recording.duration);
      final now = _clock().toUtc();
      final caps = await _capsRepository.load();
      final decision = await _spendGuard.evaluate(
        estimate: estimate,
        caps: caps,
        now: now,
      );
      if (!decision.isAllowed) {
        return AudioProcessOutcome(
          kind: AudioProcessOutcomeKind.spendBlocked,
          estimate: estimate,
          spendBlockReason: decision.blockReason,
        );
      }

      try {
        transcript = await _cloudTranscriber.transcribe(
          wavBytes: bytes,
          apiKey: apiKey,
        );
      } on Object {
        return AudioProcessOutcome(
          kind: AudioProcessOutcomeKind.transcriptionFailed,
          estimate: estimate,
        );
      }
      await _spendLedger.record(
        SpendEntry(at: now, usd: estimate.estimatedUsd),
      );
    } else {
      if (!await _nativeTranscriber.isModelReady()) {
        return const AudioProcessOutcome(
          kind: AudioProcessOutcomeKind.nativeModelRequired,
        );
      }
      final path = recording.path;
      if (path == null || path.isEmpty) {
        return const AudioProcessOutcome(
          kind: AudioProcessOutcomeKind.transcriptionFailed,
        );
      }
      try {
        transcript = await _nativeTranscriber.transcribe(path);
      } on Object {
        return const AudioProcessOutcome(
          kind: AudioProcessOutcomeKind.transcriptionFailed,
        );
      }
    }

    if (transcript.trim().isEmpty) {
      return AudioProcessOutcome(
        kind: AudioProcessOutcomeKind.emptyTranscript,
        transcript: transcript,
        estimate: estimate,
      );
    }

    TextCaptureOutcome textOutcome;
    try {
      textOutcome = await _transcriptCaptureHandler(
        text: transcript,
        profile: extractionProfile,
      );
    } on Object {
      return AudioProcessOutcome(
        kind: AudioProcessOutcomeKind.handoffFailed,
        transcript: transcript,
        estimate: estimate,
      );
    }

    if (deleteAfterTranscription) {
      await _artifactCleaner.delete(recording);
    }

    return AudioProcessOutcome(
      kind: AudioProcessOutcomeKind.captured,
      transcript: transcript,
      estimate: estimate,
      textCaptureOutcome: textOutcome,
    );
  }
}
