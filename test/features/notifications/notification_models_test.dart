import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindly/features/notifications/domain/notification_models.dart';

void main() {
  test('notification preferences round-trip through JSON', () {
    const original = NotificationPreferences(
      tier2AlertsEnabled: true,
      digestFrequency: NotificationDigestFrequency.weekdays,
      digestHour: 8,
      digestMinute: 45,
      quietStartMinutes: 21 * 60 + 30,
      quietEndMinutes: 6 * 60 + 15,
    );

    final decoded = NotificationPreferences.fromJson(original.toJson());
    expect(decoded.tier2AlertsEnabled, isTrue);
    expect(decoded.digestFrequency, NotificationDigestFrequency.weekdays);
    expect(decoded.digestHour, 8);
    expect(decoded.digestMinute, 45);
    expect(decoded.quietStartMinutes, 21 * 60 + 30);
    expect(decoded.quietEndMinutes, 6 * 60 + 15);
  });

  test('delivery state round-trips through JSON', () {
    const original = NotificationDeliveryState(
      notifiedFingerprints: ['a', 'b'],
      alertIds: [101, 102],
      digestIds: [201],
    );
    final decoded = NotificationDeliveryState.fromJson(original.toJson());
    expect(decoded.notifiedFingerprints, ['a', 'b']);
    expect(decoded.alertIds, [101, 102]);
    expect(decoded.digestIds, [201]);
  });

  test('notification payload validates its route', () {
    const payload = NotificationPayload(
      route: '/insights',
      insightFingerprint: 'abc',
    );
    final decoded = NotificationPayload.tryDecode(payload.encode());
    expect(decoded?.route, '/insights');
    expect(decoded?.insightFingerprint, 'abc');
    expect(NotificationPayload.tryDecode('{"route":"not-a-route"}'), isNull);
    expect(NotificationPayload.tryDecode('bad json'), isNull);
  });

  test('platform capabilities document scheduling gaps', () {
    expect(
      NotificationCapabilities.current(
        isWebOverride: false,
        platformOverride: TargetPlatform.android,
      ).canSchedule,
      isTrue,
    );
    expect(
      NotificationCapabilities.current(
        isWebOverride: false,
        platformOverride: TargetPlatform.iOS,
      ).canSchedule,
      isTrue,
    );
    expect(
      NotificationCapabilities.current(
        isWebOverride: false,
        platformOverride: TargetPlatform.macOS,
      ).canSchedule,
      isTrue,
    );
    expect(
      NotificationCapabilities.current(
        isWebOverride: false,
        platformOverride: TargetPlatform.windows,
      ).canSchedule,
      isTrue,
    );

    final linux = NotificationCapabilities.current(
      isWebOverride: false,
      platformOverride: TargetPlatform.linux,
    );
    expect(linux.canSchedule, isFalse);
    expect(linux.message, contains('unavailable'));

    final web = NotificationCapabilities.current(
      isWebOverride: true,
      platformOverride: TargetPlatform.android,
    );
    expect(web.platform, MindlyNotificationPlatform.web);
    expect(web.canSchedule, isFalse);
    expect(web.message, contains('Scheduled'));
  });
}
