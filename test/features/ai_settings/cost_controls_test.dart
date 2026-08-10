import 'package:flutter_test/flutter_test.dart';
import 'package:mindly/features/ai_settings/application/cost_estimator.dart';
import 'package:mindly/features/ai_settings/application/spend_guard.dart';
import 'package:mindly/features/ai_settings/data/secure_spend_store.dart';
import 'package:mindly/features/ai_settings/domain/cost_models.dart';

import '../../helpers/in_memory_secret_store.dart';

void main() {
  const estimator = CostEstimator();
  const rateCard = ModelRateCard(
    providerId: 'openai',
    model: 'example-model',
    inputUsdPerMillionTokens: 2,
    outputUsdPerMillionTokens: 8,
  );

  test('cost estimate is deterministic and keeps provider metadata', () {
    final estimate = estimator.estimate(
      rateCard: rateCard,
      inputTokens: 1000,
      outputTokens: 500,
    );

    expect(estimate.providerId, 'openai');
    expect(estimate.model, 'example-model');
    expect(estimate.estimatedUsd, closeTo(0.006, 0.0000001));
  });

  test('daily cap blocks a request before dispatch', () async {
    final store = SecureSpendStore(InMemorySecretStore());
    final now = DateTime.utc(2026, 8, 10, 12);
    await store.record(
      SpendEntry(at: now.subtract(const Duration(hours: 2)), usd: 0.08),
    );

    final decision = await SpendGuard(store).evaluate(
      estimate: estimator.estimate(
        rateCard: rateCard,
        inputTokens: 5000,
        outputTokens: 2500,
      ),
      caps: const SpendCaps(dailyUsd: 0.10, weeklyUsd: 2),
      now: now,
    );

    expect(decision.isAllowed, isFalse);
    expect(decision.blockReason, SpendBlockReason.dailyCap);
  });

  test('weekly cap blocks while daily cap still has room', () async {
    final store = SecureSpendStore(InMemorySecretStore());
    final now = DateTime.utc(2026, 8, 10, 12);
    await store.record(
      SpendEntry(at: now.subtract(const Duration(days: 3)), usd: 0.48),
    );

    final decision = await SpendGuard(store).evaluate(
      estimate: estimator.estimate(
        rateCard: rateCard,
        inputTokens: 5000,
        outputTokens: 2500,
      ),
      caps: const SpendCaps(dailyUsd: 1, weeklyUsd: 0.50),
      now: now,
    );

    expect(decision.isAllowed, isFalse);
    expect(decision.blockReason, SpendBlockReason.weeklyCap);
  });

  test('within-cap and disabled-cap requests are allowed', () async {
    final store = SecureSpendStore(InMemorySecretStore());
    final guard = SpendGuard(store);
    final now = DateTime.utc(2026, 8, 10, 12);
    final estimate = estimator.estimate(
      rateCard: rateCard,
      inputTokens: 1000,
      outputTokens: 500,
    );

    final within = await guard.evaluate(
      estimate: estimate,
      caps: const SpendCaps(dailyUsd: 1, weeklyUsd: 5),
      now: now,
    );
    final disabled = await guard.evaluate(
      estimate: estimate,
      caps: const SpendCaps(),
      now: now,
    );

    expect(within.isAllowed, isTrue);
    expect(disabled.isAllowed, isTrue);
  });

  test('spend caps round-trip through the secure metadata store', () async {
    final store = SecureSpendStore(InMemorySecretStore());
    const caps = SpendCaps(dailyUsd: 0.75, weeklyUsd: 3.5);

    await store.save(caps);
    final restored = await store.load();

    expect(restored.dailyUsd, 0.75);
    expect(restored.weeklyUsd, 3.5);
  });
}
