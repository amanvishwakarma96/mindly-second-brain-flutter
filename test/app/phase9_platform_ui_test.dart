import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindly/app/app_routes.dart';
import 'package:mindly/app/mindly_app.dart';
import 'package:mindly/app/platform/screen_family.dart';
import 'package:mindly/features/ai_settings/application/provider_key_service.dart';
import 'package:mindly/features/ai_settings/application/provider_settings_controller.dart';
import 'package:mindly/features/ai_settings/data/provider_key_repository.dart';
import 'package:mindly/features/ai_settings/data/secure_spend_store.dart';
import 'package:mindly/features/ai_settings/domain/cost_models.dart';
import 'package:mindly/features/insights/application/insight_controller.dart';
import 'package:mindly/features/insights/domain/insight_models.dart';
import 'package:mindly/features/memory/application/memory_browser_controller.dart';
import 'package:mindly/features/memory/domain/memory_models.dart';
import 'package:mindly/features/notifications/application/notification_controller.dart';
import 'package:mindly/features/notifications/domain/notification_models.dart';
import 'package:mindly/screens/desktop/home/desktop_home_screen.dart';
import 'package:mindly/screens/desktop/memory/desktop_memory_browser_screen.dart';
import 'package:mindly/screens/desktop/settings/desktop_settings_screen.dart';
import 'package:mindly/screens/mobile/home/mobile_home_screen.dart';
import 'package:mindly/screens/mobile/insights/mobile_insights_screen.dart';
import 'package:mindly/screens/mobile/memory/mobile_memory_browser_screen.dart';
import 'package:mindly/screens/mobile/settings/mobile_settings_screen.dart';
import 'package:mindly/screens/web/home/web_home_screen.dart';
import 'package:mindly/screens/web/settings/web_settings_screen.dart';

import '../helpers/in_memory_secret_store.dart';

void main() {
  testWidgets('mobile home is capture-first and exposes bottom navigation', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MobileHomeScreen()));

    expect(
      find.byKey(const ValueKey<String>('mobile-primary-navigation')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('mobile-quick-text-capture')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('mobile-quick-audio-capture')),
      findsOneWidget,
    );
  });

  testWidgets('mobile memory keeps capture filters in a bottom sheet', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MobileMemoryBrowserScreen(controller: _FakeMemoryController()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('mobile-memory-filter-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('mobile-memory-filter-sheet')),
      findsNothing,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('mobile-memory-filter-button')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('mobile-memory-filter-sheet')),
      findsOneWidget,
    );
    expect(find.text('Work'), findsOneWidget);
    expect(find.text('Personal'), findsOneWidget);
    expect(find.text('Pinned'), findsOneWidget);
  });

  testWidgets('mobile insight cards are swipe dismissible', (tester) async {
    final controller = _FakeInsightController();
    await tester.pumpWidget(
      MaterialApp(home: MobileInsightsScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    final card = find.byKey(const ValueKey<String>('mobile-insight-phase9'));
    expect(card, findsOneWidget);
    expect(find.byType(Dismissible), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('mobile-primary-navigation')),
      findsOneWidget,
    );

    await tester.drag(card, const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(controller.dismissedFingerprint, 'phase9');
  });

  testWidgets('desktop home keeps sidebar, workspace, and review pane', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 720);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: DesktopHomeScreen()));

    expect(
      find.byKey(const ValueKey<String>('desktop-home-sidebar')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('desktop-home-main')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('desktop-home-detail')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop memory supports master-detail keyboard selection', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 720);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: DesktopMemoryBrowserScreen(controller: _FakeMemoryController()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('desktop-memory-sidebar')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('desktop-memory-master-list')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('desktop-memory-detail-pane')),
      findsOneWidget,
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();

    expect(find.text('Summary for Alpha'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('web home switches between wide and narrow structures', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    tester.view.physicalSize = const Size(1200, 800);
    await tester.pumpWidget(const MaterialApp(home: WebHomeScreen()));
    expect(find.byKey(const ValueKey<String>('web-home-wide')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('web-home-narrow')), findsNothing);

    tester.view.physicalSize = const Size(600, 800);
    await tester.pump();
    expect(find.byKey(const ValueKey<String>('web-home-wide')), findsNothing);
    expect(find.byKey(const ValueKey<String>('web-home-narrow')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final entry in <ScreenFamily, Key>{
    ScreenFamily.mobile: MobileSettingsScreen.screenKey,
    ScreenFamily.desktop: DesktopSettingsScreen.screenKey,
    ScreenFamily.web: WebSettingsScreen.screenKey,
  }.entries) {
    testWidgets('${entry.key.name} routes to its own combined settings screen', (
      tester,
    ) async {
      await tester.pumpWidget(
        MindlyApp(
          screenFamilyOverride: entry.key,
          providerSettingsControllerOverride: _providerController(
            isWeb: entry.key == ScreenFamily.web,
          ),
          notificationControllerOverride: _FakeNotificationController(
            canSchedule: entry.key != ScreenFamily.web,
          ),
        ),
      );
      await tester.pump();

      Navigator.of(
        tester.element(find.byType(Scaffold).first),
      ).pushNamed(AppRoutes.settings);
      await tester.pumpAndSettle();

      expect(find.byKey(entry.value), findsOneWidget);
    });
  }

  testWidgets('desktop settings exposes provider and notification tabs', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DesktopSettingsScreen(
          providerController: _providerController(isWeb: false),
          notificationController: _FakeNotificationController(
            canSchedule: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('desktop-settings-provider-tab')),
      findsOneWidget,
    );
    await tester.tap(find.text('Notifications'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('desktop-settings-notification-tab')),
      findsOneWidget,
    );
  });

  testWidgets('web settings collapse from cards to a single-column list', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    tester.view.physicalSize = const Size(1000, 800);
    await tester.pumpWidget(const MaterialApp(home: WebSettingsScreen()));
    expect(
      find.byKey(const ValueKey<String>('web-settings-wide')),
      findsOneWidget,
    );

    tester.view.physicalSize = const Size(600, 800);
    await tester.pump();
    expect(
      find.byKey(const ValueKey<String>('web-settings-narrow')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

ProviderSettingsController _providerController({required bool isWeb}) {
  final store = InMemorySecretStore();
  return ProviderSettingsController(
    keyService: ProviderKeyService(
      repository: ProviderKeyRepository(store),
      isWeb: isWeb,
    ),
    capsRepository: SecureSpendStore(store),
  );
}

class _FakeMemoryController implements MemoryBrowserController {
  const _FakeMemoryController();

  static const items = [
    MemoryListItem(
      type: MemoryEntityType.capture,
      id: 'alpha',
      title: 'Alpha',
      subtitle: 'First memory',
    ),
    MemoryListItem(
      type: MemoryEntityType.capture,
      id: 'beta',
      title: 'Beta',
      subtitle: 'Second memory',
    ),
  ];

  @override
  Future<MemoryDetail?> detail(MemoryEntityType type, String id) async {
    final item = items.firstWhere((value) => value.id == id);
    return MemoryDetail(item: item, summary: 'Summary for ${item.title}');
  }

  @override
  Future<MemoryGraphNeighborhood?> graph(
    MemoryEntityType type,
    String id, {
    int maxDepth = 2,
    int maxNodes = 100,
  }) async {
    final item = items.firstWhere((value) => value.id == id);
    return MemoryGraphNeighborhood(
      root: item,
      nodes: [MemoryGraphNode(item: item, depth: 0)],
      edges: const [],
    );
  }

  @override
  Future<List<MemoryListItem>> list(
    MemoryEntityType type, {
    CaptureBrowserFilter captureFilter = const CaptureBrowserFilter(),
    int limit = 100,
  }) async => type == MemoryEntityType.capture ? items : const [];

  @override
  Future<List<HybridMemorySearchHit>> search({
    required String query,
    String? semanticModel,
    List<double>? queryVector,
    int limit = 20,
  }) async => const [];
}

class _FakeInsightController implements InsightController {
  String? dismissedFingerprint;

  static final insight = ProactiveInsight(
    fingerprint: 'phase9',
    kind: InsightKind.followUp,
    tier: InsightTier.tier2,
    severity: InsightSeverity.recommendation,
    title: 'A gentle follow-up',
    body: 'You mentioned this commitment recently.',
    evidenceAt: DateTime(2026, 8, 12),
    sources: const [
      InsightSourceReference(
        type: MemoryEntityType.capture,
        id: 'alpha',
        title: 'Alpha',
      ),
    ],
  );

  @override
  Future<List<ProactiveInsight>> dismiss(String fingerprint) async {
    dismissedFingerprint = fingerprint;
    return const [];
  }

  @override
  Future<CostEstimate?> estimateTier3(Tier3ProviderProfile profile) async => null;

  @override
  Future<Tier3GenerationOutcome> generateTier3(
    Tier3ProviderProfile profile,
  ) async => const Tier3GenerationOutcome(
    kind: Tier3GenerationOutcomeKind.insufficientEvidence,
    estimate: null,
  );

  @override
  Future<List<ProactiveInsight>> load() async => [insight];

  @override
  Future<Set<InsightKind>> mutedKinds() async => const {};

  @override
  Future<List<ProactiveInsight>> setMuted(InsightKind kind, bool muted) async =>
      [insight];

  @override
  Future<MemoryDetail?> sourceDetail(InsightSourceReference source) async =>
      null;
}

class _FakeNotificationController implements NotificationController {
  _FakeNotificationController({required bool canSchedule})
    : capabilities = NotificationCapabilities(
        platform: canSchedule
            ? MindlyNotificationPlatform.android
            : MindlyNotificationPlatform.web,
        canSchedule: canSchedule,
        canShowImmediate: canSchedule,
        message: canSchedule
            ? 'Local scheduling is available.'
            : 'Scheduled notifications are unavailable on Web.',
      );

  @override
  final NotificationCapabilities capabilities;

  @override
  Future<void> initializeAndReconcile() async {}

  @override
  Future<NotificationPreferences> loadPreferences() async =>
      const NotificationPreferences();

  @override
  Future<void> reconcile() async {}

  @override
  Future<NotificationSaveOutcome> savePreferences(
    NotificationPreferences preferences,
  ) async => const NotificationSaveOutcome(NotificationSaveOutcomeKind.saved);
}
