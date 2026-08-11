abstract interface class NativeAudioTranscriber {
  Future<bool> isModelReady();

  Future<void> downloadModel();

  Future<String> transcribe(String audioPath);
}
