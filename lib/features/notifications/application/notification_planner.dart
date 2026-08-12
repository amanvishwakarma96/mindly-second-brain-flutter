import 'package:mindly/app/app_routes.dart';
import 'package:mindly/features/insights/domain/insight_models.dart';
import 'package:mindly/features/notifications/domain/notification_models.dart';

class NotificationPlanner {
  const NotificationPlanner({
    this.digestWindowSize = 14,
    this.maxTier2Alerts = 8,
  });

  final int digestWindowSize;
  final int maxTier2Alerts;

  DateTime nextAllowedTime(DateTime candidate, NotificationPreferences prefs) {
    if (!prefs.quietHoursEnabled) return candidate;

    final minuteOfDay = candidate.hour * 60 + candidate.minute;
    final start = prefs.quietStartMinutes;
    final end = prefs.quietEndMinutes;

    if (start < end) {
      if (minuteOfDay >= start && minuteOfDay < end) {
        return DateTime(
          candidate.year,
          candidate.month,
          candidate.day,
          end ~/ 60,
          end % 60,
        );
      }
      return candidate;
    }

    if (minuteOfDay >= start) {
      final tomorrow = candidate.add(const Duration(days: 1));
      return DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        end ~/ 60,
        end % 60,
      );
    }
    if (minuteOfDay < end) {
      return DateTime(
        candidate.year,
        candidate.month,
        candidate.day,
        end ~/ 60,
        end % 60,
      );
    }
    return candidate;
  }

  List<PlannedNotification> planTier2Alerts({
    required List<ProactiveInsight> insights,
    required NotificationPreferences preferences,
    required NotificationDeliveryState deliveryState,
    required DateTime now,
  }) {
    if (!preferences.tier2AlertsEnabled) return const <PlannedNotification>[];

    final notified = deliveryState.notifiedFingerprints.toSet();
    final candidates = insights
        .where((insight) => insight.tier == InsightTier.tier2)
        .where((insight) => !notified.contains(insight.fingerprint))
        .take(maxTier2Alerts)
        .toList(growable: false);

    return <PlannedNotification>[
      for (var index = 0; index < candidates.length; index++)
        _tier2Plan(
          candidates[index],
          nextAllowedTime(now.add(Duration(minutes: index + 1)), preferences),
        ),
    ];
  }

  List<PlannedNotification> planDigests({
    required NotificationPreferences preferences,
    required DateTime now,
  }) {
    if (preferences.digestFrequency == NotificationDigestFrequency.off) {
      return const <PlannedNotification>[];
    }

    final plans = <PlannedNotification>[];
    var cursor = DateTime(now.year, now.month, now.day);
    var safety = 0;
    while (plans.length < digestWindowSize && safety < 40) {
      safety++;
      final isWeekday =
          cursor.weekday >= DateTime.monday &&
          cursor.weekday <= DateTime.friday;
      final eligible =
          preferences.digestFrequency == NotificationDigestFrequency.daily ||
          isWeekday;
      if (eligible) {
        final candidate = DateTime(
          cursor.year,
          cursor.month,
          cursor.day,
          preferences.digestHour,
          preferences.digestMinute,
        );
        final allowed = nextAllowedTime(candidate, preferences);
        if (allowed.isAfter(now)) {
          plans.add(
            PlannedNotification(
              id: _digestId(allowed),
              title: 'Mindly digest',
              body: 'A few saved memories may be worth revisiting.',
              scheduledAt: allowed,
              payload: const NotificationPayload(route: AppRoutes.insights),
              isDigest: true,
            ),
          );
        }
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    return plans;
  }

  PlannedNotification _tier2Plan(ProactiveInsight insight, DateTime when) {
    return PlannedNotification(
      id: _stableAlertId(insight.fingerprint),
      title: insight.title,
      body: insight.body,
      scheduledAt: when,
      payload: NotificationPayload(
        route: AppRoutes.insights,
        insightFingerprint: insight.fingerprint,
      ),
      insightFingerprint: insight.fingerprint,
    );
  }

  int _stableAlertId(String value) {
    var hash = 0x811c9dc5;
    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return 100000 + (hash % 1500000000);
  }

  int _digestId(DateTime date) {
    final dateCode = date.year * 10000 + date.month * 100 + date.day;
    return 1800000000 + (dateCode % 300000000);
  }
}
