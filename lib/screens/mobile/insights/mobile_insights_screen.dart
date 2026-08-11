import 'package:flutter/material.dart';
import 'package:mindly/features/insights/application/insight_controller.dart';
import 'package:mindly/features/insights/application/tier3_insight_controller.dart';
import 'package:mindly/features/insights/application/tier3_ui_presenter.dart';
import 'package:mindly/features/insights/domain/insight_models.dart';
import 'package:mindly/features/insights/domain/tier3_models.dart';
import 'package:mindly/features/memory/domain/memory_models.dart';
import 'package:mindly/features/text_capture/domain/text_capture_models.dart';
import 'package:mindly/shared/design_tokens/mindly_spacing.dart';

class MobileInsightsScreen extends StatefulWidget {
  const MobileInsightsScreen({
    super.key,
    this.controller,
    this.tier3Controller,
  });

  static const screenKey = ValueKey<String>('screen-mobile-insights');

  final InsightController? controller;
  final Tier3InsightController? tier3Controller;

  @override
  State<MobileInsightsScreen> createState() => _MobileInsightsScreenState();
}

class _MobileInsightsScreenState extends State<MobileInsightsScreen> {
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
      _tier3Status = '';
      _tier3Preview = null;
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
        _tier3Status = Tier3UiPresenter.outcomeMessage(outcome);
        _tier3Preview = outcome.preview;
      });
    } on Object {
      if (!mounted) return;
      setState(
        () => _tier3Status =
            'AI synthesis failed safely. Your local insights are unchanged.',
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
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(MindlySpacing.lg),
          child: _MobileSourceDetail(detail: detail, source: source),
        ),
      ),
    );
  }

  Future<void> _showMutedKinds() async {
    final muted = await _controller.mutedKinds();
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(MindlySpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Muted insight types',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: MindlySpacing.md),
              if (muted.isEmpty)
                const Text('Nothing is muted.')
              else
                for (final kind in muted)
                  ListTile(
                    title: Text(kind.displayName),
                    trailing: TextButton(
                      onPressed: () async {
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
      key: MobileInsightsScreen.screenKey,
      appBar: AppBar(
        title: const Text('Insights'),
        actions: [
          IconButton(
            tooltip: 'Muted insight types',
            onPressed: _showMutedKinds,
            icon: const Icon(Icons.visibility_off_outlined),
          ),
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
          final insights = snapshot.data ?? const <ProactiveInsight>[];
          return ListView(
            padding: const EdgeInsets.all(MindlySpacing.md),
            children: [
              _MobileTier3Panel(
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
              if (_tier3Insight != null) ...[
                const SizedBox(height: MindlySpacing.md),
                _MobileInsightCard(
                  insight: _tier3Insight!,
                  onOpenSource: _openSource,
                  onDismiss: _dismissTier3,
                  onMute: _muteTier3,
                ),
              ],
              const SizedBox(height: MindlySpacing.lg),
              if (insights.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(MindlySpacing.lg),
                  child: Text(
                    'Nothing needs your attention right now. New local insights will stay grounded in your saved memories.',
                    textAlign: TextAlign.center,
                  ),
                )
              else
                for (final insight in insights) ...[
                  _MobileInsightCard(
                    insight: insight,
                    onOpenSource: _openSource,
                    onDismiss: () => _replaceFuture(
                      _controller.dismiss(insight.fingerprint),
                    ),
                    onMute: () => _replaceFuture(
                      _controller.setMuted(insight.kind, true),
                    ),
                  ),
                  const SizedBox(height: MindlySpacing.sm),
                ],
            ],
          );
        },
      ),
    );
  }
}

class _MobileTier3Panel extends StatelessWidget {
  const _MobileTier3Panel({
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
        padding: const EdgeInsets.all(MindlySpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology_alt_outlined),
                const SizedBox(width: MindlySpacing.sm),
                Expanded(
                  child: Text(
                    'Explainable AI synthesis',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: MindlySpacing.sm),
            const Text(
              'Optional and user-triggered. Mindly sends only a bounded set of linked local evidence using your provider key.',
            ),
            const SizedBox(height: MindlySpacing.md),
            DropdownButtonFormField<String>(
              initialValue: providerId,
              decoration: const InputDecoration(labelText: 'AI provider'),
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
            const SizedBox(height: MindlySpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const ValueKey<String>('mobile-tier3-preview'),
                    onPressed: busy ? null : onPreview,
                    child: const Text('Preview cost'),
                  ),
                ),
                const SizedBox(width: MindlySpacing.sm),
                Expanded(
                  child: FilledButton(
                    key: const ValueKey<String>('mobile-tier3-generate'),
                    onPressed: busy || preview?.isReady != true
                        ? null
                        : onGenerate,
                    child: const Text('Generate'),
                  ),
                ),
              ],
            ),
            if (status.isNotEmpty) ...[
              const SizedBox(height: MindlySpacing.sm),
              Text(status),
            ],
          ],
        ),
      ),
    );
  }
}

class _MobileInsightCard extends StatelessWidget {
  const _MobileInsightCard({
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
        padding: const EdgeInsets.all(MindlySpacing.md),
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
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'dismiss') onDismiss();
                    if (value == 'mute') onMute();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'dismiss', child: Text('Dismiss')),
                    PopupMenuItem(value: 'mute', child: Text('Mute this type')),
                  ],
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
            Wrap(
              spacing: MindlySpacing.sm,
              runSpacing: MindlySpacing.sm,
              children: [
                for (final source in insight.sources)
                  ActionChip(
                    avatar: const Icon(Icons.link_rounded, size: 18),
                    label: Text(source.title),
                    onPressed: () => onOpenSource(source),
                  ),
              ],
            ),
            const SizedBox(height: MindlySpacing.sm),
            Text(
              '${insight.tier.name.toUpperCase()} · ${insight.kind.displayName}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
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

class _MobileSourceDetail extends StatelessWidget {
  const _MobileSourceDetail({required this.detail, required this.source});

  final MemoryDetail? detail;
  final InsightSourceReference source;

  @override
  Widget build(BuildContext context) {
    if (detail == null) {
      return const Text('This source memory is no longer available.');
    }
    final content = [detail!.summary, detail!.transcript, detail!.rawText]
        .whereType<String>()
        .where((value) => value.trim().isNotEmpty)
        .join('\n\n');
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(source.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: MindlySpacing.sm),
        Text(content.isEmpty ? detail!.item.title : content),
        const SizedBox(height: MindlySpacing.md),
        Text('${detail!.connections.length} local connection(s)'),
      ],
    );
  }
}
