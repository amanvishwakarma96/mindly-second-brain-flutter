import 'package:flutter/material.dart';
import 'package:mindly/features/insights/application/insight_controller.dart';
import 'package:mindly/features/insights/domain/insight_models.dart';
import 'package:mindly/features/memory/domain/memory_models.dart';
import 'package:mindly/shared/design_tokens/mindly_spacing.dart';
import 'package:mindly/shared/widgets/mindly_brand_badge.dart';

class WebInsightsScreen extends StatefulWidget {
  const WebInsightsScreen({super.key, this.controller});

  static const screenKey = ValueKey<String>('screen-web-insights');

  final InsightController? controller;

  @override
  State<WebInsightsScreen> createState() => _WebInsightsScreenState();
}

class _WebInsightsScreenState extends State<WebInsightsScreen> {
  late final InsightController _controller;
  late Future<List<ProactiveInsight>> _insightsFuture;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? InsightController.production();
    _insightsFuture = _controller.load();
  }

  void _replaceFuture(Future<List<ProactiveInsight>> future) {
    setState(() => _insightsFuture = future);
  }

  Future<void> _openSource(InsightSourceReference source) async {
    final detail = await _controller.sourceDetail(source);
    if (!mounted) {
      return;
    }
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
    if (!mounted) {
      return;
    }
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
          children: [MindlyBrandBadge(), SizedBox(width: MindlySpacing.sm), Text('Insights')],
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
            return const Center(child: Text('Insights are unavailable right now.'));
          }
          final insights = snapshot.data ?? const <ProactiveInsight>[];
          if (insights.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(MindlySpacing.xl),
                child: Text(
                  'Nothing needs your attention right now. Insights are generated locally from saved evidence.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = width >= 1200 ? 3 : width >= 760 ? 2 : 1;
              final cardWidth = columns == 1
                  ? width
                  : (width - MindlySpacing.lg * (columns - 1)) / columns;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(MindlySpacing.lg),
                child: Wrap(
                  spacing: MindlySpacing.lg,
                  runSpacing: MindlySpacing.lg,
                  children: [
                    for (final insight in insights)
                      SizedBox(
                        width: cardWidth,
                        child: _WebInsightCard(
                          insight: insight,
                          onOpenSource: _openSource,
                          onDismiss: () => _replaceFuture(
                            _controller.dismiss(insight.fingerprint),
                          ),
                          onMute: () => _replaceFuture(
                            _controller.setMuted(insight.kind, true),
                          ),
                        ),
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
                  child: Text(insight.title, style: Theme.of(context).textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: MindlySpacing.sm),
            Text(insight.body),
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
