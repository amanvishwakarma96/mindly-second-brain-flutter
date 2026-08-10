import 'package:flutter/material.dart';
import 'package:mindly/app/app_routes.dart';
import 'package:mindly/features/home/application/home_presenter.dart';
import 'package:mindly/shared/design_tokens/mindly_colors.dart';
import 'package:mindly/shared/design_tokens/mindly_spacing.dart';
import 'package:mindly/shared/widgets/mindly_brand_badge.dart';

class MobileHomeScreen extends StatelessWidget {
  const MobileHomeScreen({super.key});

  static const screenKey = ValueKey<String>('screen-mobile-home');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: screenKey,
      appBar: AppBar(title: const MindlyBrandBadge()),
      body: ListView(
        padding: const EdgeInsets.all(MindlySpacing.md),
        children: [
          Text(
            HomePresenter.greeting,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: MindlySpacing.sm),
          Text(HomePresenter.prompt),
          const SizedBox(height: MindlySpacing.lg),
          Card(
            color: MindlyColors.mint,
            child: Padding(
              padding: const EdgeInsets.all(MindlySpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick capture',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: MindlySpacing.sm),
                  const Text('Jot down a thought before it wanders off.'),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 3) {
            Navigator.of(context).pushNamed(AppRoutes.providerSettings);
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.mic_rounded),
            label: 'Capture',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_rounded),
            label: 'Memory',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
