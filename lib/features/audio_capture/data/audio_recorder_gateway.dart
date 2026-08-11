import 'package:mindly/features/audio_capture/domain/audio_capture_models.dart';

abstract interface class AudioRecorderGateway {
  Future<bool> requestPermission();

  Future<void> start();

  Future<AudioRecording?> stop();

  Future<void> cancel();

  Future<void> dispose();
}
