import 'package:mindly/features/ai_settings/data/secure_spend_store.dart';
import 'package:mindly/features/ai_settings/domain/cost_models.dart';

class SpendGuard {
  SpendGuard(this._ledger);

  final SpendLedger _ledger;

  Future<SpendDecision> evaluate({
    required CostEstimate estimate,
    required SpendCaps caps,
    required DateTime now,
  }) async {
    final utcNow = now.toUtc();
    final startOfDay = DateTime.utc(utcNow.year, utcNow.month, utcNow.day);
    final weekStart = utcNow.subtract(const Duration(days: 7));

    final weeklyEntries = await _ledger.entriesSince(weekStart);
    final weeklyUsed = weeklyEntries.fold<double>(
      0,
      (total, entry) => total + entry.usd,
    );
    final dailyUsed = weeklyEntries
        .where((entry) => !entry.at.isBefore(startOfDay))
        .fold<double>(0, (total, entry) => total + entry.usd);

    final dailyProjected = dailyUsed + estimate.estimatedUsd;
    final weeklyProjected = weeklyUsed + estimate.estimatedUsd;
    final dailyCap = caps.dailyUsd;
    final weeklyCap = caps.weeklyUsd;

    if (dailyCap != null && dailyProjected > dailyCap) {
      return SpendDecision.blocked(
        estimate: estimate,
        reason: SpendBlockReason.dailyCap,
        dailyProjectedUsd: dailyProjected,
        weeklyProjectedUsd: weeklyProjected,
      );
    }

    if (weeklyCap != null && weeklyProjected > weeklyCap) {
      return SpendDecision.blocked(
        estimate: estimate,
        reason: SpendBlockReason.weeklyCap,
        dailyProjectedUsd: dailyProjected,
        weeklyProjectedUsd: weeklyProjected,
      );
    }

    return SpendDecision.allowed(
      estimate: estimate,
      dailyProjectedUsd: dailyProjected,
      weeklyProjectedUsd: weeklyProjected,
    );
  }
}
