import 'package:flutter/material.dart';
import 'package:mindly/features/audio_capture/application/audio_capture_controller.dart';
import 'package:mindly/features/audio_capture/domain/audio_capture_models.dart';
import 'package:mindly/features/text_capture/domain/text_capture_models.dart';
import 'package:mindly/shared/design_tokens/mindly_spacing.dart';

class DesktopAudioCaptureScreen extends StatefulWidget {
  const DesktopAudioCaptureScreen({super.key, this.controller});

  static const screenKey = ValueKey<String>('screen-desktop-audio-capture');
  final AudioCaptureController? controller;

  @override
  State<DesktopAudioCaptureScreen> createState() =>
      _DesktopAudioCaptureScreenState();
}

class _DesktopAudioCaptureScreenState extends State<DesktopAudioCaptureScreen> {
  late final AudioCaptureController _controller;
  late final bool _ownsController;
  bool _deleteAfterTranscription = true;
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
      key: DesktopAudioCaptureScreen.screenKey,
      appBar: AppBar(title: const Text('Audio capture')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Padding(
          padding: const EdgeInsets.all(MindlySpacing.xl),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 360,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(MindlySpacing.lg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _controller.isRecording
                              ? Icons.mic_rounded
                              : Icons.mic_none_rounded,
                          size: 64,
                        ),
                        const SizedBox(height: MindlySpacing.md),
                        Text(
                          _statusText(_controller.status),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: MindlySpacing.lg),
                        if (_controller.isRecording) ...[
                          FilledButton.icon(
                            onPressed: _controller.stopRecording,
                            icon: const Icon(Icons.stop_rounded),
                            label: const Text('Stop'),
                          ),
                          TextButton(
                            onPressed: _controller.cancelRecording,
                            child: const Text('Cancel and discard'),
                          ),
                        ] else
                          FilledButton.icon(
                            onPressed:
                                _controller.status ==
                                    AudioCaptureStatus.transcribing
                                ? null
                                : _controller.startRecording,
                            icon: const Icon(Icons.mic_rounded),
                            label: Text(
                              _controller.recording == null
                                  ? 'Start recording'
                                  : 'Record again',
                            ),
                          ),
                        const SizedBox(height: MindlySpacing.sm),
                        OutlinedButton.icon(
                          onPressed:
                              _controller.status ==
                                  AudioCaptureStatus.downloadingModel
                              ? null
                              : _controller.downloadNativeModel,
                          icon: const Icon(Icons.download_rounded),
                          label: const Text('Get local Whisper model'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: MindlySpacing.xl),
              Expanded(
                child: ListView(
                  children: [
                    Text(
                      'On-device transcription',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: MindlySpacing.sm),
                    const Text(
                      'Audio stays on this computer for native transcription. '
                      'Only the resulting text enters the normal BYOK extraction flow.',
                    ),
                    const SizedBox(height: MindlySpacing.lg),
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
                      title: const Text(
                        'Delete raw audio after transcript is saved',
                      ),
                    ),
                    FilledButton.icon(
                      onPressed:
                          _controller.canTranscribe &&
                              _controller.status !=
                                  AudioCaptureStatus.transcribing
                          ? () => _controller.transcribeAndCapture(
                              extractionProfile: _profile,
                              webCloudConsent: false,
                              deleteAfterTranscription:
                                  _deleteAfterTranscription,
                            )
                          : null,
                      icon: const Icon(Icons.auto_awesome_rounded),
                      label: const Text('Transcribe and remember'),
                    ),
                    if (_controller.lastOutcome?.transcript
                        case final transcript?) ...[
                      const SizedBox(height: MindlySpacing.xl),
                      Text(
                        'Transcript',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: MindlySpacing.sm),
                      SelectableText(transcript),
                    ],
                    if (_controller.errorMessage case final message?) ...[
                      const SizedBox(height: MindlySpacing.md),
                      Text(message),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusText(AudioCaptureStatus status) => switch (status) {
    AudioCaptureStatus.idle => 'Ready to record',
    AudioCaptureStatus.requestingPermission => 'Checking microphone access…',
    AudioCaptureStatus.permissionDenied => 'Microphone access is required.',
    AudioCaptureStatus.recording => 'Recording — microphone active',
    AudioCaptureStatus.recorded => 'Saved locally',
    AudioCaptureStatus.downloadingModel => 'Downloading Whisper model…',
    AudioCaptureStatus.transcribing => 'Transcribing locally…',
    AudioCaptureStatus.complete => 'Saved to local memory',
    AudioCaptureStatus.modelRequired => 'Local Whisper model required',
    AudioCaptureStatus.spendBlocked =>
      'Spend cap blocked downstream extraction',
    AudioCaptureStatus.missingKey => 'Provider key required for extraction',
    AudioCaptureStatus.consentRequired => 'Consent required',
    AudioCaptureStatus.failed => 'Processing failed; recording can be retried',
  };
}
