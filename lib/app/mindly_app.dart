import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mindly/app/app_routes.dart';
import 'package:mindly/app/platform/platform_screen_router.dart';
import 'package:mindly/app/platform/screen_family.dart';
import 'package:mindly/features/ai_settings/application/provider_settings_controller.dart';
import 'package:mindly/features/audio_capture/application/audio_capture_controller.dart';
import 'package:mindly/features/insights/application/insight_controller.dart';
import 'package:mindly/features/memory/application/memory_browser_controller.dart';
import 'package:mindly/features/notifications/application/notification_controller.dart';
import 'package:mindly/features/text_capture/application/text_capture_controller.dart';
import 'package:mindly/shared/design_tokens/mindly_theme.dart';

class MindlyApp extends StatefulWidget {
  const MindlyApp({
    super.key,
    this.screenFamilyOverride,
    this.providerSettingsControllerOverride,
    this.textCaptureControllerOverride,
    this.audioCaptureControllerOverride,
    this.memoryBrowserControllerOverride,
    this.insightControllerOverride,
    this.notificationControllerOverride,
  });

  final ScreenFamily? screenFamilyOverride;
  final ProviderSettingsController? providerSettingsControllerOverride;
  final TextCaptureController? textCaptureControllerOverride;
  final AudioCaptureController? audioCaptureControllerOverride;
  final MemoryBrowserController? memoryBrowserControllerOverride;
  final InsightController? insightControllerOverride;
  final NotificationController? notificationControllerOverride;

  @override
  State<MindlyApp> createState() => _MindlyAppState();
}

class _MindlyAppState extends State<MindlyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final NotificationController _notificationController;

  @override
  void initState() {
    super.initState();
    _notificationController =
        widget.notificationControllerOverride ??
        NotificationController.production(onOpenRoute: _openNotificationRoute);
    unawaited(_notificationController.initializeAndReconcile());
  }

  void _openNotificationRoute(String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigatorKey.currentState?.pushNamed(route);
    });
  }

  @override
  Widget build(BuildContext context) {
    final family = widget.screenFamilyOverride ?? resolveScreenFamily();

    return MaterialApp(
      navigatorKey: _navigatorKey,
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
              controller: widget.textCaptureControllerOverride,
            ),
          );
        }
        if (settings.name == AppRoutes.audioCapture) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => buildPlatformAudioCapture(
              family,
              controller: widget.audioCaptureControllerOverride,
            ),
          );
        }
        if (settings.name == AppRoutes.memory) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => buildPlatformMemory(
              family,
              controller: widget.memoryBrowserControllerOverride,
            ),
          );
        }
        if (settings.name == AppRoutes.insights) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => buildPlatformInsights(
              family,
              controller: widget.insightControllerOverride,
            ),
          );
        }
        if (settings.name == AppRoutes.providerSettings) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => buildPlatformProviderSettings(
              family,
              controller: widget.providerSettingsControllerOverride,
            ),
          );
        }
        if (settings.name == AppRoutes.notificationSettings) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => buildPlatformNotificationSettings(
              family,
              controller: _notificationController,
            ),
          );
        }
        return null;
      },
    );
  }
}
