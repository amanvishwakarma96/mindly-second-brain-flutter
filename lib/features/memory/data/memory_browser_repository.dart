import 'package:drift/drift.dart';
import 'package:mindly/core/database/mindly_database.dart';
import 'package:mindly/features/memory/domain/memory_models.dart';

class MemoryBrowserRepository {
  MemoryBrowserRepository(this._database);

  final MindlyDatabase _database;

  Future<List<MemoryListItem>> list(
    MemoryEntityType type, {
    CaptureBrowserFilter captureFilter = const CaptureBrowserFilter(),
    int limit = 100,
  }) {
    return switch (type) {
      MemoryEntityType.capture => _listCaptures(
        filter: captureFilter,
        limit: limit,
      ),
      MemoryEntityType.person => _listPeople(limit: limit),
      MemoryEntityType.topic => _listTopics(limit: limit),
      MemoryEntityType.commitment => _listCommitments(limit: limit),
    };
  }

  Future<List<MemoryListItem>> _listCaptures({
    required CaptureBrowserFilter filter,
    required int limit,
  }) async {
    if (limit <= 0) {
      return const [];
    }

    final query = _database.select(_database.captures);
    final context = filter.context?.trim();
    final mode = filter.mode?.trim();

    if (context != null && context.isNotEmpty) {
      query.where((row) => row.context.equals(context));
    }
    if (mode != null && mode.isNotEmpty) {
      query.where((row) => row.mode.equals(mode));
    }
    if (filter.isPinned != null) {
      query.where((row) => row.isPinned.equals(filter.isPinned!));
    }

    query
      ..orderBy([
        (row) => OrderingTerm(
          expression: row.createdAt,
          mode: OrderingMode.desc,
        ),
        (row) => OrderingTerm(expression: row.id),
      ])
      ..limit(limit);

    final rows = await query.get();
    return rows.map(_captureItem).toList(growable: false);
  }

  Future<List<MemoryListItem>> _listPeople({required int limit}) async {
    if (limit <= 0) {
      return const [];
    }
    final query = _database.select(_database.people)
      ..orderBy([(row) => OrderingTerm(expression: row.normalizedName)])
      ..limit(limit);
    final rows = await query.get();
    return rows
        .map(
          (row) => MemoryListItem(
            type: MemoryEntityType.person,
            id: row.id,
            title: row.displayName,
            createdAt: row.createdAt,
          ),
        )
        .toList(growable: false);
  }

  Future<List<MemoryListItem>> _listTopics({required int limit}) async {
    if (limit <= 0) {
      return const [];
    }
    final query = _database.select(_database.topics)
      ..orderBy([(row) => OrderingTerm(expression: row.normalizedLabel)])
      ..limit(limit);
    final rows = await query.get();
    return rows
        .map(
          (row) => MemoryListItem(
            type: MemoryEntityType.topic,
            id: row.id,
            title: row.label,
            createdAt: row.createdAt,
          ),
        )
        .toList(growable: false);
  }

  Future<List<MemoryListItem>> _listCommitments({required int limit}) async {
    if (limit <= 0) {
      return const [];
    }
    final query = _database.select(_database.commitments)
      ..orderBy([
        (row) => OrderingTerm(
          expression: row.createdAt,
          mode: OrderingMode.desc,
        ),
        (row) => OrderingTerm(expression: row.id),
      ])
      ..limit(limit);
    final rows = await query.get();
    return rows
        .map(
          (row) => MemoryListItem(
            type: MemoryEntityType.commitment,
            id: row.id,
            title: row.commitmentText,
            subtitle: row.status,
            createdAt: row.createdAt,
          ),
        )
        .toList(growable: false);
  }

  Future<MemoryListItem?> getItem(MemoryEntityType type, String id) async {
    switch (type) {
      case MemoryEntityType.capture:
        final row = await (_database.select(
          _database.captures,
        )..where((value) => value.id.equals(id))).getSingleOrNull();
        return row == null ? null : _captureItem(row);
      case MemoryEntityType.person:
        final row = await (_database.select(
          _database.people,
        )..where((value) => value.id.equals(id))).getSingleOrNull();
        if (row == null) {
          return null;
        }
        return MemoryListItem(
          type: MemoryEntityType.person,
          id: row.id,
          title: row.displayName,
          createdAt: row.createdAt,
        );
      case MemoryEntityType.topic:
        final row = await (_database.select(
          _database.topics,
        )..where((value) => value.id.equals(id))).getSingleOrNull();
        if (row == null) {
          return null;
        }
        return MemoryListItem(
          type: MemoryEntityType.topic,
          id: row.id,
          title: row.label,
          createdAt: row.createdAt,
        );
      case MemoryEntityType.commitment:
        final row = await (_database.select(
          _database.commitments,
        )..where((value) => value.id.equals(id))).getSingleOrNull();
        if (row == null) {
          return null;
        }
        return MemoryListItem(
          type: MemoryEntityType.commitment,
          id: row.id,
          title: row.commitmentText,
          subtitle: row.status,
          createdAt: row.createdAt,
        );
    }
  }

  Future<MemoryCaptureContent?> getCaptureContent(String id) async {
    final row = await (_database.select(
      _database.captures,
    )..where((value) => value.id.equals(id))).getSingleOrNull();
    if (row == null) {
      return null;
    }
    return MemoryCaptureContent(
      rawText: row.rawText,
      transcript: row.transcript,
      summary: row.summary,
    );
  }

  Future<List<MemoryRelationshipView>> relationshipsFor({
    required String entityType,
    required String entityId,
  }) async {
    final query = _database.select(_database.memoryRelationships)
      ..where(
        (row) =>
            (row.fromType.equals(entityType) & row.fromId.equals(entityId)) |
            (row.toType.equals(entityType) & row.toId.equals(entityId)),
      )
      ..orderBy([
        (row) => OrderingTerm(expression: row.createdAt),
        (row) => OrderingTerm(expression: row.id),
      ]);
    final rows = await query.get();
    return rows
        .map(
          (row) => MemoryRelationshipView(
            id: row.id,
            fromType: row.fromType,
            fromId: row.fromId,
            relationType: row.relationType,
            toType: row.toType,
            toId: row.toId,
          ),
        )
        .toList(growable: false);
  }

  MemoryListItem _captureItem(Capture row) {
    final summary = row.summary?.trim();
    final transcript = row.transcript?.trim();
    final rawText = row.rawText?.trim();
    final preferred = [summary, transcript, rawText].whereType<String>().firstWhere(
      (value) => value.isNotEmpty,
      orElse: () => 'Untitled capture',
    );
    final title = preferred.length > 120
        ? '${preferred.substring(0, 117)}...'
        : preferred;

    return MemoryListItem(
      type: MemoryEntityType.capture,
      id: row.id,
      title: title,
      subtitle: '${row.context} · ${row.mode}',
      createdAt: row.createdAt,
      context: row.context,
      mode: row.mode,
      isPinned: row.isPinned,
    );
  }
}
