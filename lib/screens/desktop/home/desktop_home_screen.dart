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
          const SizedBox(width: 220, child: _DesktopSidebar()),
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
                  Expanded(
                    child: Card(
                      color: MindlyColors.mint,
                      child: Center(
                        child: FilledButton.icon(
                          onPressed: () => Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.textCapture),
                          icon: const Icon(Icons.edit_note_rounded),
                          label: const Text('Capture a thought'),
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
            width: 280,
            child: Padding(
              padding: EdgeInsets.all(MindlySpacing.lg),
              child: Text('Details and connections'),
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
          const ListTile(
            leading: Icon(Icons.home_rounded),
            title: Text('Home'),
          ),
          ListTile(
            leading: const Icon(Icons.edit_note_rounded),
            title: const Text('Capture'),
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.textCapture),
          ),
          const ListTile(
            leading: Icon(Icons.auto_stories_rounded),
            title: Text('Memory'),
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.settings_rounded),
            title: const Text('Settings'),
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.providerSettings),
          ),
        ],
      ),
    );
  }
}
