import 'dart:convert';

import 'package:mindly/core/security/secret_store.dart';
import 'package:mindly/features/insights/domain/insight_models.dart';
import 'package:mindly/features/memory/domain/memory_models.dart';

abstract interface class Tier3InsightStore {
  Future<List<ProactiveInsight>> load();

  Future<void> save(List<ProactiveInsight> insights);
}

class SecureTier3InsightStore implements Tier3InsightStore {
  SecureTier3InsightStore(this._store);

  static const _storageKey = 'mindly.insights.tier3.v1';

  final SecretStore _store;

  @override
  Future<List<ProactiveInsight>> load() async {
    final raw = await _store.read(key: _storageKey);
    if (raw == null || raw.trim().isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      final insights = <ProactiveInsight>[];
      for (final value in decoded) {
        if (value is! Map) continue;
        final insight = _fromJson(Map<String, Object?>.from(value));
        if (insight != null) insights.add(insight);
      }
      return List<ProactiveInsight>.unmodifiable(insights);
    } on Object {
      return const [];
    }
  }

  @override
  Future<void> save(List<ProactiveInsight> insights) {
    final tier3 = insights
        .where((insight) => insight.tier == InsightTier.tier3)
        .take(20)
        .map(_toJson)
        .toList(growable: false);
    return _store.write(key: _storageKey, value: jsonEncode(tier3));
  }

  Map<String, Object?> _toJson(ProactiveInsight insight) => {
    'fingerprint': insight.fingerprint,
    'kind': insight.kind.name,
    'severity': insight.severity.name,
    'title': insight.title,
    'body': insight.body,
    'evidenceAt': insight.evidenceAt.toUtc().toIso8601String(),
    'sources': insight.sources
        .map(
          (source) => <String, Object?>{
            'type': source.type.wireName,
            'id': source.id,
            'title': source.title,
          },
        )
        .toList(growable: false),
  };

  ProactiveInsight? _fromJson(Map<String, Object?> json) {
    final fingerprint = json['fingerprint'];
    final title = json['title'];
    final body = json['body'];
    final evidenceAtValue = json['evidenceAt'];
    if (fingerprint is! String ||
        fingerprint.trim().isEmpty ||
        title is! String ||
        title.trim().isEmpty ||
        body is! String ||
        body.trim().isEmpty ||
        evidenceAtValue is! String) {
      return null;
    }

    final kindName = json['kind'];
    final severityName = json['severity'];
    final kind = InsightKind.values.where((value) => value.name == kindName).firstOrNull;
    final severity = InsightSeverity.values
        .where((value) => value.name == severityName)
        .firstOrNull;
    final evidenceAt = DateTime.tryParse(evidenceAtValue)?.toUtc();
    if (kind == null ||
        (kind != InsightKind.aiRecommendation && kind != InsightKind.aiWarning) ||
        severity == null ||
        evidenceAt == null) {
      return null;
    }

    final sourcesValue = json['sources'];
    if (sourcesValue is! List) return null;
    final sources = <InsightSourceReference>[];
    for (final value in sourcesValue) {
      if (value is! Map) continue;
      final sourceJson = Map<String, Object?>.from(value);
      final type = MemoryEntityType.tryParse(sourceJson['type'] as String? ?? '');
      final id = sourceJson['id'];
      final sourceTitle = sourceJson['title'];
      if (type == null ||
          id is! String ||
          id.trim().isEmpty ||
          sourceTitle is! String ||
          sourceTitle.trim().isEmpty) {
        continue;
      }
      sources.add(
        InsightSourceReference(type: type, id: id, title: sourceTitle),
      );
    }
    if (sources.isEmpty) return null;

    return ProactiveInsight(
      fingerprint: fingerprint,
      kind: kind,
      tier: InsightTier.tier3,
      severity: severity,
      title: title,
      body: body,
      evidenceAt: evidenceAt,
      sources: List<InsightSourceReference>.unmodifiable(sources),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
