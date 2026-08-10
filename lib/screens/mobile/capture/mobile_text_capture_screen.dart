import 'package:flutter/material.dart';
import 'package:mindly/app/app_routes.dart';
import 'package:mindly/features/ai_settings/domain/cost_models.dart';
import 'package:mindly/features/text_capture/application/text_capture_controller.dart';
import 'package:mindly/features/text_capture/domain/memory_extraction.dart';
import 'package:mindly/features/text_capture/domain/text_capture_models.dart';
import 'package:mindly/shared/design_tokens/mindly_spacing.dart';

class MobileTextCaptureScreen extends StatefulWidget {
  const MobileTextCaptureScreen({super.key, this.controller});

  static const screenKey = ValueKey<String>('screen-mobile-text-capture');

  final TextCaptureController? controller;

  @override
  State<MobileTextCaptureScreen> createState() => _MobileTextCaptureScreenState();
}

class _MobileTextCaptureScreenState extends State<MobileTextCaptureScreen> {
  late final TextCaptureController _controller;
  final _textController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _modelController = TextEditingController();
  final _inputRateController = TextEditingController();
  final _outputRateController = TextEditingController();
  String _providerId = 'openai';
  CostEstimate? _estimate;
  TextCaptureOutcome? _outcome;
  bool _busy = false;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextCaptureController.production();
    _textController.addListener(_refreshEstimate);
  }

  @override
  void dispose() {
    _textController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    _inputRateController.dispose();
    _outputRateController.dispose();
    super.dispose();
  }

  ExtractionProviderProfile _profile() {
    return switch (_providerId) {
      'openai' => ExtractionProviderProfile.openAiDefault,
      'anthropic' => ExtractionProviderProfile.anthropicDefault,
      _ => ExtractionProviderProfile.compatible(
        baseUrl: _baseUrlController.text,
        model: _modelController.text,
        inputUsdPerMillionTokens:
            double.tryParse(_inputRateController.text) ?? -1,
        outputUsdPerMillionTokens:
            double.tryParse(_outputRateController.text) ?? -1,
      ),
    };
  }

  void _refreshEstimate() {
    if (!mounted) return;
    try {
      if (_textController.text.trim().isEmpty) {
        setState(() => _estimate = null);
        return;
      }
      final estimate = _controller.estimate(
        text: _textController.text,
        profile: _profile(),
      );
      setState(() => _estimate = estimate);
    } on Object {
      setState(() => _estimate = null);
    }
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _status = '';
      _outcome = null;
    });
    try {
      final outcome = await _controller.capture(
        text: _textController.text,
        profile: _profile(),
      );
      if (!mounted) return;
      setState(() {
        _outcome = outcome;
        _status = _statusFor(outcome);
      });
    } on Object {
      if (!mounted) return;
      setState(() => _status = 'Check the note and provider details, then try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _classify(ExtractionContext context) async {
    final outcome = _outcome;
    final extraction = outcome?.extraction;
    if (outcome == null || extraction == null) return;
    await _controller.classify(captureId: outcome.captureId, context: context);
    if (!mounted) return;
    setState(() {
      _outcome = TextCaptureOutcome(
        kind: outcome.kind,
        captureId: outcome.captureId,
        estimate: outcome.estimate,
        extraction: extraction.copyWith(context: context),
      );
      _status = 'Context updated to ${context.name}.';
    });
  }

  String _statusFor(TextCaptureOutcome outcome) {
    return switch (outcome.kind) {
      TextCaptureOutcomeKind.extracted => 'Saved locally and organized.',
      TextCaptureOutcomeKind.savedMissingKey =>
        'Saved locally. Add this provider API key in Settings to enable extraction.',
      TextCaptureOutcomeKind.savedSpendBlocked =>
        'Saved locally. The AI call was blocked by your spend cap.',
      TextCaptureOutcomeKind.savedProviderFailure =>
        'Saved locally. The provider request failed, so your note is safe for retry.',
      TextCaptureOutcomeKind.savedInvalidExtraction =>
        'Saved locally. The provider returned an invalid structured extraction.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final extraction = _outcome?.extraction;
    return Scaffold(
      key: MobileTextCaptureScreen.screenKey,
      appBar: AppBar(title: const Text('Text capture')),
      body: ListView(
        padding: const EdgeInsets.all(MindlySpacing.md),
        children: [
          Text(
            'What should Mindly remember?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: MindlySpacing.md),
          DropdownButtonFormField<String>(
            initialValue: _providerId,
            decoration: const InputDecoration(labelText: 'AI provider'),
            items: const [
              DropdownMenuItem(value: 'openai', child: Text('OpenAI')),
              DropdownMenuItem(value: 'anthropic', child: Text('Anthropic')),
              DropdownMenuItem(
                value: 'compatible',
                child: Text('OpenAI-compatible'),
              ),
            ],
            onChanged: _busy
                ? null
                : (value) {
                    setState(() => _providerId = value!);
                    _refreshEstimate();
                  },
          ),
          if (_providerId == 'compatible') ...[
            const SizedBox(height: MindlySpacing.sm),
            TextField(
              controller: _baseUrlController,
              onChanged: (_) => _refreshEstimate(),
              decoration: const InputDecoration(
                labelText: 'API base URL (include /v1 when required)',
              ),
            ),
            const SizedBox(height: MindlySpacing.sm),
            TextField(
              controller: _modelController,
              onChanged: (_) => _refreshEstimate(),
              decoration: const InputDecoration(labelText: 'Model'),
            ),
            const SizedBox(height: MindlySpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputRateController,
                    onChanged: (_) => _refreshEstimate(),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Input $/1M tokens',
                    ),
                  ),
                ),
                const SizedBox(width: MindlySpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _outputRateController,
                    onChanged: (_) => _refreshEstimate(),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Output $/1M tokens',
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: MindlySpacing.md),
          TextField(
            controller: _textController,
            minLines: 8,
            maxLines: 14,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Paste a note, meeting thought, idea, or commitment…',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: MindlySpacing.sm),
          if (_estimate != null)
            Text(
              'Estimated maximum AI cost: ~\$${_estimate!.estimatedUsd.toStringAsFixed(4)}',
            ),
          const SizedBox(height: MindlySpacing.md),
          FilledButton.icon(
            onPressed: _busy ? null : _submit,
            icon: const Icon(Icons.auto_awesome_rounded),
            label: Text(_busy ? 'Saving…' : 'Save & organize'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.providerSettings),
            child: const Text('AI provider settings'),
          ),
          if (_status.isNotEmpty) ...[
            const SizedBox(height: MindlySpacing.md),
            Text(_status),
          ],
          if (extraction != null) ...[
            const SizedBox(height: MindlySpacing.lg),
            Text('Summary', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: MindlySpacing.xs),
            Text(extraction.summary),
            const SizedBox(height: MindlySpacing.md),
            Text('Context: ${extraction.context.name}'),
            if (extraction.context == ExtractionContext.ambiguous) ...[
              const SizedBox(height: MindlySpacing.sm),
              Wrap(
                spacing: MindlySpacing.sm,
                children: [
                  ActionChip(
                    label: const Text('Work'),
                    onPressed: () => _classify(ExtractionContext.work),
                  ),
                  ActionChip(
                    label: const Text('Personal'),
                    onPressed: () => _classify(ExtractionContext.personal),
                  ),
                ],
              ),
            ],
            if (extraction.people.isNotEmpty)
              Text('People: ${extraction.people.join(', ')}'),
            if (extraction.topics.isNotEmpty)
              Text('Topics: ${extraction.topics.join(', ')}'),
            if (extraction.commitments.isNotEmpty) ...[
              const SizedBox(height: MindlySpacing.sm),
              Text('Commitments', style: Theme.of(context).textTheme.titleMedium),
              for (final item in extraction.commitments) Text('• $item'),
            ],
          ],
        ],
      ),
    );
  }
}
