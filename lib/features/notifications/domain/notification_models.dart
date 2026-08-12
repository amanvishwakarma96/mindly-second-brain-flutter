import 'dart:convert';

import 'package:flutter/foundation.dart';

enum NotificationDigestFrequency {
  off,
  daily,
  weekdays;

  String get displayName => switch (this) {
    NotificationDigestFrequency.off => 'Off',
    NotificationDigestFrequency.daily => 'Daily',
    NotificationDigestFrequency.weekdays => 'Weekdays',
  };
}

class NotificationPreferences {
  const NotificationPreferences({
    this.tier2AlertsEnabled = false,
    this.digestFrequency = NotificationDigestFrequency.off,
    this.digestHour = 9,
    this.digestMinute = 0,
    this.quietStartMinutes = 22 * 60,
    this.quietEndMinutes = 7 * 60,
  });

  final bool tier2AlertsEnabled;
  final NotificationDigestFrequency digestFrequency;
  final int digestHour;
  final int digestMinute;
  final int quietStartMinutes;
  final int quietEndMinutes;

  bool get anyEnabled =>
      tier2AlertsEnabled || digestFrequency != NotificationDigestFrequency.off;

  bool get quietHoursEnabled => quietStartMinutes != quietEndMinutes;

  NotificationPreferences copyWith({
    bool? tier2AlertsEnabled,
    NotificationDigestFrequency? digestFrequency,
    int? digestHour,
    int? digestMinute,
    int? quietStartMinutes,
    int? quietEndMinutes,
  }) {
    return NotificationPreferences(
      tier2AlertsEnabled: tier2AlertsEnabled ?? this.tier2AlertsEnabled,
      digestFrequency: digestFrequency ?? this.digestFrequency,
      digestHour: digestHour ?? this.digestHour,
      digestMinute: digestMinute ?? this.digestMinute,
      quietStartMinutes: quietStartMinutes ?? this.quietStartMinutes,
      quietEndMinutes: quietEndMinutes ?? this.quietEndMinutes,
    );
  }

  Map<String, Object> toJson() => <String, Object>{
    'tier2AlertsEnabled': tier2AlertsEnabled,
    'digestFrequency': digestFrequency.name,
    'digestHour': digestHour,
    'digestMinute': digestMinute,
    'quietStartMinutes': quietStartMinutes,
    'quietEndMinutes': quietEndMinutes,
  };

  factory NotificationPreferences.fromJson(Map<String, Object?> json) {
    final rawFrequency = json['digestFrequency'];
    final frequencyName = rawFrequency is String ? rawFrequency : null;
    final frequency = NotificationDigestFrequency.values.firstWhere(
      (value) => value.name == frequencyName,
      orElse: () => NotificationDigestFrequency.off,
    );
    final rawTier2 = json['tier2AlertsEnabled'];
    return NotificationPreferences(
      tier2AlertsEnabled: rawTier2 is bool ? rawTier2 : false,
      digestFrequency: frequency,
      digestHour: _boundedInt(json['digestHour'], 0, 23, 9),
      digestMinute: _boundedInt(json['digestMinute'], 0, 59, 0),
      quietStartMinutes: _boundedInt(
        json['quietStartMinutes'],
        0,
        1439,
        22 * 60,
      ),
      quietEndMinutes: _boundedInt(json['quietEndMinutes'], 0, 1439, 7 * 60),
    );
  }

  static int _boundedInt(Object? value, int min, int max, int fallback) {
    final parsed = value is int ? value : null;
    if (parsed == null || parsed < min || parsed > max) return fallback;
    return parsed;
  }
}

class NotificationDeliveryState {
  const NotificationDeliveryState({
    this.notifiedFingerprints = const <String>[],
    this.alertIds = const <int>[],
    this.digestIds = const <int>[],
  });

  final List<String> notifiedFingerprints;
  final List<int> alertIds;
  final List<int> digestIds;

  NotificationDeliveryState copyWith({
    List<String>? notifiedFingerprints,
    List<int>? alertIds,
    List<int>? digestIds,
  }) {
    return NotificationDeliveryState(
      notifiedFingerprints: notifiedFingerprints ?? this.notifiedFingerprints,
      alertIds: alertIds ?? this.alertIds,
      digestIds: digestIds ?? this.digestIds,
    );
  }

  Map<String, Object> toJson() => <String, Object>{
    'notifiedFingerprints': notifiedFingerprints,
    'alertIds': alertIds,
    'digestIds': digestIds,
  };

  factory NotificationDeliveryState.fromJson(Map<String, Object?> json) {
    return NotificationDeliveryState(
      notifiedFingerprints: _list(
        json['notifiedFingerprints'],
      ).whereType<String>().toList(growable: false),
      alertIds: _list(
        json['alertIds'],
      ).whereType<num>().map((value) => value.toInt()).toList(growable: false),
      digestIds: _list(
        json['digestIds'],
      ).whereType<num>().map((value) => value.toInt()).toList(growable: false),
    );
  }

  static List<Object?> _list(Object? value) =>
      value is List<Object?> ? value : const <Object?>[];
}

class NotificationPayload {
  const NotificationPayload({required this.route, this.insightFingerprint});

  final String route;
  final String? insightFingerprint;

  String encode() => jsonEncode(<String, Object?>{
    'route': route,
    'insightFingerprint': insightFingerprint,
  });

  static NotificationPayload? tryDecode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final route = decoded['route'];
      if (route is! String || !route.startsWith('/')) return null;
      final rawFingerprint = decoded['insightFingerprint'];
      return NotificationPayload(
        route: route,
        insightFingerprint: rawFingerprint is String ? rawFingerprint : null,
      );
    } on FormatException {
      return null;
    }
  }
}

class PlannedNotification {
  const PlannedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.payload,
    this.insightFingerprint,
    this.isDigest = false,
  });

  final int id;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final NotificationPayload payload;
  final String? insightFingerprint;
  final bool isDigest;
}

enum MindlyNotificationPlatform {
  android,
  iOS,
  macOS,
  windows,
  linux,
  web,
  other,
}

class NotificationCapabilities {
  const NotificationCapabilities({
    required this.platform,
    required this.canSchedule,
    required this.canShowImmediate,
    required this.message,
  });

  final MindlyNotificationPlatform platform;
  final bool canSchedule;
  final bool canShowImmediate;
  final String message;

  static NotificationCapabilities current({
    bool? isWebOverride,
    TargetPlatform? platformOverride,
  }) {
    final isWeb = isWebOverride ?? kIsWeb;
    if (isWeb) {
      return const NotificationCapabilities(
        platform: MindlyNotificationPlatform.web,
        canSchedule: false,
        canShowImmediate: false,
        message:
            'Scheduled and repeating notifications are not available in the Web build. Mindly keeps this limitation explicit instead of pretending browser delivery is reliable.',
      );
    }

    final platform = platformOverride ?? defaultTargetPlatform;
    return switch (platform) {
      TargetPlatform.android => const NotificationCapabilities(
        platform: MindlyNotificationPlatform.android,
        canSchedule: true,
        canShowImmediate: true,
        message: 'Local notification scheduling is available on Android.',
      ),
      TargetPlatform.iOS => const NotificationCapabilities(
        platform: MindlyNotificationPlatform.iOS,
        canSchedule: true,
        canShowImmediate: true,
        message: 'Local notification scheduling is available on iOS.',
      ),
      TargetPlatform.macOS => const NotificationCapabilities(
        platform: MindlyNotificationPlatform.macOS,
        canSchedule: true,
        canShowImmediate: true,
        message: 'Local notification scheduling is available on macOS.',
      ),
      TargetPlatform.windows => const NotificationCapabilities(
        platform: MindlyNotificationPlatform.windows,
        canSchedule: true,
        canShowImmediate: true,
        message:
            'Local scheduling is available on Windows. Mindly schedules a bounded rolling window because Windows does not support repeating notifications.',
      ),
      TargetPlatform.linux => const NotificationCapabilities(
        platform: MindlyNotificationPlatform.linux,
        canSchedule: false,
        canShowImmediate: true,
        message:
            'Linux desktop notifications can be shown while Mindly is running, but scheduled/pending notifications are unavailable with the current desktop notification API.',
      ),
      _ => const NotificationCapabilities(
        platform: MindlyNotificationPlatform.other,
        canSchedule: false,
        canShowImmediate: false,
        message: 'Scheduled notifications are unavailable on this platform.',
      ),
    };
  }
}
