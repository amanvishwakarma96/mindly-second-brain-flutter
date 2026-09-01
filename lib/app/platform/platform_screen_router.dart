import 'package:flutter/widgets.dart';
import 'package:mindly/app/platform/screen_family.dart';
import 'package:mindly/features/ai_settings/application/provider_settings_controller.dart';
import 'package:mindly/features/audio_capture/application/audio_capture_controller.dart';
import 'package:mindly/features/insights/application/insight_controller.dart';
import 'package:mindly/features/memory/application/memory_browser_controller.dart';
import 'package:mindly/features/notifications/application/notification_controller.dart';
import 'package:mindly/features/text_capture/application/text_capture_controller.dart';
import 'package:mindly/screens/desktop/capture/desktop_audio_capture_screen.dart';
import 'package:mindly/screens/desktop/capture/desktop_text_capture_screen.dart';
import 'package:mindly/screens/desktop/home/desktop_home_screen.dart';
import 'package:mindly/screens/desktop/insights/desktop_insights_screen.dart';
import 'package:mindly/screens/desktop/memory/desktop_memory_browser_screen.dart';
import 'package:mindly/screens/desktop/settings/desktop_notification_settings_screen.dart';
import 'package:mindly/screens/desktop/settings/desktop_provider_settings_screen.dart';
import 'package:mindly/screens/desktop/settings/desktop_settings_screen.dart';
import 'package:mindly/screens/mobile/capture/mobile_audio_capture_screen.dart';
import 'package:mindly/screens/mobile/capture/mobile_text_capture_screen.dart';
import 'package:mindly/screens/mobile/home/mobile_home_screen.dart';
import 'package:mindly/screens/mobile/insights/mobile_insights_screen.dart';
import 'package:mindly/screens/mobile/memory/mobile_memory_browser_screen.dart';
import 'package:mindly/screens/mobile/settings/mobile_notification_settings_screen.dart';
import 'package:mindly/screens/mobile/settings/mobile_provider_settings_screen.dart';
import 'package:mindly/screens/mobile/settings/mobile_settings_screen.dart';
import 'package:mindly/screens/web/capture/web_audio_capture_screen.dart';
import 'package:mindly/screens/web/capture/web_text_capture_screen.dart';
import 'package:mindly/screens/web/home/web_home_screen.dart';
import 'package:mindly/screens/web/insights/web_insights_screen.dart';
import 'package:mindly/screens/web/memory/web_memory_browser_screen.dart';
import 'package:mindly/screens/web/settings/web_notification_settings_screen.dart';
import 'package:mindly/screens/web/settings/web_provider_settings_screen.dart';
import 'package:mindly/screens/web/settings/web_settings_screen.dart';

Widget buildPlatformHome(ScreenFamily family) => switch (family) {
  ScreenFamily.mobile => const MobileHomeScreen(),
  ScreenFamily.desktop => const DesktopHomeScreen(),
  ScreenFamily.web => const WebHomeScreen(),
};

Widget buildPlatformTextCapture(
  ScreenFamily family, {
  TextCaptureController? controller,
}) => switch (family) {
  ScreenFamily.mobile => MobileTextCaptureScreen(controller: controller),
  ScreenFamily.desktop => DesktopTextCaptureScreen(controller: controller),
  ScreenFamily.web => WebTextCaptureScreen(controller: controller),
};

Widget buildPlatformAudioCapture(
  ScreenFamily family, {
  AudioCaptureController? controller,
}) => switch (family) {
  ScreenFamily.mobile => MobileAudioCaptureScreen(controller: controller),
  ScreenFamily.desktop => DesktopAudioCaptureScreen(controller: controller),
  ScreenFamily.web => WebAudioCaptureScreen(controller: controller),
};

Widget buildPlatformMemory(
  ScreenFamily family, {
  MemoryBrowserController? controller,
}) => switch (family) {
  ScreenFamily.mobile => MobileMemoryBrowserScreen(controller: controller),
  ScreenFamily.desktop => DesktopMemoryBrowserScreen(controller: controller),
  ScreenFamily.web => WebMemoryBrowserScreen(controller: controller),
};

Widget buildPlatformInsights(
  ScreenFamily family, {
  InsightController? controller,
}) => switch (family) {
  ScreenFamily.mobile => MobileInsightsScreen(controller: controller),
  ScreenFamily.desktop => DesktopInsightsScreen(controller: controller),
  ScreenFamily.web => WebInsightsScreen(controller: controller),
};

Widget buildPlatformSettings(
  ScreenFamily family, {
  ProviderSettingsController? providerController,
  required NotificationController notificationController,
}) => switch (family) {
  ScreenFamily.mobile => const MobileSettingsScreen(),
  ScreenFamily.desktop => DesktopSettingsScreen(
    providerController: providerController,
    notificationController: notificationController,
  ),
  ScreenFamily.web => const WebSettingsScreen(),
};

Widget buildPlatformProviderSettings(
  ScreenFamily family, {
  ProviderSettingsController? controller,
}) => switch (family) {
  ScreenFamily.mobile => MobileProviderSettingsScreen(controller: controller),
  ScreenFamily.desktop => DesktopProviderSettingsScreen(controller: controller),
  ScreenFamily.web => WebProviderSettingsScreen(controller: controller),
};

Widget buildPlatformNotificationSettings(
  ScreenFamily family, {
  required NotificationController controller,
}) => switch (family) {
  ScreenFamily.mobile => MobileNotificationSettingsScreen(
    controller: controller,
  ),
  ScreenFamily.desktop => DesktopNotificationSettingsScreen(
    controller: controller,
  ),
  ScreenFamily.web => WebNotificationSettingsScreen(controller: controller),
};
