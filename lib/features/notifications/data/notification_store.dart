import 'dart:convert';

import 'package:mindly/core/security/secret_store.dart';
import 'package:mindly/features/notifications/domain/notification_models.dart';

abstract interface class NotificationPreferenceStore {
  Future<NotificationPreferences> read();
  Future<void> write(NotificationPreferences preferences);
}

abstract interface class NotificationDeliveryStore {
  Future<NotificationDeliveryState> read();
  Future<void> write(NotificationDeliveryState state);
}

class SecureNotificationPreferenceStore implements NotificationPreferenceStore {
  SecureNotificationPreferenceStore(this._store);

  static const _key = 'mindly.notifications.preferences.v1';
  final SecretStore _store;

  @override
  Future<NotificationPreferences> read() async {
    final raw = await _store.read(key: _key);
    if (raw == null || raw.isEmpty) return const NotificationPreferences();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const NotificationPreferences();
      }
      return NotificationPreferences.fromJson(decoded);
    } on FormatException {
      return const NotificationPreferences();
    }
  }

  @override
  Future<void> write(NotificationPreferences preferences) {
    return _store.write(key: _key, value: jsonEncode(preferences.toJson()));
  }
}

class SecureNotificationDeliveryStore implements NotificationDeliveryStore {
  SecureNotificationDeliveryStore(this._store);

  static const _key = 'mindly.notifications.delivery.v1';
  static const _historyLimit = 500;
  final SecretStore _store;

  @override
  Future<NotificationDeliveryState> read() async {
    final raw = await _store.read(key: _key);
    if (raw == null || raw.isEmpty) return const NotificationDeliveryState();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const NotificationDeliveryState();
      }
      return NotificationDeliveryState.fromJson(decoded);
    } on FormatException {
      return const NotificationDeliveryState();
    }
  }

  @override
  Future<void> write(NotificationDeliveryState state) {
    final fingerprints = state.notifiedFingerprints.length <= _historyLimit
        ? state.notifiedFingerprints
        : state.notifiedFingerprints.sublist(
            state.notifiedFingerprints.length - _historyLimit,
          );
    final compact = state.copyWith(notifiedFingerprints: fingerprints);
    return _store.write(key: _key, value: jsonEncode(compact.toJson()));
  }
}
