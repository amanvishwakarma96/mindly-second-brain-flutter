import 'dart:io';

import 'package:mindly/features/audio_capture/data/audio_artifact_cleaner.dart';
import 'package:mindly/features/audio_capture/domain/audio_capture_models.dart';

AudioArtifactCleaner createAudioArtifactCleaner() => IoAudioArtifactCleaner();

class IoAudioArtifactCleaner implements AudioArtifactCleaner {
  @override
  Future<void> delete(AudioRecording recording) async {
    recording.clearBytes();
    final path = recording.path;
    if (path == null || path.isEmpty) {
      return;
    }
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
