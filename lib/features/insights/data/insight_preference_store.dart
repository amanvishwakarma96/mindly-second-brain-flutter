import 'dart:convert';

import 'package:mindly/core/security/secret_store.dart';
import 'package:mindly/features/insights/domain/insight_models.dart';

abstract interface class InsightPreferenceStore {
  Future<InsightPreferences> load();

  Future<void> save(InsightPreferences preferences);
}

class SecureInsightPreferenceStore implements InsightPreferenceStore {
  SecureInsightPreferenceStore(this._store);

  static const _storageKey = 'mindly.insights.preferences.v1';

  final SecretStore _store;

  @override
  Future<InsightPreferences> load() async {
    final raw = await _store.read(key: _storageKey);
    if (raw == null || raw.trim().isEmpty) {
      return const InsightPreferences();
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const InsightPreferences();
      }
      final dismissed = (decoded['dismissed'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toSet();
      final mutedNames = (decoded['mutedKinds'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toSet();
      final muted = InsightKind.values
          .where((kind) => mutedNames.contains(kind.name))
          .toSet();
      return InsightPreferences(
        dismissedFingerprints: dismissed,
        mutedKinds: muted,
      );
    } on FormatException {
      return const InsightPreferences();
    }
  }

  @override
  Future<void> save(InsightPreferences preferences) {
    final dismissed = preferences.dismissedFingerprints.toList()..sort();
    final muted = preferences.mutedKinds.map((kind) => kind.name).toList()
      ..sort();
    return _store.write(
      key: _storageKey,
      value: jsonEncode(<String, Object>{
        'dismissed': dismissed,
        'mutedKinds': muted,
      }),
    );
  }
}
