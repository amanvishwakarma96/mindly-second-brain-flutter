import 'package:flutter_test/flutter_test.dart';
import 'package:mindly/features/insights/domain/insight_models.dart';
import 'package:mindly/features/notifications/application/notification_planner.dart';
import 'package:mindly/features/notifications/domain/notification_models.dart';

void main() {
  const planner = NotificationPlanner(digestWindowSize: 4, maxTier2Alerts: 4);

  group('quiet hours', () {
    const preferences = NotificationPreferences(
      quietStartMinutes: 22 * 60,
      quietEndMinutes: 7 * 60,
    );

    test('delays a late-night alert to next morning', () {
      final candidate = DateTime(2026, 8, 12, 23, 30);
      expect(
        planner.nextAllowedTime(candidate, preferences),
        DateTime(2026, 8, 13, 7),
      );
    });

    test('delays an early-morning alert to the same morning boundary', () {
      final candidate = DateTime(2026, 8, 12, 6, 15);
      expect(
        planner.nextAllowedTime(candidate, preferences),
        DateTime(2026, 8, 12, 7),
      );
    });

    test('leaves an alert outside quiet hours unchanged', () {
      final candidate = DateTime(2026, 8, 12, 12, 30);
      expect(planner.nextAllowedTime(candidate, preferences), candidate);
    });

    test('equal quiet boundaries disable quiet hours', () {
      const disabled = NotificationPreferences(
        quietStartMinutes: 22 * 60,
        quietEndMinutes: 22 * 60,
      );
      final candidate = DateTime(2026, 8, 12, 23, 30);
      expect(planner.nextAllowedTime(candidate, disabled), candidate);
    });
  });

  group('digest planning', () {
    test('daily digest creates a bounded future window', () {
      const preferences = NotificationPreferences(
        digestFrequency: NotificationDigestFrequency.daily,
        digestHour: 9,
        quietStartMinutes: 22 * 60,
        quietEndMinutes: 7 * 60,
      );
      final now = DateTime(2026, 8, 12, 10);
      final plans = planner.planDigests(preferences: preferences, now: now);

      expect(plans, hasLength(4));
      expect(plans.first.scheduledAt, DateTime(2026, 8, 13, 9));
      expect(plans.every((plan) => plan.isDigest), isTrue);
      expect(plans.every((plan) => plan.scheduledAt.isAfter(now)), isTrue);
    });

    test('weekday digest skips Saturday and Sunday', () {
      const preferences = NotificationPreferences(
        digestFrequency: NotificationDigestFrequency.weekdays,
        digestHour: 9,
      );
      final now = DateTime(2026, 8, 14, 10); // Friday.
      final plans = planner.planDigests(preferences: preferences, now: now);

      expect(plans.first.scheduledAt.weekday, DateTime.monday);
      expect(plans.first.scheduledAt, DateTime(2026, 8, 17, 9));
      expect(
        plans.every(
          (plan) => plan.scheduledAt.weekday >= DateTime.monday &&
              plan.scheduledAt.weekday <= DateTime.friday,
        ),
        isTrue,
      );
    });

    test('off frequency creates no digest schedule', () {
      final plans = planner.planDigests(
        preferences: const NotificationPreferences(),
        now: DateTime(2026, 8, 12, 10),
      );
      expect(plans, isEmpty);
    });
  });

  group('Tier 2 planning', () {
    test('filters other tiers and skips previously notified fingerprints', () {
      final insights = [
        _insight('new-tier2', InsightTier.tier2),
        _insight('old-tier2', InsightTier.tier2),
        _insight('tier1', InsightTier.tier1),
        _insight('tier3', InsightTier.tier3),
      ];
      final plans = planner.planTier2Alerts(
        insights: insights,
        preferences: const NotificationPreferences(tier2AlertsEnabled: true),
        deliveryState: const NotificationDeliveryState(
          notifiedFingerprints: ['old-tier2'],
        ),
        now: DateTime(2026, 8, 12, 12),
      );

      expect(plans, hasLength(1));
      expect(plans.single.insightFingerprint, 'new-tier2');
      expect(plans.single.payload.insightFingerprint, 'new-tier2');
    });

    test('delays new Tier 2 alerts until quiet hours end', () {
      final plans = planner.planTier2Alerts(
        insights: [_insight('quiet', InsightTier.tier2)],
        preferences: const NotificationPreferences(
          tier2AlertsEnabled: true,
          quietStartMinutes: 22 * 60,
          quietEndMinutes: 7 * 60,
        ),
        deliveryState: const NotificationDeliveryState(),
        now: DateTime(2026, 8, 12, 23),
      );

      expect(plans.single.scheduledAt, DateTime(2026, 8, 13, 7));
    });

    test('disabled Tier 2 alerts create no schedule', () {
      final plans = planner.planTier2Alerts(
        insights: [_insight('new-tier2', InsightTier.tier2)],
        preferences: const NotificationPreferences(),
        deliveryState: const NotificationDeliveryState(),
        now: DateTime(2026, 8, 12, 12),
      );
      expect(plans, isEmpty);
    });
  });
}

ProactiveInsight _insight(String fingerprint, InsightTier tier) {
  return ProactiveInsight(
    fingerprint: fingerprint,
    kind: tier == InsightTier.tier2
        ? InsightKind.followUp
        : tier == InsightTier.tier3
        ? InsightKind.aiRecommendation
        : InsightKind.relatedMemory,
    tier: tier,
    severity: InsightSeverity.recommendation,
    title: 'Insight $fingerprint',
    body: 'Useful context for $fingerprint.',
    evidenceAt: DateTime(2026, 8, 12, 9),
    sources: const <InsightSourceReference>[],
  );
}
