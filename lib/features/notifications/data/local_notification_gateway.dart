import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mindly/features/notifications/domain/notification_models.dart';
import 'package:timezone/timezone.dart' as tz;

abstract interface class LocalNotificationGateway {
  NotificationCapabilities get capabilities;

  Future<void> initialize(ValueChanged<String?> onPayload);
  Future<bool> requestPermission();
  Future<void> schedule(PlannedNotification notification);
  Future<void> cancelIds(Iterable<int> ids);
}

class FlutterLocalNotificationGateway implements LocalNotificationGateway {
  FlutterLocalNotificationGateway({
    FlutterLocalNotificationsPlugin? plugin,
    NotificationCapabilities? capabilities,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _capabilities = capabilities ?? NotificationCapabilities.current();

  final FlutterLocalNotificationsPlugin _plugin;
  final NotificationCapabilities _capabilities;
  bool _initialized = false;

  @override
  NotificationCapabilities get capabilities => _capabilities;

  @override
  Future<void> initialize(ValueChanged<String?> onPayload) async {
    if (_initialized ||
        _capabilities.platform == MindlyNotificationPlatform.web ||
        _capabilities.platform == MindlyNotificationPlatform.other) {
      return;
    }

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    final settings = InitializationSettings(
      android: const AndroidInitializationSettings('ic_launcher'),
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: const LinuxInitializationSettings(
        defaultActionName: 'Open Mindly',
      ),
      windows: WindowsInitializationSettings(
        appName: 'Mindly',
        appUserModelId: 'AmanVishwakarma.Mindly',
        guid: '4d5669fc-8fa0-4a4e-9c68-1c88f7097d7b',
      ),
    );
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        onPayload(response.payload);
      },
    );
    _initialized = true;

    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      onPayload(launch?.notificationResponse?.payload);
    }
  }

  @override
  Future<bool> requestPermission() async {
    if (!_capabilities.canSchedule) return false;

    switch (_capabilities.platform) {
      case MindlyNotificationPlatform.android:
        return await _plugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >()
                ?.requestNotificationsPermission() ??
            true;
      case MindlyNotificationPlatform.iOS:
        return await _plugin
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >()
                ?.requestPermissions(alert: true, badge: true, sound: true) ??
            false;
      case MindlyNotificationPlatform.macOS:
        return await _plugin
                .resolvePlatformSpecificImplementation<
                  MacOSFlutterLocalNotificationsPlugin
                >()
                ?.requestPermissions(alert: true, badge: true, sound: true) ??
            false;
      case MindlyNotificationPlatform.windows:
        return true;
      case MindlyNotificationPlatform.linux:
      case MindlyNotificationPlatform.web:
      case MindlyNotificationPlatform.other:
        return false;
    }
  }

  @override
  Future<void> schedule(PlannedNotification notification) async {
    if (!_capabilities.canSchedule) {
      throw UnsupportedError(_capabilities.message);
    }

    final details = NotificationDetails(
      android: const AndroidNotificationDetails(
        'mindly_insights',
        'Mindly insights',
        channelDescription: 'Quiet reminders from your local Mindly insights.',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: const DarwinNotificationDetails(),
      macOS: const DarwinNotificationDetails(),
      windows: WindowsNotificationDetails(),
    );
    await _plugin.zonedSchedule(
      id: notification.id,
      title: notification.title,
      body: notification.body,
      scheduledDate: tz.TZDateTime.from(notification.scheduledAt.toUtc(), tz.UTC),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: notification.payload.encode(),
    );
  }

  @override
  Future<void> cancelIds(Iterable<int> ids) async {
    for (final id in ids.toSet()) {
      await _plugin.cancel(id: id);
    }
  }
}
