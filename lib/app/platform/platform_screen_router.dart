import 'package:flutter/widgets.dart';
import 'package:mindly/app/platform/screen_family.dart';
import 'package:mindly/features/ai_settings/application/provider_settings_controller.dart';
import 'package:mindly/features/audio_capture/application/audio_capture_controller.dart';
import 'package:mindly/features/text_capture/application/text_capture_controller.dart';
import 'package:mindly/screens/desktop/capture/desktop_audio_capture_screen.dart';
import 'package:mindly/screens/desktop/capture/desktop_text_capture_screen.dart';
import 'package:mindly/screens/desktop/home/desktop_home_screen.dart';
import 'package:mindly/screens/desktop/settings/desktop_provider_settings_screen.dart';
import 'package:mindly/screens/mobile/capture/mobile_audio_capture_screen.dart';
import 'package:mindly/screens/mobile/capture/mobile_text_capture_screen.dart';
import 'package:mindly/screens/mobile/home/mobile_home_screen.dart';
import 'package:mindly/screens/mobile/settings/mobile_provider_settings_screen.dart';
import 'package:mindly/screens/web/capture/web_audio_capture_screen.dart';
import 'package:mindly/screens/web/capture/web_text_capture_screen.dart';
import 'package:mindly/screens/web/home/web_home_screen.dart';
import 'package:mindly/screens/web/settings/web_provider_settings_screen.dart';

Widget buildPlatformHome(ScreenFamily family) => switch (family) {
  ScreenFamily.mobile => const MobileHomeScreen(),
  ScreenFamily.desktop => const DesktopHomeScreen(),
  ScreenFamily.web => const WebHomeScreen(),
};

Widget buildPlatformTextCapture(ScreenFamily family, {TextCaptureController? controller}) => switch (family) {
  ScreenFamily.mobile => MobileTextCaptureScreen(controller: controller),
  ScreenFamily.desktop => DesktopTextCaptureScreen(controller: controller),
  ScreenFamily.web => WebTextCaptureScreen(controller: controller),
};

Widget buildPlatformAudioCapture(ScreenFamily family, {AudioCaptureController? controller}) => switch (family) {
  ScreenFamily.mobile => MobileAudioCaptureScreen(controller: controller),
  ScreenFamily.desktop => DesktopAudioCaptureScreen(controller: controller),
  ScreenFamily.web => WebAudioCaptureScreen(controller: controller),
};

Widget buildPlatformProviderSettings(ScreenFamily family, {ProviderSettingsController? controller}) => switch (family) {
  ScreenFamily.mobile => MobileProviderSettingsScreen(controller: controller),
  ScreenFamily.desktop => DesktopProviderSettingsScreen(controller: controller),
  ScreenFamily.web => WebProviderSettingsScreen(controller: controller),
};
