import 'package:mindly/features/audio_capture/data/native_audio_transcriber.dart';

NativeAudioTranscriber createNativeWhisperTranscriber() =>
    UnsupportedNativeAudioTranscriber();

class UnsupportedNativeAudioTranscriber implements NativeAudioTranscriber {
  @override
  Future<bool> isModelReady() async => false;

  @override
  Future<void> downloadModel() {
    throw UnsupportedError('Native Whisper is not available on Web.');
  }

  @override
  Future<String> transcribe(String audioPath) {
    throw UnsupportedError('Native Whisper is not available on Web.');
  }
}
