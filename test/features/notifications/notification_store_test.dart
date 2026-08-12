import 'package:flutter_test/flutter_test.dart';
import 'package:mindly/core/security/secret_store.dart';
import 'package:mindly/features/notifications/data/notification_store.dart';
import 'package:mindly/features/notifications/domain/notification_models.dart';

void main() {
  test('secure notification preference store round-trips settings', () async {
    final secretStore = _MemorySecretStore();
    final store = SecureNotificationPreferenceStore(secretStore);
    const preferences = NotificationPreferences(
      tier2AlertsEnabled: true,
      digestFrequency: NotificationDigestFrequency.daily,
      digestHour: 7,
      digestMinute: 30,
    );

    await store.write(preferences);
    final loaded = await store.read();

    expect(loaded.tier2AlertsEnabled, isTrue);
    expect(loaded.digestFrequency, NotificationDigestFrequency.daily);
    expect(loaded.digestHour, 7);
    expect(loaded.digestMinute, 30);
  });

  test('secure notification stores fall back safely on corrupt JSON', () async {
    final preferenceSecret = _MemorySecretStore(
      seed: {'mindly.notifications.preferences.v1': '{bad'},
    );
    final deliverySecret = _MemorySecretStore(
      seed: {'mindly.notifications.delivery.v1': '{bad'},
    );

    final preferences = await SecureNotificationPreferenceStore(
      preferenceSecret,
    ).read();
    final delivery = await SecureNotificationDeliveryStore(
      deliverySecret,
    ).read();

    expect(preferences.anyEnabled, isFalse);
    expect(delivery.notifiedFingerprints, isEmpty);
    expect(delivery.alertIds, isEmpty);
    expect(delivery.digestIds, isEmpty);
  });

  test('delivery store persists notification IDs and fingerprints', () async {
    final secretStore = _MemorySecretStore();
    final store = SecureNotificationDeliveryStore(secretStore);
    const state = NotificationDeliveryState(
      notifiedFingerprints: ['first'],
      alertIds: [1001],
      digestIds: [2001, 2002],
    );

    await store.write(state);
    final loaded = await store.read();

    expect(loaded.notifiedFingerprints, ['first']);
    expect(loaded.alertIds, [1001]);
    expect(loaded.digestIds, [2001, 2002]);
  });
}

class _MemorySecretStore implements SecretStore {
  _MemorySecretStore({Map<String, String>? seed})
    : values = <String, String>{...?seed};

  final Map<String, String> values;

  @override
  Future<void> delete({required String key}) async {
    values.remove(key);
  }

  @override
  Future<String?> read({required String key}) async => values[key];

  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }
}
