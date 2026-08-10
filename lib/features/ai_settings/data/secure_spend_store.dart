import 'dart:convert';

import 'package:mindly/core/security/secret_store.dart';
import 'package:mindly/features/ai_settings/domain/cost_models.dart';

abstract interface class SpendLedger {
  Future<List<SpendEntry>> entriesSince(DateTime startInclusive);

  Future<void> record(SpendEntry entry);
}

abstract interface class SpendCapsRepository {
  Future<SpendCaps> load();

  Future<void> save(SpendCaps caps);
}

class SecureSpendStore implements SpendLedger, SpendCapsRepository {
  SecureSpendStore(this._store);

  static const _entriesKey = 'mindly.ai-spend.entries.v1';
  static const _capsKey = 'mindly.ai-spend.caps.v1';

  final SecretStore _store;

  @override
  Future<List<SpendEntry>> entriesSince(DateTime startInclusive) async {
    final entries = await _loadEntries();
    final cutoff = startInclusive.toUtc();
    return entries
        .where((entry) => !entry.at.isBefore(cutoff))
        .toList(growable: false);
  }

  @override
  Future<void> record(SpendEntry entry) async {
    final entries = await _loadEntries();
    final pruneBefore = entry.at.toUtc().subtract(const Duration(days: 8));
    final retained = entries
        .where((candidate) => !candidate.at.isBefore(pruneBefore))
        .toList()
      ..add(entry);
    await _store.write(
      key: _entriesKey,
      value: jsonEncode(retained.map((item) => item.toJson()).toList()),
    );
  }

  @override
  Future<SpendCaps> load() async {
    final raw = await _store.read(key: _capsKey);
    if (raw == null || raw.isEmpty) {
      return const SpendCaps();
    }
    final decoded = Map<String, Object?>.from(jsonDecode(raw) as Map);
    return SpendCaps.fromJson(decoded);
  }

  @override
  Future<void> save(SpendCaps caps) {
    _validateCap(caps.dailyUsd, 'dailyUsd');
    _validateCap(caps.weeklyUsd, 'weeklyUsd');
    return _store.write(key: _capsKey, value: jsonEncode(caps.toJson()));
  }

  Future<List<SpendEntry>> _loadEntries() async {
    final raw = await _store.read(key: _entriesKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    final decoded = jsonDecode(raw) as List<Object?>;
    return decoded
        .map(
          (item) => SpendEntry.fromJson(
            Map<String, Object?>.from(item! as Map),
          ),
        )
        .toList(growable: false);
  }

  void _validateCap(double? value, String field) {
    if (value != null && value <= 0) {
      throw ArgumentError.value(value, field, 'Spend cap must be positive.');
    }
  }
}
