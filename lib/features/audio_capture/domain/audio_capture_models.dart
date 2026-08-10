import 'dart:typed_data';

import 'package:mindly/features/ai_settings/domain/cost_models.dart';
import 'package:mindly/features/text_capture/domain/text_capture_models.dart';

class AudioRecording {
  AudioRecording({
    required this.duration,
    this.path,
    Uint8List? bytes,
  }) : _bytes = bytes {
    if ((path == null || path!.isEmpty) && bytes == null) {
      throw ArgumentError('Audio recording requires a path or bytes.');
    }
  }

  final String? path;
  final Duration duration;
  Uint8List? _bytes;

  Uint8List? get bytes => _bytes;
  bool get hasBytes => _bytes != null && _bytes!.isNotEmpty;
  bool get hasPath => path != null && path!.isNotEmpty;

  void clearBytes() {
    final value = _bytes;
    if (value != null) {
      value.fillRange(0, value.length, 0);
      _bytes = null;
    }
  }
}

enum AudioProcessOutcomeKind {
  captured,
  webConsentRequired,
  nativeModelRequired,
  missingWebKey,
  spendBlocked,
  transcriptionFailed,
  emptyTranscript,
  handoffFailed,
}

class AudioProcessOutcome {
  const AudioProcessOutcome({
    required this.kind,
    this.transcript,
    this.estimate,
    this.spendBlockReason,
    this.textCaptureOutcome,
  });

  final AudioProcessOutcomeKind kind;
  final String? transcript;
  final CostEstimate? estimate;
  final SpendBlockReason? spendBlockReason;
  final TextCaptureOutcome? textCaptureOutcome;

  bool get isCaptured => kind == AudioProcessOutcomeKind.captured;
}

enum AudioCaptureStatus {
  idle,
  requestingPermission,
  permissionDenied,
  recording,
  recorded,
  downloadingModel,
  transcribing,
  complete,
  consentRequired,
  modelRequired,
  missingKey,
  spendBlocked,
  failed,
}
