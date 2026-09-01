import 'package:flutter/material.dart';
import 'package:mindly/features/ai_settings/application/provider_settings_controller.dart';
import 'package:mindly/features/notifications/application/notification_controller.dart';
import 'package:mindly/screens/desktop/settings/desktop_notification_settings_screen.dart';
import 'package:mindly/screens/desktop/settings/desktop_provider_settings_screen.dart';

class DesktopSettingsScreen extends StatelessWidget {
  const DesktopSettingsScreen({
    super.key,
    this.providerController,
    required this.notificationController,
  });

  static const screenKey = ValueKey<String>('screen-desktop-settings');

  final ProviderSettingsController? providerController;
  final NotificationController notificationController;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: screenKey,
        appBar: AppBar(
          title: const Text('Settings'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.key_rounded), text: 'AI & spend'),
              Tab(
                icon: Icon(Icons.notifications_none_rounded),
                text: 'Notifications',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            DesktopProviderSettingsScreen(
              controller: providerController,
              embedded: true,
            ),
            DesktopNotificationSettingsScreen(
              controller: notificationController,
              embedded: true,
            ),
          ],
        ),
      ),
    );
  }
}
