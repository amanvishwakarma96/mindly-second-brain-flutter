import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindly/app/platform/screen_family.dart';

void main() {
  group('resolveScreenFamily', () {
    test('web override always selects web', () {
      expect(
        resolveScreenFamily(
          isWebOverride: true,
          platformOverride: TargetPlatform.android,
        ),
        ScreenFamily.web,
      );
    });

    test('Android and iOS select mobile screens', () {
      for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
        expect(
          resolveScreenFamily(isWebOverride: false, platformOverride: platform),
          ScreenFamily.mobile,
        );
      }
    });

    test('Windows, macOS and Linux select desktop screens', () {
      for (final platform in [
        TargetPlatform.windows,
        TargetPlatform.macOS,
        TargetPlatform.linux,
      ]) {
        expect(
          resolveScreenFamily(isWebOverride: false, platformOverride: platform),
          ScreenFamily.desktop,
        );
      }
    });
  });
}
