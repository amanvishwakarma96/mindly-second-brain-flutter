import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindly/core/database/mindly_database.dart';
import 'package:mindly/features/insights/application/proactive_insight_service.dart';
import 'package:mindly/features/insights/data/insight_evidence_repository.dart';
import 'package:mindly/features/insights/data/insight_preference_store.dart';
import 'package:mindly/features/insights/domain/insight_models.dart';
import 'package:mindly/features/memory/data/memory_browser_repository.dart';
import 'package:mindly/features/memory/data/memory_repository.dart';
import 'package:mindly/features/memory/domain/memory_models.dart';
import '../../helpers/in_memory_secret_store.dart';

void main() {
  final now = DateTime.utc(2026, 8, 11, 10);
  late MindlyDatabase database;
  late MemoryRepository memoryRepository;
  late InMemorySecretStore secrets;
  late SecureInsightPreferenceStore preferences;
  late ProactiveInsightService service;

  setUp(() {
    database = MindlyDatabase(NativeDatabase.memory());
    memoryRepository = MemoryRepository(database);
    secrets = InMemorySecretStore();
    preferences = SecureInsightPreferenceStore(secrets);
    final browserRepository = MemoryBrowserRepository(database);
    service = ProactiveInsightService(
      evidenceRepository: InsightEvidenceRepository(
        database: database,
        browserRepository: browserRepository,
      ),
      preferenceStore: preferences,
      clock: () => now,
    );
  });

  tearDown(() => database.close());

  test(
    'Tier 1 relationships are grounded, directional and deduplicated',
    () async {
      await memoryRepository.saveCapture(
        id: 'c1',
        mode: 'text',
        context: 'work',
        summary: 'Launch plan',
      );
      await memoryRepository.saveCapture(
        id: 'c2',
        mode: 'text',
        context: 'work',
        summary: 'Launch follow-up',
      );
      await memoryRepository.link(
        id: 'r-related-1',
        fromType: 'capture',
        fromId: 'c1',
        relationType: 'related_to',
        toType: 'capture',
        toId: 'c2',
      );
      await memoryRepository.link(
        id: 'r-related-2',
        fromType: 'capture',
        fromId: 'c2',
        relationType: 'related_to',
        toType: 'capture',
        toId: 'c1',
      );
      await memoryRepository.link(
        id: 'r-follow',
        fromType: 'capture',
        fromId: 'c2',
        relationType: 'follows_up_on',
        toType: 'capture',
        toId: 'c1',
      );

      final insights = await service.load();
      final related = insights.where(
        (item) => item.kind == InsightKind.relatedMemory,
      );
      final followUp = insights.singleWhere(
        (item) => item.kind == InsightKind.followUp,
      );

      expect(related, hasLength(1));
      expect(related.single.sources, hasLength(2));
      expect(followUp.sources.map((source) => source.id), ['c2', 'c1']);
      expect(followUp.tier, InsightTier.tier1);
    },
  );

  test(
    'Tier 2 commitment rules respect time boundaries and priority',
    () async {
      await _insertCommitment(
        database,
        id: 'overdue',
        text: 'Send overdue draft',
        dueDate: now.subtract(const Duration(hours: 1)),
        createdAt: now.subtract(const Duration(days: 2)),
      );
      await _insertCommitment(
        database,
        id: 'soon',
        text: 'Prepare review',
        dueDate: now.add(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 1)),
      );
      await _insertCommitment(
        database,
        id: 'far',
        text: 'Future item',
        dueDate: now.add(const Duration(days: 5)),
        createdAt: now,
      );
      await _insertCommitment(
        database,
        id: 'stale',
        text: 'Old open task',
        createdAt: now.subtract(const Duration(days: 15)),
      );
      await _insertCommitment(
        database,
        id: 'fresh',
        text: 'Fresh open task',
        createdAt: now.subtract(const Duration(days: 2)),
      );
      await _insertCommitment(
        database,
        id: 'closed',
        text: 'Already done',
        status: 'closed',
        dueDate: now.subtract(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 3)),
      );

      final insights = await service.load();

      expect(insights.first.kind, InsightKind.overdueCommitment);
      expect(
        insights.map((item) => item.kind),
        containsAll(<InsightKind>[
          InsightKind.overdueCommitment,
          InsightKind.dueSoonCommitment,
          InsightKind.staleCommitment,
        ]),
      );
      expect(insights.any((item) => item.body == 'Future item'), isFalse);
      expect(insights.any((item) => item.body == 'Fresh open task'), isFalse);
      expect(insights.any((item) => item.body == 'Already done'), isFalse);
      expect(insights.every((item) => item.sources.isNotEmpty), isTrue);
    },
  );

  test('ordering and fingerprints are stable across repeated evaluation', () async {
    await _insertCommitment(
      database,
      id: 'overdue-b',
      text: 'Second overdue item',
      dueDate: now.subtract(const Duration(hours: 2)),
      createdAt: now.subtract(const Duration(days: 2)),
    );
    await _insertCommitment(
      database,
      id: 'overdue-a',
      text: 'First overdue item',
      dueDate: now.subtract(const Duration(hours: 1)),
      createdAt: now.subtract(const Duration(days: 1)),
    );
    await _insertCommitment(
      database,
      id: 'soon',
      text: 'Soon item',
      dueDate: now.add(const Duration(days: 1)),
      createdAt: now,
    );

    final first = await service.load();
    final second = await service.load();

    expect(
      second.map((item) => item.fingerprint).toList(),
      first.map((item) => item.fingerprint).toList(),
    );
    expect(
      first.map((item) => item.kind).toList(),
      <InsightKind>[
        InsightKind.overdueCommitment,
        InsightKind.overdueCommitment,
        InsightKind.dueSoonCommitment,
      ],
    );
    expect(first.first.body, 'First overdue item');
  });

  test(
    'dismissal persists until material commitment evidence changes',
    () async {
      await _insertCommitment(
        database,
        id: 'due',
        text: 'Send the deck',
        dueDate: now.add(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 1)),
      );
      final first = (await service.load()).single;
      await service.dismiss(first.fingerprint);

      expect(await service.load(), isEmpty);

      final changedDueDate = now.add(const Duration(days: 2));
      await (database.update(database.commitments)
            ..where((row) => row.id.equals('due')))
          .write(CommitmentsCompanion(dueDate: Value(changedDueDate)));

      final changed = (await service.load()).single;
      expect(changed.fingerprint, isNot(first.fingerprint));
      expect(changed.kind, InsightKind.dueSoonCommitment);
    },
  );

  test(
    'mute and unmute suppress only the insight kind without deleting evidence',
    () async {
      await memoryRepository.saveCapture(
        id: 'left',
        mode: 'text',
        context: 'personal',
        summary: 'Left memory',
      );
      await memoryRepository.saveCapture(
        id: 'right',
        mode: 'text',
        context: 'personal',
        summary: 'Right memory',
      );
      await memoryRepository.link(
        id: 'rel',
        fromType: 'capture',
        fromId: 'left',
        relationType: 'related_to',
        toType: 'capture',
        toId: 'right',
      );

      expect((await service.load()).single.kind, InsightKind.relatedMemory);
      await service.setMuted(InsightKind.relatedMemory, true);
      expect(await service.load(), isEmpty);
      expect(await service.mutedKinds(), contains(InsightKind.relatedMemory));
      expect(
        await database.select(database.memoryRelationships).get(),
        hasLength(1),
      );
      expect(await database.select(database.captures).get(), hasLength(2));

      await service.setMuted(InsightKind.relatedMemory, false);
      expect((await service.load()).single.kind, InsightKind.relatedMemory);
    },
  );

  test(
    'empty evidence produces no fabricated insight and source detail resolves locally',
    () async {
      expect(await service.load(), isEmpty);

      await memoryRepository.saveCapture(
        id: 'source',
        mode: 'text',
        context: 'work',
        rawText: 'Raw local source',
        summary: 'Source summary',
      );
      final detail = await service.sourceDetail(
        const InsightSourceReference(
          type: MemoryEntityType.capture,
          id: 'source',
          title: 'Source summary',
        ),
      );
      expect(detail?.summary, 'Source summary');
      expect(detail?.rawText, 'Raw local source');
    },
  );
}

Future<void> _insertCommitment(
  MindlyDatabase database, {
  required String id,
  required String text,
  required DateTime createdAt,
  DateTime? dueDate,
  String status = 'open',
}) {
  return database
      .into(database.commitments)
      .insert(
        CommitmentsCompanion.insert(
          id: id,
          commitmentText: text,
          dueDate: Value(dueDate),
          status: Value(status),
          createdAt: createdAt,
        ),
      );
}
