import 'dart:async';
import 'dart:typed_data';

import 'package:mindly/features/audio_capture/data/audio_recorder_gateway.dart';
import 'package:mindly/features/audio_capture/domain/audio_capture_models.dart';
import 'package:record/record.dart';

AudioRecorderGateway createRecordAudioRecorder() => RecordAudioRecorderWeb();

class RecordAudioRecorderWeb implements AudioRecorderGateway {
  RecordAudioRecorderWeb({AudioRecorder? recorder})
      : _recorder = recorder ?? AudioRecorder();

  static const config = RecordConfig(
    encoder: AudioEncoder.pcm16bits,
    sampleRate: 16000,
    numChannels: 1,
  );

  final AudioRecorder _recorder;
  BytesBuilder? _pcmBytes;
  StreamSubscription<Uint8List>? _subscription;
  Completer<void>? _streamDone;
  DateTime? _startedAt;

  @override
  Future<bool> requestPermission() => _recorder.hasPermission();

  @override
  Future<void> start() async {
    final stream = await _recorder.startStream(config);
    final builder = BytesBuilder(copy: false);
    final done = Completer<void>();
    _pcmBytes = builder;
    _streamDone = done;
    _subscription = stream.listen(
      builder.add,
      onDone: () {
        if (!done.isCompleted) {
          done.complete();
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!done.isCompleted) {
          done.completeError(error, stackTrace);
        }
      },
    );
    _startedAt = DateTime.now().toUtc();
  }

  @override
  Future<AudioRecording?> stop() async {
    await _recorder.stop();
    final done = _streamDone;
    if (done != null) {
      try {
        await done.future.timeout(const Duration(seconds: 1));
      } on TimeoutException {
        // Some browsers do not close the media stream synchronously on stop.
      }
    }
    await _subscription?.cancel();

    final builder = _pcmBytes;
    final startedAt = _startedAt;
    _resetSession();
    if (builder == null) {
      return null;
    }
    final pcm = builder.takeBytes();
    if (pcm.isEmpty) {
      return null;
    }
    final duration = startedAt == null
        ? Duration.zero
        : DateTime.now().toUtc().difference(startedAt);
    return AudioRecording(
      bytes: encodePcm16AsWav(pcm, sampleRate: 16000, channels: 1),
      duration: duration,
    );
  }

  @override
  Future<void> cancel() async {
    await _recorder.cancel();
    await _subscription?.cancel();
    final builder = _pcmBytes;
    if (builder != null) {
      final bytes = builder.takeBytes();
      bytes.fillRange(0, bytes.length, 0);
    }
    _resetSession();
  }

  void _resetSession() {
    _subscription = null;
    _streamDone = null;
    _pcmBytes = null;
    _startedAt = null;
  }

  @override
  Future<void> dispose() async {
    await _subscription?.cancel();
    await _recorder.dispose();
  }
}

Uint8List encodePcm16AsWav(
  Uint8List pcm, {
  required int sampleRate,
  required int channels,
}) {
  const bitsPerSample = 16;
  final byteRate = sampleRate * channels * bitsPerSample ~/ 8;
  final blockAlign = channels * bitsPerSample ~/ 8;
  final header = ByteData(44);

  void ascii(int offset, String value) {
    for (var index = 0; index < value.length; index += 1) {
      header.setUint8(offset + index, value.codeUnitAt(index));
    }
  }

  ascii(0, 'RIFF');
  header.setUint32(4, 36 + pcm.length, Endian.little);
  ascii(8, 'WAVE');
  ascii(12, 'fmt ');
  header.setUint32(16, 16, Endian.little);
  header.setUint16(20, 1, Endian.little);
  header.setUint16(22, channels, Endian.little);
  header.setUint32(24, sampleRate, Endian.little);
  header.setUint32(28, byteRate, Endian.little);
  header.setUint16(32, blockAlign, Endian.little);
  header.setUint16(34, bitsPerSample, Endian.little);
  ascii(36, 'data');
  header.setUint32(40, pcm.length, Endian.little);

  final output = Uint8List(44 + pcm.length);
  output.setRange(0, 44, header.buffer.asUint8List());
  output.setRange(44, output.length, pcm);
  return output;
}
