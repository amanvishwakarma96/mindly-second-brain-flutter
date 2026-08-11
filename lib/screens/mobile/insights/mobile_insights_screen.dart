import 'package:flutter/material.dart';
import 'package:mindly/features/insights/application/insight_controller.dart';
import 'package:mindly/features/insights/domain/insight_models.dart';
import 'package:mindly/features/insights/presentation/tier3_provider_picker.dart';
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
  bool _generatingTier3 = false;

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

  Future<void> _generateTier3() async {
    if (_generatingTier3) return;
    final profile = await showTier3ProviderPicker(context);
    if (profile == null || !mounted) return;

    final estimate = await _controller.estimateTier3(profile);
    if (!mounted) return;
    if (estimate == null) {
      _showMessage(
        'Add a little more connected memory before asking AI for an insight.',
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate AI insights?'),
        content: Text(
          'This sends the selected memory context directly to ${profile.configuration.displayName}. '
          'Estimated maximum cost: \$${estimate.estimatedUsd.toStringAsFixed(4)}. Your spend caps still apply.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Generate'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _generatingTier3 = true);
    final outcome = await _controller.generateTier3(profile);
    if (!mounted) return;
    setState(() => _generatingTier3 = false);
    if (outcome.generated) {
      _replaceFuture(_controller.load());
      _showMessage(
        outcome.insights.isEmpty
            ? 'AI did not find a well-supported new insight.'
            : 'AI insights refreshed.',
      );
      return;
    }
    _showMessage(_tier3OutcomeMessage(outcome.kind));
  }

  String _tier3OutcomeMessage(
    Tier3GenerationOutcomeKind kind,
  ) => switch (kind) {
    Tier3GenerationOutcomeKind.generated => 'AI insights refreshed.',
    Tier3GenerationOutcomeKind.insufficientEvidence =>
      'Add a little more connected memory before asking AI for an insight.',
    Tier3GenerationOutcomeKind.missingKey =>
      'Add a key for this provider in AI settings first.',
    Tier3GenerationOutcomeKind.spendBlocked =>
      'Your AI spend cap blocked this request.',
    Tier3GenerationOutcomeKind.providerFailure =>
      'The AI provider is unavailable right now. Your memories were not changed.',
    Tier3GenerationOutcomeKind.invalidOutput =>
      'The provider response could not be safely tied back to your memories.',
  };

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: MobileInsightsScreen.screenKey,
      appBar: AppBar(
        title: const Text('Insights'),
        actions: [
          IconButton(
            tooltip: 'Generate AI insights',
            onPressed: _generatingTier3 ? null : _generateTier3,
            icon: _generatingTier3
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome_rounded),
          ),
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
                  'Nothing needs your attention right now. Local insights appear automatically; AI insights are always generated only when you ask.',
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
                onDismissed: (_) =>
                    _replaceFuture(_controller.dismiss(insight.fingerprint)),
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
                        if (insight.isAiGenerated) ...[
                          Text(
                            'Why am I seeing this?',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: MindlySpacing.sm),
                        ],
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
                          insight.isAiGenerated
                              ? 'AI-GENERATED · TIER3 · ${insight.kind.displayName}'
                              : '${insight.tier.name.toUpperCase()} · ${insight.kind.displayName}',
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
