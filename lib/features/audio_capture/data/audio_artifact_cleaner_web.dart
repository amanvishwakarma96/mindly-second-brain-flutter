import 'package:mindly/features/audio_capture/data/audio_artifact_cleaner.dart';
import 'package:mindly/features/audio_capture/domain/audio_capture_models.dart';

AudioArtifactCleaner createAudioArtifactCleaner() => WebAudioArtifactCleaner();

class WebAudioArtifactCleaner implements AudioArtifactCleaner {
  @override
  Future<void> delete(AudioRecording recording) async {
    recording.clearBytes();
  }
}
