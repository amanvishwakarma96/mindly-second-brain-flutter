import 'package:flutter/material.dart';
import 'package:mindly/app/app_routes.dart';
import 'package:mindly/screens/mobile/widgets/mobile_primary_navigation.dart';
import 'package:mindly/shared/design_tokens/mindly_spacing.dart';

class MobileSettingsScreen extends StatelessWidget {
  const MobileSettingsScreen({super.key});

  static const screenKey = ValueKey<String>('screen-mobile-settings');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: screenKey,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(MindlySpacing.md),
        children: [
          Text(
            'Make Mindly work your way',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: MindlySpacing.sm),
          const Text(
            'Your provider, spend limits, and notification choices stay under your control.',
          ),
          const SizedBox(height: MindlySpacing.lg),
          Card(
            child: ListTile(
              leading: const Icon(Icons.key_rounded),
              title: const Text('AI provider & spend'),
              subtitle: const Text(
                'Keys, provider choice, and spending limits',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.providerSettings),
            ),
          ),
          const SizedBox(height: MindlySpacing.sm),
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications_none_rounded),
              title: const Text('Notifications'),
              subtitle: const Text('Digests, pattern alerts, and quiet hours'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(
                context,
              ).pushNamed(AppRoutes.notificationSettings),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const MobilePrimaryNavigation(selectedIndex: 4),
    );
  }
}
