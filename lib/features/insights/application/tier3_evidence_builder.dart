import 'package:mindly/features/insights/domain/insight_models.dart';
import 'package:mindly/features/insights/domain/tier3_models.dart';
import 'package:mindly/features/memory/domain/memory_models.dart';

typedef LocalInsightLoader = Future<List<ProactiveInsight>> Function();
typedef InsightSourceDetailLoader =
    Future<MemoryDetail?> Function(InsightSourceReference source);

class Tier3EvidenceBuilder {
  const Tier3EvidenceBuilder({
    required LocalInsightLoader insightLoader,
    required InsightSourceDetailLoader sourceDetailLoader,
    this.maxSources = 8,
    this.maxCharacters = 12000,
  }) : _insightLoader = insightLoader,
       _sourceDetailLoader = sourceDetailLoader;

  final LocalInsightLoader _insightLoader;
  final InsightSourceDetailLoader _sourceDetailLoader;
  final int maxSources;
  final int maxCharacters;

  Future<Tier3EvidenceBundle> build() async {
    if (maxSources <= 0 || maxCharacters <= 0) {
      return const Tier3EvidenceBundle(sources: [], totalCharacters: 0);
    }

    final localInsights = await _insightLoader();
    final orderedReferences = <InsightSourceReference>[];
    final seen = <String>{};
    for (final insight in localInsights) {
      for (final source in insight.sources) {
        if (seen.add(source.stableKey)) {
          orderedReferences.add(source);
          if (orderedReferences.length == maxSources) break;
        }
      }
      if (orderedReferences.length == maxSources) break;
    }

    final sources = <Tier3EvidenceSource>[];
    var usedCharacters = 0;
    for (final reference in orderedReferences) {
      final detail = await _sourceDetailLoader(reference);
      if (detail == null) continue;
      final raw = _contentFor(detail);
      if (raw.isEmpty) continue;
      final remaining = maxCharacters - usedCharacters;
      if (remaining <= 0) break;
      final content = raw.length <= remaining ? raw : raw.substring(0, remaining);
      if (content.trim().isEmpty) break;
      sources.add(
        Tier3EvidenceSource(
          sourceId: reference.stableKey,
          reference: reference,
          content: content,
        ),
      );
      usedCharacters += content.length;
      if (usedCharacters >= maxCharacters) break;
    }

    return Tier3EvidenceBundle(
      sources: List<Tier3EvidenceSource>.unmodifiable(sources),
      totalCharacters: usedCharacters,
    );
  }

  String _contentFor(MemoryDetail detail) {
    final sections = <String>[
      detail.item.title,
      if (detail.summary != null && detail.summary!.trim().isNotEmpty)
        detail.summary!.trim(),
      if (detail.transcript != null && detail.transcript!.trim().isNotEmpty)
        detail.transcript!.trim(),
      if (detail.rawText != null && detail.rawText!.trim().isNotEmpty)
        detail.rawText!.trim(),
    ];
    return sections.toSet().join('\n\n').trim();
  }
}
