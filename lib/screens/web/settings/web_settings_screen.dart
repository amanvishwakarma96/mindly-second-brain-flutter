import 'package:flutter/material.dart';
import 'package:mindly/app/app_routes.dart';
import 'package:mindly/shared/design_tokens/mindly_spacing.dart';
import 'package:mindly/shared/widgets/mindly_brand_badge.dart';

class WebSettingsScreen extends StatelessWidget {
  const WebSettingsScreen({super.key});

  static const screenKey = ValueKey<String>('screen-web-settings');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: screenKey,
      appBar: AppBar(
        title: const Text('Settings · Mindly'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 760;
          return narrow ? const _NarrowWebSettings() : const _WideWebSettings();
        },
      ),
    );
  }
}

class _WideWebSettings extends StatelessWidget {
  const _WideWebSettings();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Padding(
            key: const ValueKey<String>('web-settings-wide'),
            padding: const EdgeInsets.all(MindlySpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MindlyBrandBadge(),
                const SizedBox(height: MindlySpacing.xl),
                Text(
                  'Your controls, in one place',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: MindlySpacing.sm),
                const Text(
                  'Provider credentials stay in this browser’s storage boundary, and notification capability depends on the browser.',
                ),
                const SizedBox(height: MindlySpacing.xl),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _SettingsCard(
                        icon: Icons.key_rounded,
                        title: 'AI provider & spend',
                        body:
                            'Manage API keys and spending limits. The mandatory browser key-security notice appears before first key entry and remains re-checkable.',
                        buttonLabel: 'Open AI settings',
                        onPressed: () => Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.providerSettings),
                      ),
                    ),
                    const SizedBox(width: MindlySpacing.lg),
                    Expanded(
                      child: _SettingsCard(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifications',
                        body:
                            'Review what scheduled notification behavior this browser can reliably support.',
                        buttonLabel: 'Open notification settings',
                        onPressed: () => Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.notificationSettings),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NarrowWebSettings extends StatelessWidget {
  const _NarrowWebSettings();

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey<String>('web-settings-narrow'),
      padding: const EdgeInsets.all(MindlySpacing.md),
      children: [
        Text('Settings', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: MindlySpacing.sm),
        const Text('Choose what you want to adjust in this browser.'),
        const SizedBox(height: MindlySpacing.lg),
        Card(
          child: ListTile(
            leading: const Icon(Icons.key_rounded),
            title: const Text('AI provider & spend'),
            subtitle: const Text('Keys, browser warning, and spending limits'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.providerSettings),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.notifications_none_rounded),
            title: const Text('Notifications'),
            subtitle: const Text('Browser capability and delivery limits'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.notificationSettings),
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String body;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(MindlySpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: MindlySpacing.md),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: MindlySpacing.sm),
            Text(body),
            const SizedBox(height: MindlySpacing.lg),
            FilledButton(onPressed: onPressed, child: Text(buttonLabel)),
          ],
        ),
      ),
    );
  }
}
