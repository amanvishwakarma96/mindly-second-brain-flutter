class ModelRateCard {
  const ModelRateCard({
    required this.providerId,
    required this.model,
    required this.inputUsdPerMillionTokens,
    required this.outputUsdPerMillionTokens,
  });

  final String providerId;
  final String model;
  final double inputUsdPerMillionTokens;
  final double outputUsdPerMillionTokens;
}

class CostEstimate {
  const CostEstimate({
    required this.providerId,
    required this.model,
    required this.inputTokens,
    required this.outputTokens,
    required this.estimatedUsd,
  });

  final String providerId;
  final String model;
  final int inputTokens;
  final int outputTokens;
  final double estimatedUsd;
}

class SpendCaps {
  const SpendCaps({this.dailyUsd, this.weeklyUsd});

  final double? dailyUsd;
  final double? weeklyUsd;

  bool get isDisabled => dailyUsd == null && weeklyUsd == null;

  Map<String, Object?> toJson() => {
    'dailyUsd': dailyUsd,
    'weeklyUsd': weeklyUsd,
  };

  factory SpendCaps.fromJson(Map<String, Object?> json) {
    return SpendCaps(
      dailyUsd: (json['dailyUsd'] as num?)?.toDouble(),
      weeklyUsd: (json['weeklyUsd'] as num?)?.toDouble(),
    );
  }
}

class SpendEntry {
  const SpendEntry({required this.at, required this.usd});

  final DateTime at;
  final double usd;

  Map<String, Object?> toJson() => {
    'at': at.toUtc().toIso8601String(),
    'usd': usd,
  };

  factory SpendEntry.fromJson(Map<String, Object?> json) {
    return SpendEntry(
      at: DateTime.parse(json['at']! as String).toUtc(),
      usd: (json['usd']! as num).toDouble(),
    );
  }
}

enum SpendBlockReason { dailyCap, weeklyCap }

class SpendDecision {
  const SpendDecision.allowed({
    required this.estimate,
    required this.dailyProjectedUsd,
    required this.weeklyProjectedUsd,
  }) : allowed = true,
       reason = null;

  const SpendDecision.blocked({
    required this.estimate,
    required this.reason,
    required this.dailyProjectedUsd,
    required this.weeklyProjectedUsd,
  }) : allowed = false;

  final bool allowed;
  final SpendBlockReason? reason;
  final CostEstimate estimate;
  final double dailyProjectedUsd;
  final double weeklyProjectedUsd;

  bool get isAllowed => allowed;
  SpendBlockReason? get blockReason => reason;
}
