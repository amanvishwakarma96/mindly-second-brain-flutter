import 'package:flutter/widgets.dart';
import 'package:mindly/app/platform/screen_family.dart';
import 'package:mindly/features/ai_settings/application/provider_settings_controller.dart';
import 'package:mindly/screens/desktop/home/desktop_home_screen.dart';
import 'package:mindly/screens/desktop/settings/desktop_provider_settings_screen.dart';
import 'package:mindly/screens/mobile/home/mobile_home_screen.dart';
import 'package:mindly/screens/mobile/settings/mobile_provider_settings_screen.dart';
import 'package:mindly/screens/web/home/web_home_screen.dart';
import 'package:mindly/screens/web/settings/web_provider_settings_screen.dart';

Widget buildPlatformHome(ScreenFamily family) {
  return switch (family) {
    ScreenFamily.mobile => const MobileHomeScreen(),
    ScreenFamily.desktop => const DesktopHomeScreen(),
    ScreenFamily.web => const WebHomeScreen(),
  };
}

Widget buildPlatformProviderSettings(
  ScreenFamily family, {
  ProviderSettingsController? controller,
}) {
  return switch (family) {
    ScreenFamily.mobile => MobileProviderSettingsScreen(controller: controller),
    ScreenFamily.desktop => DesktopProviderSettingsScreen(
      controller: controller,
    ),
    ScreenFamily.web => WebProviderSettingsScreen(controller: controller),
  };
}
