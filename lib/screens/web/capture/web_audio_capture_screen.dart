import 'package:flutter/material.dart';
import 'package:mindly/features/audio_capture/application/audio_capture_controller.dart';
import 'package:mindly/features/audio_capture/domain/audio_capture_models.dart';
import 'package:mindly/features/text_capture/domain/text_capture_models.dart';
import 'package:mindly/shared/design_tokens/mindly_spacing.dart';

class WebAudioCaptureScreen extends StatefulWidget {
  const WebAudioCaptureScreen({super.key, this.controller});

  static const screenKey = ValueKey<String>('screen-web-audio-capture');
  final AudioCaptureController? controller;

  @override
  State<WebAudioCaptureScreen> createState() => _WebAudioCaptureScreenState();
}

class _WebAudioCaptureScreenState extends State<WebAudioCaptureScreen> {
  late final AudioCaptureController _controller;
  late final bool _ownsController;
  bool _cloudConsent = false;
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
      key: WebAudioCaptureScreen.screenKey,
      appBar: AppBar(title: const Text('Browser audio capture')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth < 760
                ? constraints.maxWidth
                : 720.0;
            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: width,
                child: ListView(
                  padding: const EdgeInsets.all(MindlySpacing.xl),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(MindlySpacing.lg),
                        child: Row(
                          children: [
                            Icon(
                              _controller.isRecording
                                  ? Icons.mic_rounded
                                  : Icons.mic_none_rounded,
                              size: 48,
                            ),
                            const SizedBox(width: MindlySpacing.md),
                            Expanded(child: Text(_statusText(_controller.status))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: MindlySpacing.lg),
                    const Text(
                      'Recording stays in this browser until you choose transcription. '
                      'Web transcription sends the selected recording directly to OpenAI '
                      'with your own API key; Mindly has no audio backend.',
                    ),
                    const SizedBox(height: MindlySpacing.md),
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
                    ] else
                      FilledButton.icon(
                        onPressed: _controller.status == AudioCaptureStatus.transcribing
                            ? null
                            : _controller.startRecording,
                        icon: const Icon(Icons.mic_rounded),
                        label: Text(
                          _controller.recording == null
                              ? 'Start browser recording'
                              : 'Record again',
                        ),
                      ),
                    const SizedBox(height: MindlySpacing.lg),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _cloudConsent,
                      onChanged: (value) =>
                          setState(() => _cloudConsent = value ?? false),
                      title: const Text(
                        'I agree to send this recording directly to OpenAI for transcription.',
                      ),
                      subtitle: const Text(
                        'This consent applies to this transcription action; the recording is '
                        'not sent before you choose Transcribe and remember.',
                      ),
                    ),
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
                      title: const Text('Clear raw audio after transcript is saved'),
                    ),
                    FilledButton.icon(
                      onPressed: _controller.canTranscribe &&
                              _controller.status != AudioCaptureStatus.transcribing
                          ? () => _controller.transcribeAndCapture(
                                extractionProfile: _profile,
                                webCloudConsent: _cloudConsent,
                                deleteAfterTranscription:
                                    _deleteAfterTranscription,
                              )
                          : null,
                      icon: const Icon(Icons.cloud_upload_rounded),
                      label: const Text('Transcribe and remember'),
                    ),
                    if (_controller.lastOutcome?.estimate case final estimate?) ...[
                      const SizedBox(height: MindlySpacing.sm),
                      Text(
                        'Preflight transcription estimate: '
                        '\$${estimate.estimatedUsd.toStringAsFixed(4)}',
                      ),
                    ],
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
            );
          },
        ),
      ),
    );
  }

  String _statusText(AudioCaptureStatus status) => switch (status) {
        AudioCaptureStatus.idle => 'Ready to record in this browser.',
        AudioCaptureStatus.requestingPermission => 'Checking browser microphone access…',
        AudioCaptureStatus.permissionDenied => 'Browser microphone access is required.',
        AudioCaptureStatus.recording => 'Recording — browser microphone active.',
        AudioCaptureStatus.recorded => 'Recording is local and ready for optional cloud transcription.',
        AudioCaptureStatus.transcribing => 'Sending directly to OpenAI and transcribing…',
        AudioCaptureStatus.complete => 'Transcript saved to your local Mindly memory.',
        AudioCaptureStatus.consentRequired => 'Cloud transcription consent is required.',
        AudioCaptureStatus.missingKey => 'Add an OpenAI BYOK key in Settings first.',
        AudioCaptureStatus.spendBlocked => 'Your configured spend cap blocks this request.',
        AudioCaptureStatus.failed => 'Transcription failed; the recording remains available to retry.',
        AudioCaptureStatus.modelRequired => 'Native model is not used on Web.',
        AudioCaptureStatus.downloadingModel => 'Native model is not used on Web.',
      };
}
