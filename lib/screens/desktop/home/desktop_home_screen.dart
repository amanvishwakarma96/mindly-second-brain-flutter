import 'package:flutter/material.dart';
import 'package:mindly/app/app_routes.dart';
import 'package:mindly/features/home/application/home_presenter.dart';
import 'package:mindly/shared/design_tokens/mindly_colors.dart';
import 'package:mindly/shared/design_tokens/mindly_spacing.dart';
import 'package:mindly/shared/widgets/mindly_brand_badge.dart';

class DesktopHomeScreen extends StatelessWidget {
  const DesktopHomeScreen({super.key});

  static const screenKey = ValueKey<String>('screen-desktop-home');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: screenKey,
      body: Row(
        children: [
          const SizedBox(
            key: ValueKey<String>('desktop-home-sidebar'),
            width: 220,
            child: _DesktopSidebar(),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            key: const ValueKey<String>('desktop-home-main'),
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
                  Expanded(
                    child: Card(
                      color: MindlyColors.mint,
                      child: Center(
                        child: Wrap(
                          spacing: MindlySpacing.md,
                          runSpacing: MindlySpacing.md,
                          children: [
                            FilledButton.icon(
                              onPressed: () => Navigator.of(
                                context,
                              ).pushNamed(AppRoutes.textCapture),
                              icon: const Icon(Icons.edit_note_rounded),
                              label: const Text('Write a thought'),
                            ),
                            FilledButton.icon(
                              onPressed: () => Navigator.of(
                                context,
                              ).pushNamed(AppRoutes.audioCapture),
                              icon: const Icon(Icons.mic_rounded),
                              label: const Text('Record a thought'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => Navigator.of(
                                context,
                              ).pushNamed(AppRoutes.memory),
                              icon: const Icon(Icons.auto_stories_rounded),
                              label: const Text('Browse memory'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => Navigator.of(
                                context,
                              ).pushNamed(AppRoutes.insights),
                              icon: const Icon(Icons.auto_awesome_rounded),
                              label: const Text('Review insights'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => Navigator.of(
                                context,
                              ).pushNamed(AppRoutes.settings),
                              icon: const Icon(Icons.settings_rounded),
                              label: const Text('Settings'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          const SizedBox(
            key: ValueKey<String>('desktop-home-detail'),
            width: 280,
            child: Padding(
              padding: EdgeInsets.all(MindlySpacing.lg),
              child: Text(
                'Review space\n\nOpen Memory or Insights to inspect sources and connections without leaving the desktop workflow.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(MindlySpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MindlyBrandBadge(),
          const SizedBox(height: MindlySpacing.xl),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const ListTile(
                  leading: Icon(Icons.home_rounded),
                  title: Text('Home'),
                ),
                ListTile(
                  leading: const Icon(Icons.edit_note_rounded),
                  title: const Text('Text capture'),
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.textCapture),
                ),
                ListTile(
                  leading: const Icon(Icons.mic_rounded),
                  title: const Text('Audio capture'),
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.audioCapture),
                ),
                ListTile(
                  leading: const Icon(Icons.auto_stories_rounded),
                  title: const Text('Memory'),
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.memory),
                ),
                ListTile(
                  leading: const Icon(Icons.auto_awesome_rounded),
                  title: const Text('Insights'),
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.insights),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings_rounded),
            title: const Text('Settings'),
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.settings),
          ),
        ],
      ),
    );
  }
}
