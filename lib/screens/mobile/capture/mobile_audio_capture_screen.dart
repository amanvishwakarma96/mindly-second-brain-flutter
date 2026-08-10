import 'package:flutter/material.dart';
import 'package:mindly/features/audio_capture/application/audio_capture_controller.dart';
import 'package:mindly/features/audio_capture/domain/audio_capture_models.dart';
import 'package:mindly/features/text_capture/domain/text_capture_models.dart';
import 'package:mindly/shared/design_tokens/mindly_spacing.dart';

class MobileAudioCaptureScreen extends StatefulWidget {
  const MobileAudioCaptureScreen({super.key, this.controller});

  static const screenKey = ValueKey<String>('screen-mobile-audio-capture');
  final AudioCaptureController? controller;

  @override
  State<MobileAudioCaptureScreen> createState() =>
      _MobileAudioCaptureScreenState();
}

class _MobileAudioCaptureScreenState extends State<MobileAudioCaptureScreen> {
  late final AudioCaptureController _controller;
  late final bool _ownsController;
  bool _deleteAfterTranscription = true;
  bool _webConsent = false;
  ExtractionProviderProfile _profile = ExtractionProviderProfile.openAiDefault;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? AudioCaptureController.production();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: MobileAudioCaptureScreen.screenKey,
      appBar: AppBar(title: const Text('Audio capture')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(MindlySpacing.lg),
          children: [
            Center(
              child: Icon(
                _controller.isRecording
                    ? Icons.mic_rounded
                    : Icons.mic_none_rounded,
                size: 72,
              ),
            ),
            const SizedBox(height: MindlySpacing.md),
            Center(
              child: Text(
                _statusText(_controller.status),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (_controller.errorMessage case final message?) ...[
              const SizedBox(height: MindlySpacing.sm),
              Text(message, textAlign: TextAlign.center),
            ],
            const SizedBox(height: MindlySpacing.xl),
            if (_controller.isRecording) ...[
              FilledButton.icon(
                onPressed: _controller.stopRecording,
                icon: const Icon(Icons.stop_rounded),
                label: const Text('Stop recording'),
              ),
              TextButton(
                onPressed: _controller.cancelRecording,
                child: const Text('Cancel and discard'),
              ),
            ] else ...[
              FilledButton.icon(
                onPressed: _controller.status == AudioCaptureStatus.transcribing
                    ? null
                    : _controller.startRecording,
                icon: const Icon(Icons.mic_rounded),
                label: Text(
                  _controller.recording == null
                      ? 'Start recording'
                      : 'Record again',
                ),
              ),
            ],
            if (!_controller.isWeb) ...[
              const SizedBox(height: MindlySpacing.md),
              OutlinedButton.icon(
                onPressed:
                    _controller.status == AudioCaptureStatus.downloadingModel
                    ? null
                    : _controller.downloadNativeModel,
                icon: const Icon(Icons.download_rounded),
                label: const Text('Download local transcription model'),
              ),
            ],
            if (_controller.isWeb) ...[
              const SizedBox(height: MindlySpacing.lg),
              const Text(
                'Your recording stays in this browser until you choose cloud transcription. '
                'Transcribing sends this recording directly to OpenAI using your BYOK key.',
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _webConsent,
                onChanged: (value) =>
                    setState(() => _webConsent = value ?? false),
                title: const Text(
                  'I agree to send this recording to OpenAI for transcription.',
                ),
              ),
            ],
            const SizedBox(height: MindlySpacing.md),
            DropdownButtonFormField<ExtractionProviderProfile>(
              initialValue: _profile,
              decoration: const InputDecoration(
                labelText: 'AI extraction after transcription',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: ExtractionProviderProfile.openAiDefault,
                  child: Text('OpenAI'),
                ),
                DropdownMenuItem(
                  value: ExtractionProviderProfile.anthropicDefault,
                  child: Text('Anthropic'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _profile = value);
                }
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _deleteAfterTranscription,
              onChanged: (value) =>
                  setState(() => _deleteAfterTranscription = value),
              title: const Text('Delete raw audio after transcript is saved'),
            ),
            const SizedBox(height: MindlySpacing.md),
            FilledButton.icon(
              onPressed:
                  _controller.canTranscribe &&
                      _controller.status != AudioCaptureStatus.transcribing
                  ? () => _controller.transcribeAndCapture(
                      extractionProfile: _profile,
                      webCloudConsent: _webConsent,
                      deleteAfterTranscription: _deleteAfterTranscription,
                    )
                  : null,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('Transcribe and remember'),
            ),
            if (_controller.lastOutcome?.transcript case final transcript?) ...[
              const SizedBox(height: MindlySpacing.lg),
              Text(
                'Transcript',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: MindlySpacing.sm),
              SelectableText(transcript),
            ],
          ],
        ),
      ),
    );
  }

  String _statusText(AudioCaptureStatus status) => switch (status) {
    AudioCaptureStatus.idle => 'Ready when you are.',
    AudioCaptureStatus.requestingPermission => 'Checking microphone access…',
    AudioCaptureStatus.permissionDenied =>
      'Microphone access is needed to record.',
    AudioCaptureStatus.recording => 'Recording — your microphone is active.',
    AudioCaptureStatus.recorded =>
      'Recording saved locally and ready to transcribe.',
    AudioCaptureStatus.downloadingModel =>
      'Downloading the local Whisper model…',
    AudioCaptureStatus.transcribing => 'Transcribing…',
    AudioCaptureStatus.complete => 'Transcript saved to your local memory.',
    AudioCaptureStatus.consentRequired =>
      'Confirm cloud transcription consent first.',
    AudioCaptureStatus.modelRequired =>
      'Download the local transcription model first.',
    AudioCaptureStatus.missingKey =>
      'Add an OpenAI key in Settings before Web transcription.',
    AudioCaptureStatus.spendBlocked =>
      'Your configured spend cap blocks this transcription.',
    AudioCaptureStatus.failed =>
      'This recording could not be processed. You can retry.',
  };
}
