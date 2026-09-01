import 'package:flutter/material.dart';
import 'package:mindly/app/app_routes.dart';
import 'package:mindly/features/home/application/home_presenter.dart';
import 'package:mindly/screens/mobile/widgets/mobile_primary_navigation.dart';
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
            child: InkWell(
              key: const ValueKey<String>('mobile-quick-text-capture'),
              borderRadius: BorderRadius.circular(12),
              onTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.textCapture),
              child: const Padding(
                padding: EdgeInsets.all(MindlySpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quick capture'),
                    SizedBox(height: MindlySpacing.sm),
                    Text('Jot down a thought before it wanders off.'),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: MindlySpacing.md),
          Card(
            color: MindlyColors.peach,
            child: InkWell(
              key: const ValueKey<String>('mobile-quick-audio-capture'),
              borderRadius: BorderRadius.circular(12),
              onTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.audioCapture),
              child: const Padding(
                padding: EdgeInsets.all(MindlySpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Record a thought'),
                    SizedBox(height: MindlySpacing.sm),
                    Text(
                      'Capture audio now and transcribe it when you are ready.',
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: MindlySpacing.md),
          Card(
            child: ListTile(
              leading: const Icon(Icons.auto_awesome_rounded),
              title: const Text('Local insights'),
              subtitle: const Text('See what your saved memories suggest.'),
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.insights),
            ),
          ),
          const SizedBox(height: MindlySpacing.md),
          Card(
            child: ListTile(
              leading: const Icon(Icons.settings_rounded),
              title: const Text('Settings'),
              subtitle: const Text(
                'Manage AI providers, spend limits, and notifications.',
              ),
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.settings),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const MobilePrimaryNavigation(selectedIndex: 0),
    );
  }
}
