import 'package:mindly/features/audio_capture/data/audio_recorder_gateway.dart';
import 'package:mindly/features/audio_capture/domain/audio_capture_models.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

AudioRecorderGateway createRecordAudioRecorder() => RecordAudioRecorderNative();

class RecordAudioRecorderNative implements AudioRecorderGateway {
  RecordAudioRecorderNative({AudioRecorder? recorder})
      : _recorder = recorder ?? AudioRecorder();

  static const config = RecordConfig(
    encoder: AudioEncoder.wav,
    sampleRate: 16000,
    numChannels: 1,
  );

  final AudioRecorder _recorder;
  DateTime? _startedAt;

  @override
  Future<bool> requestPermission() => _recorder.hasPermission();

  @override
  Future<void> start() async {
    final directory = await getTemporaryDirectory();
    final stamp = DateTime.now().toUtc().microsecondsSinceEpoch;
    final path = '${directory.path}/mindly-audio-$stamp.wav';
    await _recorder.start(config, path: path);
    _startedAt = DateTime.now().toUtc();
  }

  @override
  Future<AudioRecording?> stop() async {
    final path = await _recorder.stop();
    final startedAt = _startedAt;
    _startedAt = null;
    if (path == null || path.isEmpty) {
      return null;
    }
    final duration = startedAt == null
        ? Duration.zero
        : DateTime.now().toUtc().difference(startedAt);
    return AudioRecording(path: path, duration: duration);
  }

  @override
  Future<void> cancel() async {
    _startedAt = null;
    await _recorder.cancel();
  }

  @override
  Future<void> dispose() => _recorder.dispose();
}
