import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindly/app/app_routes.dart';
import 'package:mindly/app/mindly_app.dart';
import 'package:mindly/app/platform/screen_family.dart';
import 'package:mindly/features/audio_capture/application/audio_capture_controller.dart';
import 'package:mindly/features/audio_capture/application/audio_transcription_service.dart';
import 'package:mindly/features/audio_capture/data/audio_recorder_gateway.dart';
import 'package:mindly/features/audio_capture/domain/audio_capture_models.dart';
import 'package:mindly/features/text_capture/domain/text_capture_models.dart';
import 'package:mindly/screens/desktop/capture/desktop_audio_capture_screen.dart';
import 'package:mindly/screens/mobile/capture/mobile_audio_capture_screen.dart';
import 'package:mindly/screens/web/capture/web_audio_capture_screen.dart';

void main() {
  for (final entry in <ScreenFamily, Key>{
    ScreenFamily.mobile: MobileAudioCaptureScreen.screenKey,
    ScreenFamily.desktop: DesktopAudioCaptureScreen.screenKey,
    ScreenFamily.web: WebAudioCaptureScreen.screenKey,
  }.entries) {
    testWidgets('${entry.key.name} routes to its own audio capture screen', (
      tester,
    ) async {
      final controller = AudioCaptureController(
        recorder: _NoopRecorder(),
        transcriptionService: _NoopTranscriptionGateway(),
        isWeb: entry.key == ScreenFamily.web,
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MindlyApp(
          screenFamilyOverride: entry.key,
          audioCaptureControllerOverride: controller,
        ),
      );
      Navigator.of(
        tester.element(find.byType(Scaffold).first),
      ).pushNamed(AppRoutes.audioCapture);
      await tester.pumpAndSettle();

      expect(find.byKey(entry.value), findsOneWidget);
      final otherKeys = <Key>{
        MobileAudioCaptureScreen.screenKey,
        DesktopAudioCaptureScreen.screenKey,
        WebAudioCaptureScreen.screenKey,
      }..remove(entry.value);
      for (final key in otherKeys) {
        expect(find.byKey(key), findsNothing);
      }
    });
  }
}

class _NoopRecorder implements AudioRecorderGateway {
  @override
  Future<void> cancel() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> start() async {}

  @override
  Future<AudioRecording?> stop() async => null;
}

class _NoopTranscriptionGateway implements AudioTranscriptionGateway {
  @override
  Future<void> downloadNativeModel() async {}

  @override
  Future<bool> isNativeModelReady() async => false;

  @override
  Future<AudioProcessOutcome> transcribeAndCapture({
    required AudioRecording recording,
    required ExtractionProviderProfile extractionProfile,
    required bool webCloudConsent,
    required bool deleteAfterTranscription,
  }) async {
    return const AudioProcessOutcome(
      kind: AudioProcessOutcomeKind.transcriptionFailed,
    );
  }
}
