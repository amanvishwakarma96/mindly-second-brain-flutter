import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mindly/features/ai_settings/application/provider_key_service.dart';
import 'package:mindly/features/ai_settings/application/spend_guard.dart';
import 'package:mindly/features/ai_settings/data/provider_key_repository.dart';
import 'package:mindly/features/ai_settings/data/secure_spend_store.dart';
import 'package:mindly/features/ai_settings/domain/cost_models.dart';
import 'package:mindly/features/audio_capture/application/audio_cost_estimator.dart';
import 'package:mindly/features/audio_capture/application/audio_transcription_service.dart';
import 'package:mindly/features/audio_capture/data/audio_artifact_cleaner.dart';
import 'package:mindly/features/audio_capture/data/native_audio_transcriber.dart';
import 'package:mindly/features/audio_capture/data/openai_cloud_audio_transcriber.dart';
import 'package:mindly/features/audio_capture/domain/audio_capture_models.dart';
import 'package:mindly/features/text_capture/domain/text_capture_models.dart';

import '../../helpers/in_memory_secret_store.dart';

void main() {
  const profile = ExtractionProviderProfile.openAiDefault;

  test(
    'native transcription stops when the Whisper model is missing',
    () async {
      final fixture = _Fixture(
        isWeb: false,
        modelReady: false,
        nativeText: 'hello',
      );

      final outcome = await fixture.service.transcribeAndCapture(
        recording: AudioRecording(
          path: '/tmp/mindly.wav',
          duration: const Duration(seconds: 5),
        ),
        extractionProfile: profile,
        webCloudConsent: false,
        deleteAfterTranscription: true,
      );

      expect(outcome.kind, AudioProcessOutcomeKind.nativeModelRequired);
      expect(fixture.native.transcribeCalls, 0);
      expect(fixture.handoffTexts, isEmpty);
      expect(fixture.cleaner.deleted, isEmpty);
    },
  );

  test(
    'native transcript is handed to text capture before raw audio deletion',
    () async {
      final fixture = _Fixture(
        isWeb: false,
        modelReady: true,
        nativeText: '  Exact native transcript.  ',
      );
      final recording = AudioRecording(
        path: '/tmp/mindly.wav',
        duration: const Duration(seconds: 8),
      );

      final outcome = await fixture.service.transcribeAndCapture(
        recording: recording,
        extractionProfile: profile,
        webCloudConsent: false,
        deleteAfterTranscription: true,
      );

      expect(outcome.kind, AudioProcessOutcomeKind.captured);
      expect(outcome.transcript, '  Exact native transcript.  ');
      expect(fixture.handoffTexts, ['  Exact native transcript.  ']);
      expect(fixture.cleaner.deleted, [recording]);
    },
  );

  test('Web requires explicit cloud consent before dispatch', () async {
    final fixture = _Fixture(isWeb: true, cloudText: 'web transcript');
    await fixture.saveOpenAiKey();

    final outcome = await fixture.service.transcribeAndCapture(
      recording: _webRecording(),
      extractionProfile: profile,
      webCloudConsent: false,
      deleteAfterTranscription: false,
    );

    expect(outcome.kind, AudioProcessOutcomeKind.webConsentRequired);
    expect(fixture.cloud.calls, 0);
    expect(fixture.spend.entries, isEmpty);
  });

  test('Web keeps recording retryable when OpenAI key is missing', () async {
    final fixture = _Fixture(isWeb: true, cloudText: 'web transcript');

    final outcome = await fixture.service.transcribeAndCapture(
      recording: _webRecording(),
      extractionProfile: profile,
      webCloudConsent: true,
      deleteAfterTranscription: true,
    );

    expect(outcome.kind, AudioProcessOutcomeKind.missingWebKey);
    expect(fixture.cloud.calls, 0);
    expect(fixture.cleaner.deleted, isEmpty);
  });

  test('Web spend cap blocks provider dispatch', () async {
    final fixture = _Fixture(
      isWeb: true,
      cloudText: 'web transcript',
      caps: const SpendCaps(dailyUsd: 0.000001),
    );
    await fixture.saveOpenAiKey();

    final outcome = await fixture.service.transcribeAndCapture(
      recording: _webRecording(duration: const Duration(minutes: 2)),
      extractionProfile: profile,
      webCloudConsent: true,
      deleteAfterTranscription: false,
    );

    expect(outcome.kind, AudioProcessOutcomeKind.spendBlocked);
    expect(outcome.spendBlockReason, SpendBlockReason.dailyCap);
    expect(fixture.cloud.calls, 0);
  });

  test(
    'successful Web transcription records estimated spend and handoff',
    () async {
      final fixture = _Fixture(isWeb: true, cloudText: 'web transcript');
      await fixture.saveOpenAiKey();

      final outcome = await fixture.service.transcribeAndCapture(
        recording: _webRecording(duration: const Duration(minutes: 1)),
        extractionProfile: profile,
        webCloudConsent: true,
        deleteAfterTranscription: false,
      );

      expect(outcome.kind, AudioProcessOutcomeKind.captured);
      expect(fixture.cloud.calls, 1);
      expect(fixture.cloud.lastKey, 'sk-phase4-test');
      expect(fixture.handoffTexts, ['web transcript']);
      expect(fixture.spend.entries, hasLength(1));
      expect(
        fixture.spend.entries.single.usd,
        closeTo(AudioCostEstimator.estimatedUsdPerMinute, 0.0000001),
      );
    },
  );

  test('provider failure never deletes retryable Web audio', () async {
    final fixture = _Fixture(isWeb: true, cloudShouldFail: true);
    await fixture.saveOpenAiKey();

    final outcome = await fixture.service.transcribeAndCapture(
      recording: _webRecording(),
      extractionProfile: profile,
      webCloudConsent: true,
      deleteAfterTranscription: true,
    );

    expect(outcome.kind, AudioProcessOutcomeKind.transcriptionFailed);
    expect(fixture.cleaner.deleted, isEmpty);
    expect(fixture.handoffTexts, isEmpty);
  });

  test('empty transcription is rejected before text extraction', () async {
    final fixture = _Fixture(isWeb: false, modelReady: true, nativeText: '   ');

    final outcome = await fixture.service.transcribeAndCapture(
      recording: AudioRecording(
        path: '/tmp/mindly.wav',
        duration: const Duration(seconds: 3),
      ),
      extractionProfile: profile,
      webCloudConsent: false,
      deleteAfterTranscription: true,
    );

    expect(outcome.kind, AudioProcessOutcomeKind.emptyTranscript);
    expect(fixture.handoffTexts, isEmpty);
    expect(fixture.cleaner.deleted, isEmpty);
  });
}

AudioRecording _webRecording({
  Duration duration = const Duration(seconds: 10),
}) {
  return AudioRecording(
    bytes: Uint8List.fromList([82, 73, 70, 70, 1, 2, 3, 4]),
    duration: duration,
  );
}

class _Fixture {
  _Fixture({
    required bool isWeb,
    bool modelReady = true,
    String nativeText = '',
    String cloudText = '',
    bool cloudShouldFail = false,
    SpendCaps caps = const SpendCaps(),
  }) : spend = _SpendStore(caps),
       native = _FakeNative(modelReady: modelReady, text: nativeText),
       cloud = _FakeCloud(text: cloudText, shouldFail: cloudShouldFail),
       cleaner = _FakeCleaner() {
    keyService = ProviderKeyService(
      repository: ProviderKeyRepository(secretStore),
      isWeb: isWeb,
    );
    service = AudioTranscriptionService(
      isWeb: isWeb,
      nativeTranscriber: native,
      cloudTranscriber: cloud,
      keyService: keyService,
      capsRepository: spend,
      spendLedger: spend,
      spendGuard: SpendGuard(spend),
      costEstimator: const AudioCostEstimator(),
      artifactCleaner: cleaner,
      transcriptCaptureHandler: ({required text, required profile}) async {
        handoffTexts.add(text);
        return const TextCaptureOutcome(
          kind: TextCaptureOutcomeKind.extracted,
          captureId: 'capture-from-audio',
          estimate: CostEstimate(
            providerId: 'openai',
            model: 'test',
            inputTokens: 1,
            outputTokens: 1,
            estimatedUsd: 0.001,
          ),
        );
      },
      clock: () => DateTime.utc(2026, 8, 10, 12),
    );
  }

  final secretStore = InMemorySecretStore();
  final _SpendStore spend;
  final _FakeNative native;
  final _FakeCloud cloud;
  final _FakeCleaner cleaner;
  final List<String> handoffTexts = [];
  late final ProviderKeyService keyService;
  late final AudioTranscriptionService service;

  Future<void> saveOpenAiKey() {
    return keyService.saveKey(
      'openai',
      'sk-phase4-test',
      webRiskAccepted: true,
    );
  }
}

class _FakeNative implements NativeAudioTranscriber {
  _FakeNative({required this.modelReady, required this.text});

  bool modelReady;
  final String text;
  int transcribeCalls = 0;

  @override
  Future<void> downloadModel() async {
    modelReady = true;
  }

  @override
  Future<bool> isModelReady() async => modelReady;

  @override
  Future<String> transcribe(String audioPath) async {
    transcribeCalls += 1;
    return text;
  }
}

class _FakeCloud implements CloudAudioTranscriber {
  _FakeCloud({required this.text, required this.shouldFail});

  final String text;
  final bool shouldFail;
  int calls = 0;
  String? lastKey;

  @override
  Future<String> transcribe({
    required Uint8List wavBytes,
    required String apiKey,
  }) async {
    calls += 1;
    lastKey = apiKey;
    if (shouldFail) {
      throw const AudioProviderException(500);
    }
    return text;
  }
}

class _FakeCleaner implements AudioArtifactCleaner {
  final List<AudioRecording> deleted = [];

  @override
  Future<void> delete(AudioRecording recording) async {
    deleted.add(recording);
    recording.clearBytes();
  }
}

class _SpendStore implements SpendLedger, SpendCapsRepository {
  _SpendStore(this.caps);

  SpendCaps caps;
  final List<SpendEntry> entries = [];

  @override
  Future<List<SpendEntry>> entriesSince(DateTime startInclusive) async {
    return entries
        .where((entry) => !entry.at.isBefore(startInclusive))
        .toList(growable: false);
  }

  @override
  Future<SpendCaps> load() async => caps;

  @override
  Future<void> record(SpendEntry entry) async {
    entries.add(entry);
  }

  @override
  Future<void> save(SpendCaps caps) async {
    this.caps = caps;
  }
}
