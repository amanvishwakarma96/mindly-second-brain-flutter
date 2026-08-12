import 'package:flutter/material.dart';
import 'package:mindly/features/notifications/application/notification_controller.dart';
import 'package:mindly/shared/design_tokens/mindly_spacing.dart';
import 'package:mindly/shared/widgets/mindly_brand_badge.dart';

class WebNotificationSettingsScreen extends StatelessWidget {
  const WebNotificationSettingsScreen({
    super.key,
    required this.controller,
  });

  static const screenKey = ValueKey<String>('screen-web-notification-settings');

  final NotificationController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: WebNotificationSettingsScreen.screenKey,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MindlyBrandBadge(),
            SizedBox(width: MindlySpacing.sm),
            Text('Notifications'),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(MindlySpacing.xl),
          child: SizedBox(
            width: 680,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(MindlySpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.notifications_off_outlined, size: 36),
                    const SizedBox(height: MindlySpacing.md),
                    Text(
                      'Scheduled notifications are a native-app feature',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: MindlySpacing.md),
                    Text(controller.capabilities.message),
                    const SizedBox(height: MindlySpacing.md),
                    const Text(
                      'Mindly does not request browser notification permission in Phase 8 because browsers cannot reliably schedule or repeat local notifications. Use an Android, iOS, macOS, or Windows build for scheduled digests and Tier 2 alerts.',
                    ),
                    const SizedBox(height: MindlySpacing.md),
                    const Text(
                      'Cross-device push remains part of the later optional sync milestone; no notification backend is introduced here.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
