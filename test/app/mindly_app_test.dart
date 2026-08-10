import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindly/app/mindly_app.dart';
import 'package:mindly/app/platform/screen_family.dart';
import 'package:mindly/screens/desktop/home/desktop_home_screen.dart';
import 'package:mindly/screens/mobile/home/mobile_home_screen.dart';
import 'package:mindly/screens/web/home/web_home_screen.dart';

void main() {
  for (final testCase in <(ScreenFamily, Key, Key, Key)>[
    (
      ScreenFamily.mobile,
      MobileHomeScreen.screenKey,
      DesktopHomeScreen.screenKey,
      WebHomeScreen.screenKey,
    ),
    (
      ScreenFamily.desktop,
      DesktopHomeScreen.screenKey,
      MobileHomeScreen.screenKey,
      WebHomeScreen.screenKey,
    ),
    (
      ScreenFamily.web,
      WebHomeScreen.screenKey,
      MobileHomeScreen.screenKey,
      DesktopHomeScreen.screenKey,
    ),
  ]) {
    testWidgets('${testCase.$1.name} loads only its own home screen', (
      tester,
    ) async {
      await tester.pumpWidget(MindlyApp(screenFamilyOverride: testCase.$1));

      expect(find.byKey(testCase.$2), findsOneWidget);
      expect(find.byKey(testCase.$3), findsNothing);
      expect(find.byKey(testCase.$4), findsNothing);
    });
  }
}
