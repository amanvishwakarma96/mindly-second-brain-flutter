import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mindly/core/security/flutter_secure_secret_store.dart';
import 'package:mindly/features/ai_settings/application/provider_key_service.dart';
import 'package:mindly/features/ai_settings/application/spend_guard.dart';
import 'package:mindly/features/ai_settings/data/provider_key_repository.dart';
import 'package:mindly/features/ai_settings/data/secure_spend_store.dart';
import 'package:mindly/features/audio_capture/application/audio_cost_estimator.dart';
import 'package:mindly/features/audio_capture/application/audio_transcription_service.dart';
import 'package:mindly/features/audio_capture/data/audio_artifact_cleaner_factory.dart';
import 'package:mindly/features/audio_capture/data/audio_recorder_gateway.dart';
import 'package:mindly/features/audio_capture/data/native_whisper_transcriber.dart';
import 'package:mindly/features/audio_capture/data/openai_cloud_audio_transcriber.dart';
import 'package:mindly/features/audio_capture/data/record_audio_recorder.dart';
import 'package:mindly/features/audio_capture/domain/audio_capture_models.dart';
import 'package:mindly/features/text_capture/application/text_capture_controller.dart';
import 'package:mindly/features/text_capture/domain/text_capture_models.dart';

class AudioCaptureController extends ChangeNotifier {
  AudioCaptureController({
    required AudioRecorderGateway recorder,
    required AudioTranscriptionGateway transcriptionService,
    required this.isWeb,
  }) : _recorder = recorder,
       _transcriptionService = transcriptionService;

  factory AudioCaptureController.production() {
    final store = FlutterSecureSecretStore();
    final spendStore = SecureSpendStore(store);
    final keyService = ProviderKeyService(
      repository: ProviderKeyRepository(store),
      isWeb: kIsWeb,
    );
    final textController = TextCaptureController.production();
    final transcriptionService = AudioTranscriptionService(
      isWeb: kIsWeb,
      nativeTranscriber: createNativeWhisperTranscriber(),
      cloudTranscriber: OpenAiCloudAudioTranscriber(http.Client()),
      keyService: keyService,
      capsRepository: spendStore,
      spendLedger: spendStore,
      spendGuard: SpendGuard(spendStore),
      costEstimator: const AudioCostEstimator(),
      artifactCleaner: createAudioArtifactCleaner(),
      transcriptCaptureHandler: textController.capture,
    );
    return AudioCaptureController(
      recorder: createRecordAudioRecorder(),
      transcriptionService: transcriptionService,
      isWeb: kIsWeb,
    );
  }

  final AudioRecorderGateway _recorder;
  final AudioTranscriptionGateway _transcriptionService;
  final bool isWeb;

  AudioCaptureStatus _status = AudioCaptureStatus.idle;
  AudioRecording? _recording;
  AudioProcessOutcome? _lastOutcome;
  String? _errorMessage;

  AudioCaptureStatus get status => _status;
  AudioRecording? get recording => _recording;
  AudioProcessOutcome? get lastOutcome => _lastOutcome;
  String? get errorMessage => _errorMessage;
  bool get isRecording => _status == AudioCaptureStatus.recording;
  bool get canTranscribe => _recording != null && !isRecording;

  Future<void> startRecording() async {
    _errorMessage = null;
    _lastOutcome = null;
    _recording = null;
    _setStatus(AudioCaptureStatus.requestingPermission);
    try {
      if (!await _recorder.requestPermission()) {
        _setStatus(AudioCaptureStatus.permissionDenied);
        return;
      }
      await _recorder.start();
      _setStatus(AudioCaptureStatus.recording);
    } on Object {
      _errorMessage = 'Microphone capture could not start.';
      _setStatus(AudioCaptureStatus.failed);
    }
  }

  Future<void> stopRecording() async {
    if (!isRecording) {
      return;
    }
    try {
      final result = await _recorder.stop();
      if (result == null) {
        _errorMessage = 'No audio was captured.';
        _setStatus(AudioCaptureStatus.failed);
        return;
      }
      _recording = result;
      _setStatus(AudioCaptureStatus.recorded);
    } on Object {
      _errorMessage = 'Recording could not be finalized.';
      _setStatus(AudioCaptureStatus.failed);
    }
  }

  Future<void> cancelRecording() async {
    try {
      await _recorder.cancel();
    } on Object {
      // Cancellation remains best-effort; the UI still leaves recording mode.
    }
    _recording = null;
    _lastOutcome = null;
    _errorMessage = null;
    _setStatus(AudioCaptureStatus.idle);
  }

  Future<void> downloadNativeModel() async {
    if (isWeb) {
      return;
    }
    _errorMessage = null;
    _setStatus(AudioCaptureStatus.downloadingModel);
    try {
      await _transcriptionService.downloadNativeModel();
      _setStatus(_recording == null ? AudioCaptureStatus.idle : AudioCaptureStatus.recorded);
    } on Object {
      _errorMessage = 'The local transcription model could not be downloaded.';
      _setStatus(AudioCaptureStatus.failed);
    }
  }

  Future<bool> isNativeModelReady() =>
      _transcriptionService.isNativeModelReady();

  Future<void> transcribeAndCapture({
    required ExtractionProviderProfile extractionProfile,
    required bool webCloudConsent,
    required bool deleteAfterTranscription,
  }) async {
    final current = _recording;
    if (current == null) {
      return;
    }
    _errorMessage = null;
    _setStatus(AudioCaptureStatus.transcribing);
    final outcome = await _transcriptionService.transcribeAndCapture(
      recording: current,
      extractionProfile: extractionProfile,
      webCloudConsent: webCloudConsent,
      deleteAfterTranscription: deleteAfterTranscription,
    );
    _lastOutcome = outcome;
    _setStatus(switch (outcome.kind) {
      AudioProcessOutcomeKind.captured => AudioCaptureStatus.complete,
      AudioProcessOutcomeKind.webConsentRequired =>
        AudioCaptureStatus.consentRequired,
      AudioProcessOutcomeKind.nativeModelRequired =>
        AudioCaptureStatus.modelRequired,
      AudioProcessOutcomeKind.missingWebKey => AudioCaptureStatus.missingKey,
      AudioProcessOutcomeKind.spendBlocked => AudioCaptureStatus.spendBlocked,
      AudioProcessOutcomeKind.transcriptionFailed ||
      AudioProcessOutcomeKind.emptyTranscript ||
      AudioProcessOutcomeKind.handoffFailed => AudioCaptureStatus.failed,
    });
  }

  void _setStatus(AudioCaptureStatus value) {
    _status = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }
}
