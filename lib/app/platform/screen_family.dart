import 'package:flutter/foundation.dart';

enum ScreenFamily { mobile, desktop, web }

ScreenFamily resolveScreenFamily({
  bool? isWebOverride,
  TargetPlatform? platformOverride,
}) {
  if (isWebOverride ?? kIsWeb) {
    return ScreenFamily.web;
  }

  final platform = platformOverride ?? defaultTargetPlatform;
  return switch (platform) {
    TargetPlatform.android || TargetPlatform.iOS => ScreenFamily.mobile,
    TargetPlatform.windows ||
    TargetPlatform.macOS ||
    TargetPlatform.linux => ScreenFamily.desktop,
    TargetPlatform.fuchsia => ScreenFamily.mobile,
  };
}
