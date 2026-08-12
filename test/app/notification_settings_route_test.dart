import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindly/app/app_routes.dart';
import 'package:mindly/app/mindly_app.dart';
import 'package:mindly/app/platform/screen_family.dart';
import 'package:mindly/features/notifications/application/notification_controller.dart';
import 'package:mindly/features/notifications/domain/notification_models.dart';
import 'package:mindly/screens/desktop/home/desktop_home_screen.dart';
import 'package:mindly/screens/desktop/settings/desktop_notification_settings_screen.dart';
import 'package:mindly/screens/mobile/home/mobile_home_screen.dart';
import 'package:mindly/screens/mobile/settings/mobile_notification_settings_screen.dart';
import 'package:mindly/screens/web/home/web_home_screen.dart';
import 'package:mindly/screens/web/settings/web_notification_settings_screen.dart';

void main() {
  final cases = <ScreenFamily, ({Key homeKey, Key targetKey})>{
    ScreenFamily.mobile: (
      homeKey: MobileHomeScreen.screenKey,
      targetKey: MobileNotificationSettingsScreen.screenKey,
    ),
    ScreenFamily.desktop: (
      homeKey: DesktopHomeScreen.screenKey,
      targetKey: DesktopNotificationSettingsScreen.screenKey,
    ),
    ScreenFamily.web: (
      homeKey: WebHomeScreen.screenKey,
      targetKey: WebNotificationSettingsScreen.screenKey,
    ),
  };

  for (final entry in cases.entries) {
    testWidgets('${entry.key.name} routes to its own notification settings', (
      tester,
    ) async {
      final controller = _FakeNotificationController(
        canSchedule: entry.key != ScreenFamily.web,
      );
      await tester.pumpWidget(
        MindlyApp(
          screenFamilyOverride: entry.key,
          notificationControllerOverride: controller,
        ),
      );
      await tester.pump();

      final homeFinder = find.byKey(entry.value.homeKey);
      expect(homeFinder, findsOneWidget);
      Navigator.of(
        tester.element(homeFinder),
      ).pushNamed(AppRoutes.notificationSettings);
      await tester.pumpAndSettle();

      expect(find.byKey(entry.value.targetKey), findsOneWidget);
      final otherKeys = <Key>{
        MobileNotificationSettingsScreen.screenKey,
        DesktopNotificationSettingsScreen.screenKey,
        WebNotificationSettingsScreen.screenKey,
      }..remove(entry.value.targetKey);
      for (final key in otherKeys) {
        expect(find.byKey(key), findsNothing);
      }
    });
  }
}

class _FakeNotificationController implements NotificationController {
  _FakeNotificationController({required bool canSchedule})
    : capabilities = NotificationCapabilities(
        platform: canSchedule
            ? MindlyNotificationPlatform.android
            : MindlyNotificationPlatform.web,
        canSchedule: canSchedule,
        canShowImmediate: canSchedule,
        message: canSchedule
            ? 'Local scheduling is available.'
            : 'Scheduled notifications are unavailable on Web.',
      );

  @override
  final NotificationCapabilities capabilities;

  @override
  Future<void> initializeAndReconcile() async {}

  @override
  Future<NotificationPreferences> loadPreferences() async =>
      const NotificationPreferences();

  @override
  Future<void> reconcile() async {}

  @override
  Future<NotificationSaveOutcome> savePreferences(
    NotificationPreferences preferences,
  ) async => const NotificationSaveOutcome(NotificationSaveOutcomeKind.saved);
}
