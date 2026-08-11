import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('native recorder stays on 16 kHz mono WAV', () {
    final source = File(
      'lib/features/audio_capture/data/record_audio_recorder_native.dart',
    ).readAsStringSync();

    expect(source, contains('AudioEncoder.wav'));
    expect(source, contains('sampleRate: 16000'));
    expect(source, contains('numChannels: 1'));
  });

  test('Web recorder stays on 16 kHz mono PCM with WAV packaging', () {
    final source = File(
      'lib/features/audio_capture/data/record_audio_recorder_web.dart',
    ).readAsStringSync();

    expect(source, contains('AudioEncoder.pcm16bits'));
    expect(source, contains('sampleRate: 16000'));
    expect(source, contains('numChannels: 1'));
    expect(source, contains('encodePcm16AsWav'));
  });
}
