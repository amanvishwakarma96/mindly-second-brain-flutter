import 'package:flutter/material.dart';
import 'package:mindly/app/app_routes.dart';
import 'package:mindly/features/ai_settings/domain/cost_models.dart';
import 'package:mindly/features/text_capture/application/text_capture_controller.dart';
import 'package:mindly/features/text_capture/domain/memory_extraction.dart';
import 'package:mindly/features/text_capture/domain/text_capture_models.dart';
import 'package:mindly/shared/design_tokens/mindly_colors.dart';
import 'package:mindly/shared/design_tokens/mindly_spacing.dart';

class WebTextCaptureScreen extends StatefulWidget {
  const WebTextCaptureScreen({super.key, this.controller});

  static const screenKey = ValueKey<String>('screen-web-text-capture');

  final TextCaptureController? controller;

  @override
  State<WebTextCaptureScreen> createState() => _WebTextCaptureScreenState();
}

class _WebTextCaptureScreenState extends State<WebTextCaptureScreen> {
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

  ExtractionProviderProfile _profile() => switch (_providerId) {
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

  void _refreshEstimate() {
    if (!mounted) return;
    try {
      final text = _textController.text.trim();
      final next = text.isEmpty
          ? null
          : _controller.estimate(text: text, profile: _profile());
      setState(() => _estimate = next);
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
        _status = _statusFor(outcome.kind);
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

  String _statusFor(TextCaptureOutcomeKind kind) => switch (kind) {
    TextCaptureOutcomeKind.extracted => 'Saved locally and organized.',
    TextCaptureOutcomeKind.savedMissingKey =>
      'Saved locally. Add this provider key in Settings before extraction.',
    TextCaptureOutcomeKind.savedSpendBlocked =>
      'Saved locally. The provider call was blocked by your spend cap.',
    TextCaptureOutcomeKind.savedProviderFailure =>
      'Saved locally. The direct provider request failed; your note remains local.',
    TextCaptureOutcomeKind.savedInvalidExtraction =>
      'Saved locally. The provider response did not match the memory schema.',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: WebTextCaptureScreen.screenKey,
      appBar: AppBar(
        title: const Text('Text capture'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.providerSettings),
            icon: const Icon(Icons.settings_rounded),
            label: const Text('Provider settings'),
          ),
          const SizedBox(width: MindlySpacing.sm),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 820;
          final form = _buildForm(context);
          final result = _buildResult(context);
          if (narrow) {
            return ListView(
              padding: const EdgeInsets.all(MindlySpacing.md),
              children: [form, const SizedBox(height: MindlySpacing.lg), result],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(MindlySpacing.xl),
                  child: form,
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(MindlySpacing.xl),
                  child: result,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your note stays in this browser first.',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: MindlySpacing.sm),
        const Card(
          color: MindlyColors.peach,
          child: Padding(
            padding: EdgeInsets.all(MindlySpacing.md),
            child: Text(
              'When AI extraction runs, Mindly calls your selected provider directly. '
              'Mindly does not proxy this note through its own server.',
            ),
          ),
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
            decoration: const InputDecoration(labelText: 'API base URL'),
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
                  decoration: const InputDecoration(labelText: 'Input $/1M tokens'),
                ),
              ),
              const SizedBox(width: MindlySpacing.sm),
              Expanded(
                child: TextField(
                  controller: _outputRateController,
                  onChanged: (_) => _refreshEstimate(),
                  decoration: const InputDecoration(labelText: 'Output $/1M tokens'),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: MindlySpacing.md),
        TextField(
          controller: _textController,
          minLines: 10,
          maxLines: 18,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Type or paste something worth remembering…',
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
        if (_status.isNotEmpty) ...[
          const SizedBox(height: MindlySpacing.md),
          Text(_status),
        ],
      ],
    );
  }

  Widget _buildResult(BuildContext context) {
    final extraction = _outcome?.extraction;
    if (extraction == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(MindlySpacing.lg),
          child: Text('Summary, people, topics, and commitments will appear here.'),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(MindlySpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Summary', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: MindlySpacing.sm),
            Text(extraction.summary),
            const SizedBox(height: MindlySpacing.md),
            Text('Context: ${extraction.context.name}'),
            if (extraction.context == ExtractionContext.ambiguous) ...[
              const SizedBox(height: MindlySpacing.sm),
              Wrap(
                spacing: MindlySpacing.sm,
                children: [
                  OutlinedButton(
                    onPressed: () => _classify(ExtractionContext.work),
                    child: const Text('Work'),
                  ),
                  OutlinedButton(
                    onPressed: () => _classify(ExtractionContext.personal),
                    child: const Text('Personal'),
                  ),
                ],
              ),
            ],
            if (extraction.people.isNotEmpty) ...[
              const SizedBox(height: MindlySpacing.md),
              Text('People: ${extraction.people.join(', ')}'),
            ],
            if (extraction.topics.isNotEmpty)
              Text('Topics: ${extraction.topics.join(', ')}'),
            if (extraction.commitments.isNotEmpty) ...[
              const SizedBox(height: MindlySpacing.md),
              Text('Commitments', style: Theme.of(context).textTheme.titleMedium),
              for (final item in extraction.commitments) Text('• $item'),
            ],
          ],
        ),
      ),
    );
  }
}
