// ignore_for_file: prefer_initializing_formals

import 'package:mindly/app/app_routes.dart';
import 'package:mindly/core/security/flutter_secure_secret_store.dart';
import 'package:mindly/features/insights/application/insight_controller.dart';
import 'package:mindly/features/notifications/application/notification_planner.dart';
import 'package:mindly/features/notifications/data/local_notification_gateway.dart';
import 'package:mindly/features/notifications/data/notification_store.dart';
import 'package:mindly/features/notifications/domain/notification_models.dart';

enum NotificationSaveOutcomeKind {
  saved,
  permissionDenied,
  unsupported,
  failed,
}

class NotificationSaveOutcome {
  const NotificationSaveOutcome(this.kind, {this.message});

  final NotificationSaveOutcomeKind kind;
  final String? message;

  bool get saved => kind == NotificationSaveOutcomeKind.saved;
}

abstract class NotificationController {
  factory NotificationController.production({
    required void Function(String route) onOpenRoute,
  }) {
    final secureStore = FlutterSecureSecretStore();
    return DefaultNotificationController(
      preferenceStore: SecureNotificationPreferenceStore(secureStore),
      deliveryStore: SecureNotificationDeliveryStore(secureStore),
      planner: const NotificationPlanner(),
      gateway: FlutterLocalNotificationGateway(),
      insightControllerFactory: InsightController.production,
      onOpenRoute: onOpenRoute,
    );
  }

  NotificationCapabilities get capabilities;
  Future<NotificationPreferences> loadPreferences();
  Future<NotificationSaveOutcome> savePreferences(
    NotificationPreferences preferences,
  );
  Future<void> initializeAndReconcile();
  Future<void> reconcile();
}

class DefaultNotificationController implements NotificationController {
  DefaultNotificationController({
    required NotificationPreferenceStore preferenceStore,
    required NotificationDeliveryStore deliveryStore,
    required NotificationPlanner planner,
    required LocalNotificationGateway gateway,
    required InsightController Function() insightControllerFactory,
    required void Function(String route) onOpenRoute,
    DateTime Function()? now,
  }) : _preferenceStore = preferenceStore,
       _deliveryStore = deliveryStore,
       _planner = planner,
       _gateway = gateway,
       _insightControllerFactory = insightControllerFactory,
       _onOpenRoute = onOpenRoute,
       _now = now ?? DateTime.now;

  final NotificationPreferenceStore _preferenceStore;
  final NotificationDeliveryStore _deliveryStore;
  final NotificationPlanner _planner;
  final LocalNotificationGateway _gateway;
  final InsightController Function() _insightControllerFactory;
  final void Function(String route) _onOpenRoute;
  final DateTime Function() _now;
  InsightController? _insightController;
  bool _initialized = false;

  @override
  NotificationCapabilities get capabilities => _gateway.capabilities;

  @override
  Future<NotificationPreferences> loadPreferences() => _preferenceStore.read();

  @override
  Future<void> initializeAndReconcile() async {
    try {
      final preferences = await _preferenceStore.read();
      if (!preferences.anyEnabled || !capabilities.canSchedule) return;
      await _ensureInitialized();
      await reconcile();
    } catch (_) {
      // Notification setup must never prevent local memory access or app startup.
    }
  }

  @override
  Future<NotificationSaveOutcome> savePreferences(
    NotificationPreferences preferences,
  ) async {
    if (preferences.anyEnabled && !capabilities.canSchedule) {
      return NotificationSaveOutcome(
        NotificationSaveOutcomeKind.unsupported,
        message: capabilities.message,
      );
    }

    try {
      final previous = await _preferenceStore.read();
      if (capabilities.canSchedule &&
          (preferences.anyEnabled || previous.anyEnabled)) {
        await _ensureInitialized();
      }
      if (preferences.anyEnabled && !previous.anyEnabled) {
        final granted = await _gateway.requestPermission();
        if (!granted) {
          return const NotificationSaveOutcome(
            NotificationSaveOutcomeKind.permissionDenied,
            message: 'Notification permission was not granted.',
          );
        }
      }
      await _preferenceStore.write(preferences);
      await reconcile();
      return const NotificationSaveOutcome(NotificationSaveOutcomeKind.saved);
    } catch (_) {
      return const NotificationSaveOutcome(
        NotificationSaveOutcomeKind.failed,
        message: 'Mindly could not update the local notification schedule.',
      );
    }
  }

  @override
  Future<void> reconcile() async {
    if (!capabilities.canSchedule) return;

    final preferences = await _preferenceStore.read();
    var state = await _deliveryStore.read();

    if (!preferences.anyEnabled) {
      await _gateway.cancelIds([...state.digestIds, ...state.alertIds]);
      await _deliveryStore.write(
        state.copyWith(
          digestIds: const <int>[],
          alertIds: const <int>[],
        ),
      );
      return;
    }

    await _ensureInitialized();
    await _gateway.cancelIds(state.digestIds);
    final digestPlans = _planner.planDigests(
      preferences: preferences,
      now: _now(),
    );
    final digestIds = <int>[];
    for (final plan in digestPlans) {
      await _gateway.schedule(plan);
      digestIds.add(plan.id);
    }
    state = state.copyWith(digestIds: digestIds);

    if (!preferences.tier2AlertsEnabled) {
      await _gateway.cancelIds(state.alertIds);
      state = state.copyWith(alertIds: const <int>[]);
      await _deliveryStore.write(state);
      return;
    }

    final insightController = _insightController ??= _insightControllerFactory();
    final activeInsights = await insightController.load();
    final alertPlans = _planner.planTier2Alerts(
      insights: activeInsights,
      preferences: preferences,
      deliveryState: state,
      now: _now(),
    );
    final fingerprints = <String>[...state.notifiedFingerprints];
    final alertIds = <int>[...state.alertIds];
    for (final plan in alertPlans) {
      await _gateway.schedule(plan);
      final fingerprint = plan.insightFingerprint;
      if (fingerprint != null) fingerprints.add(fingerprint);
      alertIds.add(plan.id);
    }
    await _deliveryStore.write(
      state.copyWith(
        notifiedFingerprints: fingerprints.toSet().toList(growable: false),
        alertIds: alertIds.toSet().toList(growable: false),
      ),
    );
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _gateway.initialize(_handlePayload);
    _initialized = true;
  }

  void _handlePayload(String? raw) {
    final payload = NotificationPayload.tryDecode(raw);
    if (payload?.route == AppRoutes.insights) {
      _onOpenRoute(AppRoutes.insights);
    }
  }
}
