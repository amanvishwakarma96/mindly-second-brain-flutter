import 'package:flutter_test/flutter_test.dart';
import 'package:mindly/features/insights/application/tier3_evidence_builder.dart';
import 'package:mindly/features/insights/domain/insight_models.dart';
import 'package:mindly/features/memory/domain/memory_models.dart';

void main() {
  test('Tier 3 evidence is deterministic, unique, and bounded', () async {
    final sources = List<InsightSourceReference>.generate(
      12,
      (index) => InsightSourceReference(
        type: MemoryEntityType.capture,
        id: 'capture-$index',
        title: 'Capture $index',
      ),
    );
    final insight = ProactiveInsight(
      fingerprint: 'local',
      kind: InsightKind.relatedMemory,
      tier: InsightTier.tier1,
      severity: InsightSeverity.info,
      title: 'Local signal',
      body: 'Connected memories',
      evidenceAt: DateTime.utc(2026, 8, 11),
      sources: <InsightSourceReference>[...sources, sources.first],
    );
    final longText = List<String>.filled(3000, 'x').join();
    final builder = Tier3EvidenceBuilder(
      insightLoader: () async => [insight],
      sourceDetailLoader: (source) async => MemoryDetail(
        item: MemoryListItem(
          type: source.type,
          id: source.id,
          title: source.title,
        ),
        rawText: longText,
      ),
      maxSources: 8,
      maxCharacters: 12000,
    );

    final first = await builder.build();
    final second = await builder.build();

    expect(first.sources.length, lessThanOrEqualTo(8));
    expect(first.totalCharacters, 12000);
    expect(
      first.sources.map((source) => source.sourceId).toSet().length,
      first.sources.length,
    );
    expect(
      second.sources.map((source) => source.sourceId).toList(),
      first.sources.map((source) => source.sourceId).toList(),
    );
    expect(
      first.sources.every((source) => source.sourceId.startsWith('capture:')),
      isTrue,
    );
  });

  test('Tier 3 evidence skips unresolved local references', () async {
    const source = InsightSourceReference(
      type: MemoryEntityType.capture,
      id: 'missing',
      title: 'Missing',
    );
    final builder = Tier3EvidenceBuilder(
      insightLoader: () async => [
        ProactiveInsight(
          fingerprint: 'local',
          kind: InsightKind.followUp,
          tier: InsightTier.tier1,
          severity: InsightSeverity.recommendation,
          title: 'Follow-up',
          body: 'Body',
          evidenceAt: DateTime.utc(2026, 8, 11),
          sources: const [source],
        ),
      ],
      sourceDetailLoader: (_) async => null,
    );

    final bundle = await builder.build();
    expect(bundle.isEmpty, isTrue);
    expect(bundle.totalCharacters, 0);
  });
}
