import 'package:drift/drift.dart';
import 'package:mindly/core/database/mindly_database.dart';
import 'package:mindly/features/memory/domain/memory_models.dart';

class MemoryRepository {
  MemoryRepository(this._database);

  final MindlyDatabase _database;

  Future<void> saveCapture({
    required String id,
    required String mode,
    required String context,
    String? rawText,
    String? transcript,
    String? summary,
    String? audioPath,
    bool isIncomplete = false,
    bool isPinned = false,
    DateTime? createdAt,
  }) async {
    final now = DateTime.now().toUtc();
    await _database.transaction(() async {
      await _database
          .into(_database.captures)
          .insertOnConflictUpdate(
            CapturesCompanion.insert(
              id: id,
              mode: mode,
              context: context,
              rawText: Value(rawText),
              transcript: Value(transcript),
              summary: Value(summary),
              audioPath: Value(audioPath),
              isIncomplete: Value(isIncomplete),
              isPinned: Value(isPinned),
              createdAt: createdAt ?? now,
              updatedAt: now,
            ),
          );
      await _replaceSearchDocument(
        entityType: 'capture',
        entityId: id,
        content: [summary, transcript, rawText]
            .whereType<String>()
            .where((value) => value.trim().isNotEmpty)
            .join(' '),
      );
    });
  }

  Future<void> savePerson({
    required String id,
    required String displayName,
  }) async {
    final value = displayName.trim();
    await _database.transaction(() async {
      await _database
          .into(_database.people)
          .insertOnConflictUpdate(
            PeopleCompanion.insert(
              id: id,
              displayName: value,
              normalizedName: value.toLowerCase(),
              createdAt: DateTime.now().toUtc(),
            ),
          );
      await _replaceSearchDocument(
        entityType: 'person',
        entityId: id,
        content: value,
      );
    });
  }

  Future<void> saveTopic({required String id, required String label}) async {
    final value = label.trim();
    await _database.transaction(() async {
      await _database
          .into(_database.topics)
          .insertOnConflictUpdate(
            TopicsCompanion.insert(
              id: id,
              label: value,
              normalizedLabel: value.toLowerCase(),
              createdAt: DateTime.now().toUtc(),
            ),
          );
      await _replaceSearchDocument(
        entityType: 'topic',
        entityId: id,
        content: value,
      );
    });
  }

  Future<void> saveCommitment({
    required String id,
    required String text,
    String? captureId,
    DateTime? dueDate,
    String? owner,
    String status = 'open',
  }) async {
    await _database.transaction(() async {
      await _database
          .into(_database.commitments)
          .insertOnConflictUpdate(
            CommitmentsCompanion.insert(
              id: id,
              captureId: Value(captureId),
              commitmentText: text,
              dueDate: Value(dueDate),
              owner: Value(owner),
              status: Value(status),
              createdAt: DateTime.now().toUtc(),
            ),
          );
      await _replaceSearchDocument(
        entityType: 'commitment',
        entityId: id,
        content: text,
      );
    });
  }

  Future<void> link({
    required String id,
    required String fromType,
    required String fromId,
    required String relationType,
    required String toType,
    required String toId,
  }) {
    return _database
        .into(_database.memoryRelationships)
        .insertOnConflictUpdate(
          MemoryRelationshipsCompanion.insert(
            id: id,
            fromType: fromType,
            fromId: fromId,
            relationType: relationType,
            toType: toType,
            toId: toId,
            createdAt: DateTime.now().toUtc(),
          ),
        );
  }

  Future<List<MemorySearchHit>> keywordSearch(
    String query, {
    int limit = 20,
  }) async {
    final expression = _ftsExpression(query);
    if (expression == null || limit <= 0) {
      return const [];
    }

    final rows = await _database
        .customSelect(
          '''
      SELECT entity_type, entity_id, content, bm25(memory_fts) AS rank
      FROM memory_fts
      WHERE memory_fts MATCH ?
      ORDER BY rank
      LIMIT ?
      ''',
          variables: [Variable<String>(expression), Variable<int>(limit)],
        )
        .get();

    return rows
        .map(
          (row) => MemorySearchHit(
            entityType: row.read<String>('entity_type'),
            entityId: row.read<String>('entity_id'),
            content: row.read<String>('content'),
            rank: row.read<double>('rank'),
          ),
        )
        .toList(growable: false);
  }

  Future<void> deleteMemory({
    required String entityType,
    required String entityId,
  }) async {
    await _database.transaction(() async {
      await (_database.delete(_database.memoryRelationships)..where(
            (row) =>
                (row.fromType.equals(entityType) &
                    row.fromId.equals(entityId)) |
                (row.toType.equals(entityType) & row.toId.equals(entityId)),
          ))
          .go();
      await (_database.delete(_database.memoryEmbeddings)..where(
            (row) =>
                row.ownerType.equals(entityType) & row.ownerId.equals(entityId),
          ))
          .go();
      await _database.customStatement(
        'DELETE FROM memory_fts WHERE entity_type = ? AND entity_id = ?',
        [entityType, entityId],
      );

      switch (entityType) {
        case 'capture':
          await (_database.delete(
            _database.captures,
          )..where((row) => row.id.equals(entityId))).go();
        case 'person':
          await (_database.delete(
            _database.people,
          )..where((row) => row.id.equals(entityId))).go();
        case 'topic':
          await (_database.delete(
            _database.topics,
          )..where((row) => row.id.equals(entityId))).go();
        case 'commitment':
          await (_database.delete(
            _database.commitments,
          )..where((row) => row.id.equals(entityId))).go();
        default:
          throw ArgumentError.value(
            entityType,
            'entityType',
            'Unsupported memory entity type.',
          );
      }
    });
  }

  Future<void> wipeAll() async {
    await _database.transaction(() async {
      await _database.delete(_database.memoryRelationships).go();
      await _database.delete(_database.memoryEmbeddings).go();
      await _database.delete(_database.commitments).go();
      await _database.delete(_database.people).go();
      await _database.delete(_database.topics).go();
      await _database.delete(_database.captures).go();
      await _database.customStatement('DELETE FROM memory_fts');
    });
  }

  Future<void> _replaceSearchDocument({
    required String entityType,
    required String entityId,
    required String content,
  }) async {
    await _database.customStatement(
      'DELETE FROM memory_fts WHERE entity_type = ? AND entity_id = ?',
      [entityType, entityId],
    );
    if (content.trim().isNotEmpty) {
      await _database.customStatement(
        'INSERT INTO memory_fts(entity_type, entity_id, content) VALUES (?, ?, ?)',
        [entityType, entityId, content.trim()],
      );
    }
  }

  String? _ftsExpression(String query) {
    final tokens = query
        .trim()
        .split(RegExp(r'\s+'))
        .map((token) => token.trim())
        .where((token) => token.isNotEmpty)
        .map((token) => '"${token.replaceAll('"', '""')}"')
        .toList(growable: false);
    return tokens.isEmpty ? null : tokens.join(' AND ');
  }
}
