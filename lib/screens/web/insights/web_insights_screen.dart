import 'package:flutter/material.dart';
import 'package:mindly/features/insights/application/insight_controller.dart';
import 'package:mindly/features/insights/application/tier3_insight_controller.dart';
import 'package:mindly/features/insights/application/tier3_ui_presenter.dart';
import 'package:mindly/features/insights/domain/insight_models.dart';
import 'package:mindly/features/insights/domain/tier3_models.dart';
import 'package:mindly/features/memory/domain/memory_models.dart';
import 'package:mindly/features/text_capture/domain/text_capture_models.dart';
import 'package:mindly/shared/design_tokens/mindly_spacing.dart';
import 'package:mindly/shared/widgets/mindly_brand_badge.dart';

class WebInsightsScreen extends StatefulWidget {
  const WebInsightsScreen({
    super.key,
    this.controller,
    this.tier3Controller,
  });

  static const screenKey = ValueKey<String>('screen-web-insights');

  final InsightController? controller;
  final Tier3InsightController? tier3Controller;

  @override
  State<WebInsightsScreen> createState() => _WebInsightsScreenState();
}

class _WebInsightsScreenState extends State<WebInsightsScreen> {
  late final InsightController _controller;
  late final Tier3InsightController _tier3Controller;
  late Future<List<ProactiveInsight>> _insightsFuture;
  String _tier3ProviderId = 'openai';
  Tier3GenerationPreview? _tier3Preview;
  ProactiveInsight? _tier3Insight;
  String _tier3Status = '';
  bool _tier3Busy = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? InsightController.production();
    _tier3Controller =
        widget.tier3Controller ?? Tier3InsightController.production();
    _insightsFuture = _controller.load();
  }

  ExtractionProviderProfile get _tier3Profile =>
      Tier3UiPresenter.profileFor(_tier3ProviderId);

  void _replaceFuture(Future<List<ProactiveInsight>> future) {
    setState(() => _insightsFuture = future);
  }

  Future<void> _previewTier3() async {
    setState(() {
      _tier3Busy = true;
      _tier3Preview = null;
      _tier3Status = '';
    });
    try {
      final preview = await _tier3Controller.preview(_tier3Profile);
      if (!mounted) return;
      setState(() {
        _tier3Preview = preview;
        _tier3Status = Tier3UiPresenter.previewMessage(preview);
      });
    } on Object {
      if (!mounted) return;
      setState(() => _tier3Status = 'Could not prepare AI synthesis safely.');
    } finally {
      if (mounted) setState(() => _tier3Busy = false);
    }
  }

  Future<void> _generateTier3() async {
    final preview = _tier3Preview;
    if (preview == null || !preview.isReady) return;
    setState(() {
      _tier3Busy = true;
      _tier3Status = '';
    });
    try {
      final outcome = await _tier3Controller.generate(_tier3Profile);
      if (!mounted) return;
      setState(() {
        _tier3Insight = outcome.insight;
        _tier3Preview = outcome.preview;
        _tier3Status = Tier3UiPresenter.outcomeMessage(outcome);
      });
    } on Object {
      if (!mounted) return;
      setState(
        () => _tier3Status =
            'AI synthesis failed safely. Local insights are unchanged.',
      );
    } finally {
      if (mounted) setState(() => _tier3Busy = false);
    }
  }

  Future<void> _dismissTier3() async {
    final insight = _tier3Insight;
    if (insight == null) return;
    await _controller.dismiss(insight.fingerprint);
    if (!mounted) return;
    setState(() => _tier3Insight = null);
  }

  Future<void> _muteTier3() async {
    await _controller.setMuted(InsightKind.aiSynthesis, true);
    if (!mounted) return;
    setState(() {
      _tier3Insight = null;
      _tier3Preview = null;
      _tier3Status = 'AI synthesis is muted.';
    });
  }

  Future<void> _openSource(InsightSourceReference source) async {
    final detail = await _controller.sourceDetail(source);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(source.title),
        content: SizedBox(width: 560, child: _WebSourceDetail(detail: detail)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showMutedKinds() async {
    final muted = await _controller.mutedKinds();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Muted insight types'),
        content: SizedBox(
          width: 420,
          child: muted.isEmpty
              ? const Text('Nothing is muted.')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final kind in muted)
                      ListTile(
                        title: Text(kind.displayName),
                        trailing: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _replaceFuture(_controller.setMuted(kind, false));
                            if (kind == InsightKind.aiSynthesis) {
                              setState(() {
                                _tier3Preview = null;
                                _tier3Status = '';
                              });
                            }
                          },
                          child: const Text('Unmute'),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: WebInsightsScreen.screenKey,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MindlyBrandBadge(),
            SizedBox(width: MindlySpacing.sm),
            Text('Insights'),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _showMutedKinds,
            icon: const Icon(Icons.visibility_off_outlined),
            label: const Text('Muted types'),
          ),
          const SizedBox(width: MindlySpacing.sm),
        ],
      ),
      body: FutureBuilder<List<ProactiveInsight>>(
        future: _insightsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Insights are unavailable right now.'),
            );
          }
          final localInsights = snapshot.data ?? const <ProactiveInsight>[];
          final insights = <ProactiveInsight>[
            if (_tier3Insight != null) _tier3Insight!,
            ...localInsights,
          ];
          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = width >= 1200
                  ? 3
                  : width >= 760
                  ? 2
                  : 1;
              final cardWidth = columns == 1
                  ? width
                  : (width - MindlySpacing.lg * (columns - 1)) / columns;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(MindlySpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WebTier3Panel(
                      providerId: _tier3ProviderId,
                      busy: _tier3Busy,
                      preview: _tier3Preview,
                      status: _tier3Status,
                      onProviderChanged: (value) {
                        setState(() {
                          _tier3ProviderId = value;
                          _tier3Preview = null;
                          _tier3Status = '';
                        });
                      },
                      onPreview: _previewTier3,
                      onGenerate: _generateTier3,
                    ),
                    const SizedBox(height: MindlySpacing.lg),
                    if (insights.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(MindlySpacing.xl),
                        child: Text(
                          'Nothing needs your attention right now. Local insights remain available without AI.',
                        ),
                      )
                    else
                      Wrap(
                        spacing: MindlySpacing.lg,
                        runSpacing: MindlySpacing.lg,
                        children: [
                          for (final insight in insights)
                            SizedBox(
                              width: cardWidth,
                              child: _WebInsightCard(
                                insight: insight,
                                onOpenSource: _openSource,
                                onDismiss: insight.kind == InsightKind.aiSynthesis
                                    ? _dismissTier3
                                    : () => _replaceFuture(
                                        _controller.dismiss(insight.fingerprint),
                                      ),
                                onMute: insight.kind == InsightKind.aiSynthesis
                                    ? _muteTier3
                                    : () => _replaceFuture(
                                        _controller.setMuted(insight.kind, true),
                                      ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _WebTier3Panel extends StatelessWidget {
  const _WebTier3Panel({
    required this.providerId,
    required this.busy,
    required this.preview,
    required this.status,
    required this.onProviderChanged,
    required this.onPreview,
    required this.onGenerate,
  });

  final String providerId;
  final bool busy;
  final Tier3GenerationPreview? preview;
  final String status;
  final ValueChanged<String> onProviderChanged;
  final VoidCallback onPreview;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(MindlySpacing.lg),
        child: Wrap(
          spacing: MindlySpacing.md,
          runSpacing: MindlySpacing.md,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 330,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explainable AI synthesis',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: MindlySpacing.xs),
                  const Text(
                    'Nothing is sent automatically. Preview the bounded local evidence and estimated cost first.',
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 190,
              child: DropdownButtonFormField<String>(
                initialValue: providerId,
                decoration: const InputDecoration(labelText: 'Provider'),
                items: const [
                  DropdownMenuItem(value: 'openai', child: Text('OpenAI')),
                  DropdownMenuItem(value: 'anthropic', child: Text('Anthropic')),
                ],
                onChanged: busy
                    ? null
                    : (value) {
                        if (value != null) onProviderChanged(value);
                      },
              ),
            ),
            OutlinedButton(
              key: const ValueKey<String>('web-tier3-preview'),
              onPressed: busy ? null : onPreview,
              child: const Text('Preview cost'),
            ),
            FilledButton(
              key: const ValueKey<String>('web-tier3-generate'),
              onPressed: busy || preview?.isReady != true ? null : onGenerate,
              child: const Text('Generate AI insight'),
            ),
            if (status.isNotEmpty) SizedBox(width: 360, child: Text(status)),
          ],
        ),
      ),
    );
  }
}

class _WebInsightCard extends StatelessWidget {
  const _WebInsightCard({
    required this.insight,
    required this.onOpenSource,
    required this.onDismiss,
    required this.onMute,
  });

  final ProactiveInsight insight;
  final ValueChanged<InsightSourceReference> onOpenSource;
  final VoidCallback onDismiss;
  final VoidCallback onMute;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(MindlySpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_severityIcon(insight.severity)),
                const SizedBox(width: MindlySpacing.sm),
                Expanded(
                  child: Text(
                    insight.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: MindlySpacing.sm),
            Text(insight.body),
            if (insight.explanation != null) ...[
              const SizedBox(height: MindlySpacing.sm),
              Text('Why: ${insight.explanation}'),
            ],
            const SizedBox(height: MindlySpacing.md),
            for (final source in insight.sources)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => onOpenSource(source),
                  icon: const Icon(Icons.link_rounded),
                  label: Text(source.title),
                ),
              ),
            const SizedBox(height: MindlySpacing.md),
            Wrap(
              spacing: MindlySpacing.sm,
              children: [
                OutlinedButton(onPressed: onMute, child: const Text('Mute type')),
                FilledButton(onPressed: onDismiss, child: const Text('Dismiss')),
              ],
            ),
            const SizedBox(height: MindlySpacing.sm),
            Text('${insight.tier.name.toUpperCase()} · ${insight.kind.displayName}'),
          ],
        ),
      ),
    );
  }

  IconData _severityIcon(InsightSeverity severity) => switch (severity) {
    InsightSeverity.info => Icons.lightbulb_outline_rounded,
    InsightSeverity.recommendation => Icons.auto_awesome_rounded,
    InsightSeverity.warning => Icons.warning_amber_rounded,
  };
}

class _WebSourceDetail extends StatelessWidget {
  const _WebSourceDetail({required this.detail});

  final MemoryDetail? detail;

  @override
  Widget build(BuildContext context) {
    if (detail == null) {
      return const Text('This source memory is no longer available.');
    }
    final content = [detail!.summary, detail!.transcript, detail!.rawText]
        .whereType<String>()
        .where((value) => value.trim().isNotEmpty)
        .join('\n\n');
    return SingleChildScrollView(
      child: Text(content.isEmpty ? detail!.item.title : content),
    );
  }
}
