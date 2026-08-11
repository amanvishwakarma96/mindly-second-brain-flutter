import 'package:flutter/material.dart';
import 'package:mindly/app/app_routes.dart';
import 'package:mindly/app/platform/platform_screen_router.dart';
import 'package:mindly/app/platform/screen_family.dart';
import 'package:mindly/features/ai_settings/application/provider_settings_controller.dart';
import 'package:mindly/features/audio_capture/application/audio_capture_controller.dart';
import 'package:mindly/features/text_capture/application/text_capture_controller.dart';
import 'package:mindly/shared/design_tokens/mindly_theme.dart';

class MindlyApp extends StatelessWidget {
  const MindlyApp({
    super.key,
    this.screenFamilyOverride,
    this.providerSettingsControllerOverride,
    this.textCaptureControllerOverride,
    this.audioCaptureControllerOverride,
  });

  final ScreenFamily? screenFamilyOverride;
  final ProviderSettingsController? providerSettingsControllerOverride;
  final TextCaptureController? textCaptureControllerOverride;
  final AudioCaptureController? audioCaptureControllerOverride;

  @override
  Widget build(BuildContext context) {
    final family = screenFamilyOverride ?? resolveScreenFamily();

    return MaterialApp(
      title: 'Mindly',
      debugShowCheckedModeBanner: false,
      theme: MindlyTheme.light(),
      home: buildPlatformHome(family),
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.textCapture) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => buildPlatformTextCapture(
              family,
              controller: textCaptureControllerOverride,
            ),
          );
        }
        if (settings.name == AppRoutes.audioCapture) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => buildPlatformAudioCapture(
              family,
              controller: audioCaptureControllerOverride,
            ),
          );
        }
        if (settings.name == AppRoutes.providerSettings) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => buildPlatformProviderSettings(
              family,
              controller: providerSettingsControllerOverride,
            ),
          );
        }
        return null;
      },
    );
  }
}
