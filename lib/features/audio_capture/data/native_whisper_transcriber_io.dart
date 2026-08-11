import 'dart:io';

import 'package:mindly/features/audio_capture/data/native_audio_transcriber.dart';
import 'package:whisper_ggml/whisper_ggml.dart';

NativeAudioTranscriber createNativeWhisperTranscriber() =>
    WhisperNativeAudioTranscriber();

class WhisperNativeAudioTranscriber implements NativeAudioTranscriber {
  WhisperNativeAudioTranscriber({WhisperController? controller})
    : _controller = controller ?? WhisperController();

  final WhisperController _controller;

  @override
  Future<bool> isModelReady() async {
    final modelPath = await _controller.getPath(WhisperModel.base);
    return File(modelPath).exists();
  }

  @override
  Future<void> downloadModel() async {
    await _controller.downloadModel(WhisperModel.base);
  }

  @override
  Future<String> transcribe(String audioPath) async {
    final result = await _controller.transcribe(
      model: WhisperModel.base,
      audioPath: audioPath,
      lang: 'auto',
    );
    return result?.transcription.text ?? '';
  }
}
