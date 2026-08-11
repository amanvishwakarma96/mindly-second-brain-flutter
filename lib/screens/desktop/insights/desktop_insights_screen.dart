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

class DesktopInsightsScreen extends StatefulWidget {
  const DesktopInsightsScreen({
    super.key,
    this.controller,
    this.tier3Controller,
  });

  static const screenKey = ValueKey<String>('screen-desktop-insights');

  final InsightController? controller;
  final Tier3InsightController? tier3Controller;

  @override
  State<DesktopInsightsScreen> createState() => _DesktopInsightsScreenState();
}

class _DesktopInsightsScreenState extends State<DesktopInsightsScreen> {
  late final InsightController _controller;
  late final Tier3InsightController _tier3Controller;
  late Future<List<ProactiveInsight>> _insightsFuture;
  ProactiveInsight? _selected;
  ProactiveInsight? _tier3Insight;
  Tier3GenerationPreview? _tier3Preview;
  String _tier3ProviderId = 'openai';
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
    setState(() {
      _selected = null;
      _insightsFuture = future;
    });
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
        _selected = outcome.insight;
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

  Future<void> _dismissSelected() async {
    final selected = _selected;
    if (selected == null) return;
    if (_tier3Insight?.fingerprint == selected.fingerprint) {
      await _controller.dismiss(selected.fingerprint);
      if (!mounted) return;
      setState(() {
        _tier3Insight = null;
        _selected = null;
      });
      return;
    }
    _replaceFuture(_controller.dismiss(selected.fingerprint));
  }

  Future<void> _muteSelected() async {
    final selected = _selected;
    if (selected == null) return;
    _replaceFuture(_controller.setMuted(selected.kind, true));
    if (selected.kind == InsightKind.aiSynthesis && mounted) {
      setState(() {
        _tier3Insight = null;
        _tier3Preview = null;
        _tier3Status = 'AI synthesis is muted.';
      });
    }
  }

  Future<void> _openSource(InsightSourceReference source) async {
    final detail = await _controller.sourceDetail(source);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(source.title),
        content: SizedBox(
          width: 520,
          child: _DesktopSourceDetail(detail: detail),
        ),
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
      key: DesktopInsightsScreen.screenKey,
      body: Row(
        children: [
          SizedBox(
            width: 260,
            child: Padding(
              padding: const EdgeInsets.all(MindlySpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MindlyBrandBadge(),
                  const SizedBox(height: MindlySpacing.xl),
                  Text(
                    'Insights',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: MindlySpacing.sm),
                  const Text('Local signals stay available without AI.'),
                  const SizedBox(height: MindlySpacing.lg),
                  Text(
                    'Optional AI synthesis',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: MindlySpacing.sm),
                  DropdownButtonFormField<String>(
                    initialValue: _tier3ProviderId,
                    decoration: const InputDecoration(labelText: 'Provider'),
                    items: const [
                      DropdownMenuItem(value: 'openai', child: Text('OpenAI')),
                      DropdownMenuItem(
                        value: 'anthropic',
                        child: Text('Anthropic'),
                      ),
                    ],
                    onChanged: _tier3Busy
                        ? null
                        : (value) {
                            if (value == null) return;
                            setState(() {
                              _tier3ProviderId = value;
                              _tier3Preview = null;
                              _tier3Status = '';
                            });
                          },
                  ),
                  const SizedBox(height: MindlySpacing.sm),
                  OutlinedButton(
                    key: const ValueKey<String>('desktop-tier3-preview'),
                    onPressed: _tier3Busy ? null : _previewTier3,
                    child: const Text('Preview cost'),
                  ),
                  const SizedBox(height: MindlySpacing.sm),
                  FilledButton(
                    key: const ValueKey<String>('desktop-tier3-generate'),
                    onPressed: _tier3Busy || _tier3Preview?.isReady != true
                        ? null
                        : _generateTier3,
                    child: const Text('Generate AI insight'),
                  ),
                  if (_tier3Status.isNotEmpty) ...[
                    const SizedBox(height: MindlySpacing.sm),
                    Text(_tier3Status),
                  ],
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: _showMutedKinds,
                    icon: const Icon(Icons.visibility_off_outlined),
                    label: const Text('Muted types'),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 3,
            child: FutureBuilder<List<ProactiveInsight>>(
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
                final local = snapshot.data ?? const <ProactiveInsight>[];
                final insights = <ProactiveInsight>[?_tier3Insight, ...local];
                if (insights.isEmpty) {
                  return const Center(
                    child: Text('Nothing needs your attention right now.'),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(MindlySpacing.lg),
                  itemCount: insights.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: MindlySpacing.sm),
                  itemBuilder: (context, index) {
                    final insight = insights[index];
                    return Card(
                      child: ListTile(
                        selected: _selected?.fingerprint == insight.fingerprint,
                        leading: Icon(_severityIcon(insight.severity)),
                        title: Text(insight.title),
                        subtitle: Text(insight.body),
                        trailing: Text(insight.tier.name.toUpperCase()),
                        onTap: () => setState(() => _selected = insight),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const VerticalDivider(width: 1),
          SizedBox(
            width: 380,
            child: _selected == null
                ? const Padding(
                    padding: EdgeInsets.all(MindlySpacing.lg),
                    child: Text(
                      'Select an insight to review its local evidence.',
                    ),
                  )
                : _DesktopInsightDetail(
                    insight: _selected!,
                    onOpenSource: _openSource,
                    onDismiss: _dismissSelected,
                    onMute: _muteSelected,
                  ),
          ),
        ],
      ),
    );
  }

  IconData _severityIcon(InsightSeverity severity) => switch (severity) {
    InsightSeverity.info => Icons.lightbulb_outline_rounded,
    InsightSeverity.recommendation => Icons.auto_awesome_rounded,
    InsightSeverity.warning => Icons.warning_amber_rounded,
  };
}

class _DesktopInsightDetail extends StatelessWidget {
  const _DesktopInsightDetail({
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
    return Padding(
      padding: const EdgeInsets.all(MindlySpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(insight.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: MindlySpacing.sm),
          Text(insight.body),
          if (insight.explanation != null) ...[
            const SizedBox(height: MindlySpacing.md),
            Text(
              'Why this surfaced',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: MindlySpacing.xs),
            Text(insight.explanation!),
          ],
          const SizedBox(height: MindlySpacing.lg),
          Text('Sources', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: MindlySpacing.sm),
          for (final source in insight.sources)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => onOpenSource(source),
                icon: const Icon(Icons.link_rounded),
                label: Text(source.title),
              ),
            ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onMute,
                  child: const Text('Mute type'),
                ),
              ),
              const SizedBox(width: MindlySpacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: onDismiss,
                  child: const Text('Dismiss'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DesktopSourceDetail extends StatelessWidget {
  const _DesktopSourceDetail({required this.detail});

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
