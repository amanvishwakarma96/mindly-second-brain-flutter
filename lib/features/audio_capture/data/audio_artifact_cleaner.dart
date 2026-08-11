import 'package:mindly/features/audio_capture/domain/audio_capture_models.dart';

abstract interface class AudioArtifactCleaner {
  Future<void> delete(AudioRecording recording);
}
