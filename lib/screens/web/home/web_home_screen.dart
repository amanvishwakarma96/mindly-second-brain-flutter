import 'package:flutter/material.dart';
import 'package:mindly/app/app_routes.dart';
import 'package:mindly/features/home/application/home_presenter.dart';
import 'package:mindly/shared/design_tokens/mindly_colors.dart';
import 'package:mindly/shared/design_tokens/mindly_spacing.dart';
import 'package:mindly/shared/widgets/mindly_brand_badge.dart';

class WebHomeScreen extends StatelessWidget {
  const WebHomeScreen({super.key});

  static const screenKey = ValueKey<String>('screen-web-home');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: screenKey,
      body: LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth < 760
            ? const _NarrowWebHome()
            : const _WideWebHome(),
      ),
    );
  }
}

class _WideWebHome extends StatelessWidget {
  const _WideWebHome();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 200,
          child: Padding(
            padding: const EdgeInsets.all(MindlySpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MindlyBrandBadge(),
                const SizedBox(height: MindlySpacing.xl),
                const Text('Home'),
                const SizedBox(height: MindlySpacing.md),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.textCapture),
                  child: const Text('Text capture'),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.audioCapture),
                  child: const Text('Audio capture'),
                ),
                const SizedBox(height: MindlySpacing.md),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.memory),
                  child: const Text('Memory'),
                ),
                const SizedBox(height: MindlySpacing.md),
                const Text('Insights'),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.providerSettings),
                  icon: const Icon(Icons.settings_rounded),
                  label: const Text('Settings'),
                ),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(MindlySpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  HomePresenter.greeting,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: MindlySpacing.sm),
                Text(HomePresenter.prompt),
                const SizedBox(height: MindlySpacing.xl),
                Card(
                  color: MindlyColors.peach,
                  child: Padding(
                    padding: const EdgeInsets.all(MindlySpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Capture in the browser while your memories stay local.',
                        ),
                        const SizedBox(height: MindlySpacing.md),
                        Wrap(
                          spacing: MindlySpacing.md,
                          children: [
                            FilledButton.icon(
                              onPressed: () => Navigator.of(
                                context,
                              ).pushNamed(AppRoutes.textCapture),
                              icon: const Icon(Icons.edit_note_rounded),
                              label: const Text('Write'),
                            ),
                            FilledButton.icon(
                              onPressed: () => Navigator.of(
                                context,
                              ).pushNamed(AppRoutes.audioCapture),
                              icon: const Icon(Icons.mic_rounded),
                              label: const Text('Record'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () =>
                                  Navigator.of(context).pushNamed(AppRoutes.memory),
                              icon: const Icon(Icons.auto_stories_rounded),
                              label: const Text('Browse memory'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NarrowWebHome extends StatelessWidget {
  const _NarrowWebHome();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(MindlySpacing.md),
      children: [
        const MindlyBrandBadge(),
        const SizedBox(height: MindlySpacing.xl),
        Text(
          HomePresenter.greeting,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: MindlySpacing.sm),
        Text(HomePresenter.prompt),
        const SizedBox(height: MindlySpacing.lg),
        const Card(
          color: MindlyColors.peach,
          child: Padding(
            padding: EdgeInsets.all(MindlySpacing.lg),
            child: Text('The web layout has collapsed for this browser width.'),
          ),
        ),
        const SizedBox(height: MindlySpacing.md),
        FilledButton.icon(
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoutes.textCapture),
          icon: const Icon(Icons.edit_note_rounded),
          label: const Text('Text capture'),
        ),
        const SizedBox(height: MindlySpacing.sm),
        FilledButton.icon(
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoutes.audioCapture),
          icon: const Icon(Icons.mic_rounded),
          label: const Text('Audio capture'),
        ),
        const SizedBox(height: MindlySpacing.sm),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.memory),
          icon: const Icon(Icons.auto_stories_rounded),
          label: const Text('Browse memory'),
        ),
        const SizedBox(height: MindlySpacing.sm),
        OutlinedButton.icon(
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoutes.providerSettings),
          icon: const Icon(Icons.settings_rounded),
          label: const Text('AI provider settings'),
        ),
      ],
    );
  }
}
