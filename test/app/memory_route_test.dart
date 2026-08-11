import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindly/app/app_routes.dart';
import 'package:mindly/app/mindly_app.dart';
import 'package:mindly/app/platform/screen_family.dart';
import 'package:mindly/features/memory/application/memory_browser_controller.dart';
import 'package:mindly/features/memory/domain/memory_models.dart';
import 'package:mindly/screens/desktop/memory/desktop_memory_browser_screen.dart';
import 'package:mindly/screens/mobile/memory/mobile_memory_browser_screen.dart';
import 'package:mindly/screens/web/memory/web_memory_browser_screen.dart';

void main() {
  for (final entry in <ScreenFamily, Key>{
    ScreenFamily.mobile: MobileMemoryBrowserScreen.screenKey,
    ScreenFamily.desktop: DesktopMemoryBrowserScreen.screenKey,
    ScreenFamily.web: WebMemoryBrowserScreen.screenKey,
  }.entries) {
    testWidgets('${entry.key.name} routes to its own memory screen', (
      tester,
    ) async {
      await tester.pumpWidget(
        MindlyApp(
          screenFamilyOverride: entry.key,
          memoryBrowserControllerOverride: const _FakeMemoryController(),
        ),
      );
      Navigator.of(
        tester.element(find.byType(Scaffold).first),
      ).pushNamed(AppRoutes.memory);
      await tester.pumpAndSettle();

      expect(find.byKey(entry.value), findsOneWidget);
      final otherKeys = <Key>{
        MobileMemoryBrowserScreen.screenKey,
        DesktopMemoryBrowserScreen.screenKey,
        WebMemoryBrowserScreen.screenKey,
      }..remove(entry.value);
      for (final key in otherKeys) {
        expect(find.byKey(key), findsNothing);
      }
      expect(find.textContaining('Nothing'), findsWidgets);
    });
  }
}

class _FakeMemoryController implements MemoryBrowserController {
  const _FakeMemoryController();

  @override
  Future<MemoryDetail?> detail(MemoryEntityType type, String id) async => null;

  @override
  Future<MemoryGraphNeighborhood?> graph(
    MemoryEntityType type,
    String id, {
    int maxDepth = 2,
    int maxNodes = 100,
  }) async => null;

  @override
  Future<List<MemoryListItem>> list(
    MemoryEntityType type, {
    CaptureBrowserFilter captureFilter = const CaptureBrowserFilter(),
    int limit = 100,
  }) async => const [];

  @override
  Future<List<HybridMemorySearchHit>> search({
    required String query,
    String? semanticModel,
    List<double>? queryVector,
    int limit = 20,
  }) async => const [];
}
