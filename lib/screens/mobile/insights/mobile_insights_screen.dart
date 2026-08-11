import 'package:flutter/material.dart';
import 'package:mindly/features/insights/application/insight_controller.dart';
import 'package:mindly/features/insights/domain/insight_models.dart';
import 'package:mindly/features/memory/domain/memory_models.dart';
import 'package:mindly/shared/design_tokens/mindly_spacing.dart';

class MobileInsightsScreen extends StatefulWidget {
  const MobileInsightsScreen({super.key, this.controller});

  static const screenKey = ValueKey<String>('screen-mobile-insights');

  final InsightController? controller;

  @override
  State<MobileInsightsScreen> createState() => _MobileInsightsScreenState();
}

class _MobileInsightsScreenState extends State<MobileInsightsScreen> {
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
    if (!mounted) {
      return;
    }
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
          if (insights.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(MindlySpacing.xl),
                child: Text(
                  'Nothing needs your attention right now. New insights will stay grounded in your saved memories.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(MindlySpacing.md),
            itemCount: insights.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: MindlySpacing.sm),
            itemBuilder: (context, index) {
              final insight = insights[index];
              return Dismissible(
                key: ValueKey<String>('mobile-insight-${insight.fingerprint}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: MindlySpacing.lg),
                  child: const Icon(Icons.done_rounded),
                ),
                onDismissed: (_) {
                  _replaceFuture(_controller.dismiss(insight.fingerprint));
                },
                child: Card(
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
                                if (value == 'dismiss') {
                                  _replaceFuture(
                                    _controller.dismiss(insight.fingerprint),
                                  );
                                } else if (value == 'mute') {
                                  _replaceFuture(
                                    _controller.setMuted(insight.kind, true),
                                  );
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'dismiss',
                                  child: Text('Dismiss'),
                                ),
                                PopupMenuItem(
                                  value: 'mute',
                                  child: Text('Mute this type'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: MindlySpacing.sm),
                        Text(insight.body),
                        const SizedBox(height: MindlySpacing.md),
                        Wrap(
                          spacing: MindlySpacing.sm,
                          runSpacing: MindlySpacing.sm,
                          children: [
                            for (final source in insight.sources)
                              ActionChip(
                                avatar: const Icon(
                                  Icons.link_rounded,
                                  size: 18,
                                ),
                                label: Text(source.title),
                                onPressed: () => _openSource(source),
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
                ),
              );
            },
          );
        },
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
