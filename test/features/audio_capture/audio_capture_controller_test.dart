import 'package:flutter_test/flutter_test.dart';
import 'package:mindly/features/audio_capture/application/audio_capture_controller.dart';
import 'package:mindly/features/audio_capture/application/audio_transcription_service.dart';
import 'package:mindly/features/audio_capture/data/audio_recorder_gateway.dart';
import 'package:mindly/features/audio_capture/domain/audio_capture_models.dart';
import 'package:mindly/features/text_capture/domain/text_capture_models.dart';

void main() {
  test('permission denial never starts recording', () async {
    final recorder = _FakeRecorder(permissionGranted: false);
    final controller = AudioCaptureController(
      recorder: recorder,
      transcriptionService: _FakeTranscriptionGateway(),
      isWeb: false,
    );
    addTearDown(controller.dispose);

    await controller.startRecording();

    expect(controller.status, AudioCaptureStatus.permissionDenied);
    expect(recorder.startCalls, 0);
  });

  test('recording indicator state covers only active capture', () async {
    final recorder = _FakeRecorder(permissionGranted: true);
    final controller = AudioCaptureController(
      recorder: recorder,
      transcriptionService: _FakeTranscriptionGateway(),
      isWeb: false,
    );
    addTearDown(controller.dispose);

    await controller.startRecording();
    expect(controller.isRecording, isTrue);
    expect(controller.status, AudioCaptureStatus.recording);

    await controller.stopRecording();
    expect(controller.isRecording, isFalse);
    expect(controller.status, AudioCaptureStatus.recorded);
    expect(controller.recording, isNotNull);
  });

  test('cancel discards active capture and returns to idle', () async {
    final recorder = _FakeRecorder(permissionGranted: true);
    final controller = AudioCaptureController(
      recorder: recorder,
      transcriptionService: _FakeTranscriptionGateway(),
      isWeb: false,
    );
    addTearDown(controller.dispose);

    await controller.startRecording();
    await controller.cancelRecording();

    expect(recorder.cancelCalls, 1);
    expect(controller.recording, isNull);
    expect(controller.status, AudioCaptureStatus.idle);
  });
}

class _FakeRecorder implements AudioRecorderGateway {
  _FakeRecorder({required this.permissionGranted});

  final bool permissionGranted;
  int startCalls = 0;
  int cancelCalls = 0;

  @override
  Future<void> cancel() async {
    cancelCalls += 1;
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<bool> requestPermission() async => permissionGranted;

  @override
  Future<void> start() async {
    startCalls += 1;
  }

  @override
  Future<AudioRecording?> stop() async {
    return AudioRecording(
      path: '/tmp/controller-test.wav',
      duration: const Duration(seconds: 2),
    );
  }
}

class _FakeTranscriptionGateway implements AudioTranscriptionGateway {
  @override
  Future<void> downloadNativeModel() async {}

  @override
  Future<bool> isNativeModelReady() async => true;

  @override
  Future<AudioProcessOutcome> transcribeAndCapture({
    required AudioRecording recording,
    required ExtractionProviderProfile extractionProfile,
    required bool webCloudConsent,
    required bool deleteAfterTranscription,
  }) async {
    return const AudioProcessOutcome(kind: AudioProcessOutcomeKind.captured);
  }
}
