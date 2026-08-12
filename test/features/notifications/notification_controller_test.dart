import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindly/app/app_routes.dart';
import 'package:mindly/features/ai_settings/domain/cost_models.dart';
import 'package:mindly/features/insights/application/insight_controller.dart';
import 'package:mindly/features/insights/domain/insight_models.dart';
import 'package:mindly/features/memory/domain/memory_models.dart';
import 'package:mindly/features/notifications/application/notification_controller.dart';
import 'package:mindly/features/notifications/application/notification_planner.dart';
import 'package:mindly/features/notifications/data/local_notification_gateway.dart';
import 'package:mindly/features/notifications/data/notification_store.dart';
import 'package:mindly/features/notifications/domain/notification_models.dart';

void main() {
  test(
    'startup stays fully lazy and never requests permission when disabled',
    () async {
      final gateway = _FakeGateway();
      var insightFactoryCalls = 0;
      final controller = _controller(
        gateway: gateway,
        insightControllerFactory: () {
          insightFactoryCalls++;
          return const _FakeInsightController([]);
        },
      );

      await controller.initializeAndReconcile();

      expect(gateway.initializeCalls, 0);
      expect(gateway.permissionCalls, 0);
      expect(gateway.scheduled, isEmpty);
      expect(insightFactoryCalls, 0);
    },
  );

  test('explicit first enable requests permission before scheduling', () async {
    final gateway = _FakeGateway(permissionGranted: true);
    final preferenceStore = _MemoryPreferenceStore();
    final controller = _controller(
      gateway: gateway,
      preferenceStore: preferenceStore,
    );

    final outcome = await controller.savePreferences(
      const NotificationPreferences(
        digestFrequency: NotificationDigestFrequency.daily,
        digestHour: 9,
      ),
    );

    expect(outcome.kind, NotificationSaveOutcomeKind.saved);
    expect(gateway.permissionCalls, 1);
    expect(gateway.scheduled, isNotEmpty);
    expect((await preferenceStore.read()).anyEnabled, isTrue);
  });

  test('permission denial does not persist enabled preferences', () async {
    final gateway = _FakeGateway(permissionGranted: false);
    final preferenceStore = _MemoryPreferenceStore();
    final controller = _controller(
      gateway: gateway,
      preferenceStore: preferenceStore,
    );

    final outcome = await controller.savePreferences(
      const NotificationPreferences(tier2AlertsEnabled: true),
    );

    expect(outcome.kind, NotificationSaveOutcomeKind.permissionDenied);
    expect((await preferenceStore.read()).anyEnabled, isFalse);
    expect(gateway.scheduled, isEmpty);
  });

  test(
    'disabling existing schedules initializes only to cancel them',
    () async {
      final gateway = _FakeGateway();
      final preferenceStore = _MemoryPreferenceStore(
        const NotificationPreferences(
          digestFrequency: NotificationDigestFrequency.daily,
        ),
      );
      final deliveryStore = _MemoryDeliveryStore()
        ..value = const NotificationDeliveryState(
          alertIds: [101],
          digestIds: [201, 202],
        );
      var insightFactoryCalls = 0;
      final controller = _controller(
        gateway: gateway,
        preferenceStore: preferenceStore,
        deliveryStore: deliveryStore,
        insightControllerFactory: () {
          insightFactoryCalls++;
          return const _FakeInsightController([]);
        },
      );

      final outcome = await controller.savePreferences(
        const NotificationPreferences(),
      );

      expect(outcome.kind, NotificationSaveOutcomeKind.saved);
      expect(gateway.initializeCalls, 1);
      expect(gateway.permissionCalls, 0);
      expect(gateway.cancelled, containsAll([101, 201, 202]));
      expect((await deliveryStore.read()).alertIds, isEmpty);
      expect((await deliveryStore.read()).digestIds, isEmpty);
      expect(insightFactoryCalls, 0);
    },
  );

  test(
    'unsupported scheduling rejects enable without permission request',
    () async {
      final gateway = _FakeGateway(
        capabilities: const NotificationCapabilities(
          platform: MindlyNotificationPlatform.web,
          canSchedule: false,
          canShowImmediate: false,
          message: 'Web scheduling unavailable.',
        ),
      );
      final controller = _controller(gateway: gateway);

      final outcome = await controller.savePreferences(
        const NotificationPreferences(tier2AlertsEnabled: true),
      );

      expect(outcome.kind, NotificationSaveOutcomeKind.unsupported);
      expect(gateway.permissionCalls, 0);
      expect(gateway.initializeCalls, 0);
    },
  );

  test('Tier 2 fingerprint is scheduled only once across reconciles', () async {
    final gateway = _FakeGateway();
    final preferenceStore = _MemoryPreferenceStore(
      const NotificationPreferences(tier2AlertsEnabled: true),
    );
    final deliveryStore = _MemoryDeliveryStore();
    final controller = _controller(
      gateway: gateway,
      preferenceStore: preferenceStore,
      deliveryStore: deliveryStore,
      insightController: _FakeInsightController([
        _tier2Insight('needs-follow-up'),
      ]),
    );

    await controller.reconcile();
    final countAfterFirst = gateway.scheduled.length;
    await controller.reconcile();

    expect(countAfterFirst, 1);
    expect(gateway.scheduled, hasLength(1));
    expect(
      (await deliveryStore.read()).notifiedFingerprints,
      contains('needs-follow-up'),
    );
  });

  test('notification payload only routes an Insights payload', () async {
    final routes = <String>[];
    final gateway = _FakeGateway();
    final controller = _controller(
      gateway: gateway,
      preferenceStore: _MemoryPreferenceStore(
        const NotificationPreferences(
          digestFrequency: NotificationDigestFrequency.daily,
        ),
      ),
      onOpenRoute: routes.add,
    );
    await controller.initializeAndReconcile();

    gateway.emit(const NotificationPayload(route: AppRoutes.insights).encode());
    gateway.emit(const NotificationPayload(route: '/memory').encode());
    gateway.emit('not-json');

    expect(routes, [AppRoutes.insights]);
  });
}

DefaultNotificationController _controller({
  required _FakeGateway gateway,
  _MemoryPreferenceStore? preferenceStore,
  _MemoryDeliveryStore? deliveryStore,
  InsightController? insightController,
  InsightController Function()? insightControllerFactory,
  void Function(String route)? onOpenRoute,
}) {
  return DefaultNotificationController(
    preferenceStore: preferenceStore ?? _MemoryPreferenceStore(),
    deliveryStore: deliveryStore ?? _MemoryDeliveryStore(),
    planner: const NotificationPlanner(digestWindowSize: 2),
    gateway: gateway,
    insightControllerFactory:
        insightControllerFactory ??
        () => insightController ?? const _FakeInsightController([]),
    onOpenRoute: onOpenRoute ?? (_) {},
    now: () => DateTime(2026, 8, 12, 12),
  );
}

ProactiveInsight _tier2Insight(String fingerprint) => ProactiveInsight(
  fingerprint: fingerprint,
  kind: InsightKind.followUp,
  tier: InsightTier.tier2,
  severity: InsightSeverity.recommendation,
  title: 'Follow up',
  body: 'A saved commitment may need attention.',
  evidenceAt: DateTime(2026, 8, 12, 9),
  sources: const <InsightSourceReference>[],
);

class _MemoryPreferenceStore implements NotificationPreferenceStore {
  _MemoryPreferenceStore([this.value = const NotificationPreferences()]);

  NotificationPreferences value;

  @override
  Future<NotificationPreferences> read() async => value;

  @override
  Future<void> write(NotificationPreferences preferences) async {
    value = preferences;
  }
}

class _MemoryDeliveryStore implements NotificationDeliveryStore {
  NotificationDeliveryState value = const NotificationDeliveryState();

  @override
  Future<NotificationDeliveryState> read() async => value;

  @override
  Future<void> write(NotificationDeliveryState state) async {
    value = state;
  }
}

class _FakeGateway implements LocalNotificationGateway {
  _FakeGateway({
    this.permissionGranted = true,
    this.capabilities = const NotificationCapabilities(
      platform: MindlyNotificationPlatform.android,
      canSchedule: true,
      canShowImmediate: true,
      message: 'Available.',
    ),
  });

  final bool permissionGranted;

  @override
  final NotificationCapabilities capabilities;

  int initializeCalls = 0;
  int permissionCalls = 0;
  final List<PlannedNotification> scheduled = [];
  final List<int> cancelled = [];
  ValueChanged<String?>? _onPayload;

  @override
  Future<void> cancelIds(Iterable<int> ids) async {
    cancelled.addAll(ids);
  }

  void emit(String? payload) => _onPayload?.call(payload);

  @override
  Future<void> initialize(ValueChanged<String?> onPayload) async {
    initializeCalls++;
    _onPayload = onPayload;
  }

  @override
  Future<bool> requestPermission() async {
    permissionCalls++;
    return permissionGranted;
  }

  @override
  Future<void> schedule(PlannedNotification notification) async {
    scheduled.add(notification);
  }
}

class _FakeInsightController implements InsightController {
  const _FakeInsightController(this.insights);

  final List<ProactiveInsight> insights;

  @override
  Future<List<ProactiveInsight>> dismiss(String fingerprint) async => insights;

  @override
  Future<CostEstimate?> estimateTier3(Tier3ProviderProfile profile) async =>
      null;

  @override
  Future<Tier3GenerationOutcome> generateTier3(
    Tier3ProviderProfile profile,
  ) async => const Tier3GenerationOutcome(
    kind: Tier3GenerationOutcomeKind.providerFailure,
    estimate: null,
  );

  @override
  Future<List<ProactiveInsight>> load() async => insights;

  @override
  Future<Set<InsightKind>> mutedKinds() async => const <InsightKind>{};

  @override
  Future<List<ProactiveInsight>> setMuted(InsightKind kind, bool muted) async =>
      insights;

  @override
  Future<MemoryDetail?> sourceDetail(InsightSourceReference source) async =>
      null;
}
