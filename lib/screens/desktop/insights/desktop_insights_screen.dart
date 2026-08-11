import 'package:flutter/material.dart';
import 'package:mindly/features/insights/application/insight_controller.dart';
import 'package:mindly/features/insights/domain/insight_models.dart';
import 'package:mindly/features/memory/domain/memory_models.dart';
import 'package:mindly/shared/design_tokens/mindly_spacing.dart';
import 'package:mindly/shared/widgets/mindly_brand_badge.dart';

class DesktopInsightsScreen extends StatefulWidget {
  const DesktopInsightsScreen({super.key, this.controller});

  static const screenKey = ValueKey<String>('screen-desktop-insights');

  final InsightController? controller;

  @override
  State<DesktopInsightsScreen> createState() => _DesktopInsightsScreenState();
}

class _DesktopInsightsScreenState extends State<DesktopInsightsScreen> {
  late final InsightController _controller;
  late Future<List<ProactiveInsight>> _insightsFuture;
  ProactiveInsight? _selected;
  bool _generatingTier3 = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? InsightController.production();
    _insightsFuture = _controller.load();
  }

  void _replaceFuture(Future<List<ProactiveInsight>> future) {
    setState(() {
      _selected = null;
      _insightsFuture = future;
    });
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
    final profile = await showDialog<Tier3ProviderProfile>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Choose your AI provider'),
        children: [
          SimpleDialogOption(
            onPressed: () =>
                Navigator.of(context).pop(Tier3ProviderProfile.openAiDefault),
            child: ListTile(
              leading: const Icon(Icons.auto_awesome_rounded),
              title: const Text('OpenAI'),
              subtitle: Text(Tier3ProviderProfile.openAiDefault.rateCard.model),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(
              context,
            ).pop(Tier3ProviderProfile.anthropicDefault),
            child: ListTile(
              leading: const Icon(Icons.auto_awesome_outlined),
              title: const Text('Anthropic'),
              subtitle: Text(
                Tier3ProviderProfile.anthropicDefault.rateCard.model,
              ),
            ),
          ),
        ],
      ),
    );
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
          'Mindly will send a bounded set of relevant memories directly to ${profile.configuration.displayName}. '
          'Estimated maximum cost: \$${estimate.estimatedUsd.toStringAsFixed(4)}. Existing spend caps still apply.',
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
    } else {
      _showMessage(_tier3OutcomeMessage(outcome.kind));
    }
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
      key: DesktopInsightsScreen.screenKey,
      body: Row(
        children: [
          SizedBox(
            width: 220,
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
                  const Text(
                    'Local signals appear automatically. Predictive AI insights are generated only when you ask.',
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _generatingTier3 ? null : _generateTier3,
                    icon: _generatingTier3
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome_rounded),
                    label: const Text('Ask AI'),
                  ),
                  const SizedBox(height: MindlySpacing.sm),
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
                final insights = snapshot.data ?? const <ProactiveInsight>[];
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
                        trailing: Text(
                          insight.isAiGenerated
                              ? 'AI · TIER3'
                              : insight.tier.name.toUpperCase(),
                        ),
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
            width: 360,
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
                    onDismiss: () => _replaceFuture(
                      _controller.dismiss(_selected!.fingerprint),
                    ),
                    onMute: () => _replaceFuture(
                      _controller.setMuted(_selected!.kind, true),
                    ),
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
          if (insight.isAiGenerated) ...[
            const Chip(label: Text('AI-generated')),
            const SizedBox(height: MindlySpacing.sm),
          ],
          Text(insight.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: MindlySpacing.sm),
          Text(insight.body),
          const SizedBox(height: MindlySpacing.lg),
          Text(
            insight.isAiGenerated ? 'Why am I seeing this?' : 'Sources',
            style: Theme.of(context).textTheme.titleMedium,
          ),
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
