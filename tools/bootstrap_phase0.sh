#!/usr/bin/env bash
set -euo pipefail

mkdir -p \
  lib/app/platform \
  lib/core \
  lib/features/home/application \
  lib/shared/design_tokens \
  lib/shared/widgets \
  lib/screens/mobile/home \
  lib/screens/desktop/home \
  lib/screens/web/home \
  test/app/platform \
  test/app \
  test/architecture \
  docs/architecture

cat > lib/main.dart <<'DART'
import 'package:flutter/widgets.dart';
import 'package:mindly/app/mindly_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MindlyApp());
}
DART

cat > lib/app/platform/screen_family.dart <<'DART'
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
    TargetPlatform.windows || TargetPlatform.macOS || TargetPlatform.linux =>
      ScreenFamily.desktop,
    TargetPlatform.fuchsia => ScreenFamily.mobile,
  };
}
DART

cat > lib/app/platform/platform_screen_router.dart <<'DART'
import 'package:flutter/widgets.dart';
import 'package:mindly/app/platform/screen_family.dart';
import 'package:mindly/screens/desktop/home/desktop_home_screen.dart';
import 'package:mindly/screens/mobile/home/mobile_home_screen.dart';
import 'package:mindly/screens/web/home/web_home_screen.dart';

Widget buildPlatformHome(ScreenFamily family) {
  return switch (family) {
    ScreenFamily.mobile => const MobileHomeScreen(),
    ScreenFamily.desktop => const DesktopHomeScreen(),
    ScreenFamily.web => const WebHomeScreen(),
  };
}
DART

cat > lib/app/mindly_app.dart <<'DART'
import 'package:flutter/material.dart';
import 'package:mindly/app/platform/platform_screen_router.dart';
import 'package:mindly/app/platform/screen_family.dart';
import 'package:mindly/shared/design_tokens/mindly_theme.dart';

class MindlyApp extends StatelessWidget {
  const MindlyApp({super.key, this.screenFamilyOverride});

  final ScreenFamily? screenFamilyOverride;

  @override
  Widget build(BuildContext context) {
    final family = screenFamilyOverride ?? resolveScreenFamily();

    return MaterialApp(
      title: 'Mindly',
      debugShowCheckedModeBanner: false,
      theme: MindlyTheme.light(),
      home: buildPlatformHome(family),
    );
  }
}
DART

cat > lib/core/app_info.dart <<'DART'
abstract final class AppInfo {
  static const String name = 'Mindly';
  static const String tagline =
      'A private place for the things worth remembering.';
}
DART

cat > lib/features/home/application/home_presenter.dart <<'DART'
import 'package:mindly/core/app_info.dart';

abstract final class HomePresenter {
  static const String brand = AppInfo.name;
  static const String greeting = 'Good to see you.';
  static const String prompt = 'What would you like me to remember?';
}
DART

cat > lib/shared/design_tokens/mindly_colors.dart <<'DART'
import 'package:flutter/material.dart';

abstract final class MindlyColors {
  static const Color ink = Color(0xFF25232A);
  static const Color canvas = Color(0xFFFFFBF7);
  static const Color lavender = Color(0xFFE9E1FF);
  static const Color mint = Color(0xFFDDF5E8);
  static const Color peach = Color(0xFFFFE5D5);
}
DART

cat > lib/shared/design_tokens/mindly_spacing.dart <<'DART'
abstract final class MindlySpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}
DART

cat > lib/shared/design_tokens/mindly_theme.dart <<'DART'
import 'package:flutter/material.dart';
import 'package:mindly/shared/design_tokens/mindly_colors.dart';

abstract final class MindlyTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: MindlyColors.lavender,
      brightness: Brightness.light,
      surface: MindlyColors.canvas,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: MindlyColors.canvas,
      cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
    );
  }
}
DART

cat > lib/shared/widgets/mindly_brand_badge.dart <<'DART'
import 'package:flutter/material.dart';
import 'package:mindly/shared/design_tokens/mindly_colors.dart';
import 'package:mindly/shared/design_tokens/mindly_spacing.dart';

class MindlyBrandBadge extends StatelessWidget {
  const MindlyBrandBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MindlySpacing.md,
        vertical: MindlySpacing.sm,
      ),
      decoration: BoxDecoration(
        color: MindlyColors.lavender,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text('Mindly ✦'),
    );
  }
}
DART

cat > lib/screens/mobile/home/mobile_home_screen.dart <<'DART'
import 'package:flutter/material.dart';
import 'package:mindly/features/home/application/home_presenter.dart';
import 'package:mindly/shared/design_tokens/mindly_colors.dart';
import 'package:mindly/shared/design_tokens/mindly_spacing.dart';
import 'package:mindly/shared/widgets/mindly_brand_badge.dart';

class MobileHomeScreen extends StatelessWidget {
  const MobileHomeScreen({super.key});

  static const screenKey = ValueKey<String>('screen-mobile-home');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: screenKey,
      appBar: AppBar(title: const MindlyBrandBadge()),
      body: ListView(
        padding: const EdgeInsets.all(MindlySpacing.md),
        children: [
          Text(
            HomePresenter.greeting,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: MindlySpacing.sm),
          Text(HomePresenter.prompt),
          const SizedBox(height: MindlySpacing.lg),
          Card(
            color: MindlyColors.mint,
            child: Padding(
              padding: const EdgeInsets.all(MindlySpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick capture',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: MindlySpacing.sm),
                  const Text('Jot down a thought before it wanders off.'),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.mic_rounded), label: 'Capture'),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_rounded),
            label: 'Memory',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
DART

cat > lib/screens/desktop/home/desktop_home_screen.dart <<'DART'
import 'package:flutter/material.dart';
import 'package:mindly/features/home/application/home_presenter.dart';
import 'package:mindly/shared/design_tokens/mindly_colors.dart';
import 'package:mindly/shared/design_tokens/mindly_spacing.dart';
import 'package:mindly/shared/widgets/mindly_brand_badge.dart';

class DesktopHomeScreen extends StatelessWidget {
  const DesktopHomeScreen({super.key});

  static const screenKey = ValueKey<String>('screen-desktop-home');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: screenKey,
      body: Row(
        children: [
          const SizedBox(width: 220, child: _DesktopSidebar()),
          const VerticalDivider(width: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(MindlySpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    HomePresenter.greeting,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: MindlySpacing.sm),
                  Text(HomePresenter.prompt),
                  const SizedBox(height: MindlySpacing.xl),
                  Expanded(
                    child: Card(
                      color: MindlyColors.mint,
                      child: const Center(
                        child: Text('Your review space will grow here.'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          const SizedBox(
            width: 280,
            child: Padding(
              padding: EdgeInsets.all(MindlySpacing.lg),
              child: Text('Details and connections'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(MindlySpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MindlyBrandBadge(),
          SizedBox(height: MindlySpacing.xl),
          ListTile(leading: Icon(Icons.home_rounded), title: Text('Home')),
          ListTile(leading: Icon(Icons.mic_rounded), title: Text('Capture')),
          ListTile(
            leading: Icon(Icons.auto_stories_rounded),
            title: Text('Memory'),
          ),
          Spacer(),
          ListTile(leading: Icon(Icons.settings_rounded), title: Text('Settings')),
        ],
      ),
    );
  }
}
DART

cat > lib/screens/web/home/web_home_screen.dart <<'DART'
import 'package:flutter/material.dart';
import 'package:mindly/features/home/application/home_presenter.dart';
import 'package:mindly/shared/design_tokens/mindly_colors.dart';
import 'package:mindly/shared/design_tokens/mindly_spacing.dart';
import 'package:mindly/shared/widgets/mindly_brand_badge.dart';

class WebHomeScreen extends StatelessWidget {
  const WebHomeScreen({super.key});

  static const screenKey = ValueKey<String>('screen-web-home');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: screenKey,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return constraints.maxWidth < 760
              ? const _NarrowWebHome()
              : const _WideWebHome();
        },
      ),
    );
  }
}

class _WideWebHome extends StatelessWidget {
  const _WideWebHome();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 200,
          child: Padding(
            padding: EdgeInsets.all(MindlySpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MindlyBrandBadge(),
                SizedBox(height: MindlySpacing.xl),
                Text('Home'),
                SizedBox(height: MindlySpacing.md),
                Text('Capture'),
                SizedBox(height: MindlySpacing.md),
                Text('Memory'),
                SizedBox(height: MindlySpacing.md),
                Text('Insights'),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(MindlySpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  HomePresenter.greeting,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: MindlySpacing.sm),
                Text(HomePresenter.prompt),
                const SizedBox(height: MindlySpacing.xl),
                const Card(
                  color: MindlyColors.peach,
                  child: Padding(
                    padding: EdgeInsets.all(MindlySpacing.lg),
                    child: Text(
                      'A browser-friendly home, with your memories staying local.',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NarrowWebHome extends StatelessWidget {
  const _NarrowWebHome();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(MindlySpacing.md),
      children: [
        const MindlyBrandBadge(),
        const SizedBox(height: MindlySpacing.xl),
        Text(
          HomePresenter.greeting,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: MindlySpacing.sm),
        Text(HomePresenter.prompt),
        const SizedBox(height: MindlySpacing.lg),
        const Card(
          color: MindlyColors.peach,
          child: Padding(
            padding: EdgeInsets.all(MindlySpacing.lg),
            child: Text('The web layout has collapsed for this browser width.'),
          ),
        ),
      ],
    );
  }
}
DART

cat > test/app/platform/screen_family_test.dart <<'DART'
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
          resolveScreenFamily(
            isWebOverride: false,
            platformOverride: platform,
          ),
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
          resolveScreenFamily(
            isWebOverride: false,
            platformOverride: platform,
          ),
          ScreenFamily.desktop,
        );
      }
    });
  });
}
DART

cat > test/app/mindly_app_test.dart <<'DART'
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
DART

cat > test/architecture/platform_screen_boundary_test.dart <<'DART'
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('platform screen folders never import sibling screen folders', () {
    final platformFolders = ['mobile', 'desktop', 'web'];

    for (final platform in platformFolders) {
      final directory = Directory('lib/screens/$platform');
      final forbidden = platformFolders.where((value) => value != platform);

      for (final entity in directory.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) {
          continue;
        }

        final source = entity.readAsStringSync();
        for (final sibling in forbidden) {
          expect(
            source.contains('package:mindly/screens/$sibling/'),
            isFalse,
            reason: '${entity.path} imports the $sibling screen layer.',
          );
        }
      }
    }
  });

  test('shared layers never import platform screens', () {
    for (final root in ['lib/core', 'lib/features', 'lib/shared']) {
      final directory = Directory(root);
      for (final entity in directory.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) {
          continue;
        }

        final source = entity.readAsStringSync();
        expect(
          source.contains('package:mindly/screens/'),
          isFalse,
          reason: '${entity.path} leaks a screen dependency into a shared layer.',
        );
      }
    }
  });
}
DART

cat > docs/architecture/platform-screen-boundary.md <<'MD'
# Platform screen boundary

Mindly deliberately keeps complete screen implementations separate by platform class:

- `lib/screens/mobile/`
- `lib/screens/desktop/`
- `lib/screens/web/`

Shared business logic belongs in `lib/core/` and `lib/features/`. Shared visual language belongs in `lib/shared/design_tokens/`, with intentionally small reusable UI elements in `lib/shared/widgets/`.

`lib/app/platform/platform_screen_router.dart` is the one composition boundary allowed to import all three screen families and select a complete implementation at runtime.

## Enforcement

1. A platform screen folder must never import another platform screen folder.
2. `core`, `features`, and `shared` must never import `screens`.
3. Cross-platform behavior changes in a shared layer instead of being duplicated into screens.
4. Platform-specific layout changes stay inside that platform's screen folder.
5. `test/architecture/platform_screen_boundary_test.dart` enforces rules 1 and 2 in CI.

The extra files are intentional: platform isolation takes priority over layout-code reuse.
MD

cat > README.md <<'MD'
# Mindly

Mindly is a local-first, BYOK second-brain application built with Flutter for iOS, Android, Windows, macOS, Linux, and Web.

## Architecture

```text
lib/
├── app/                      # app composition + platform screen routing
├── core/                     # shared non-UI logic
├── features/                 # shared feature/application logic
├── shared/
│   ├── design_tokens/        # colors, spacing, theme
│   └── widgets/              # small reusable components only
└── screens/
    ├── mobile/               # independent mobile screens
    ├── desktop/              # independent desktop screens
    └── web/                  # independent web screens
```

The platform screen folders are isolated by architecture tests. The runtime routing layer chooses one complete screen family without merging platform layouts.

## Supported targets

Android · iOS · Windows · macOS · Linux · Web

## Development

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Read `docs/architecture/platform-screen-boundary.md` before adding or moving UI code.
MD

rm -f test/widget_test.dart
dart format lib test
