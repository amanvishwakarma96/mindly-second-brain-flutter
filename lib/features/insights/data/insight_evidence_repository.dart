import 'package:drift/drift.dart';
import 'package:mindly/core/database/mindly_database.dart';
import 'package:mindly/features/insights/domain/insight_models.dart';
import 'package:mindly/features/memory/data/memory_browser_repository.dart';
import 'package:mindly/features/memory/domain/memory_models.dart';

class InsightRelationshipEvidence {
  const InsightRelationshipEvidence({
    required this.id,
    required this.relationType,
    required this.from,
    required this.to,
    required this.createdAt,
  });

  final String id;
  final String relationType;
  final InsightSourceReference from;
  final InsightSourceReference to;
  final DateTime createdAt;
}

class InsightCommitmentEvidence {
  const InsightCommitmentEvidence({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.commitmentSource,
    this.captureSource,
    this.dueDate,
  });

  final String id;
  final String text;
  final DateTime createdAt;
  final DateTime? dueDate;
  final InsightSourceReference commitmentSource;
  final InsightSourceReference? captureSource;

  List<InsightSourceReference> get sources => <InsightSourceReference>[
    commitmentSource,
    ?captureSource,
  ];
}

class InsightEvidenceRepository {
  factory InsightEvidenceRepository({
    required MindlyDatabase database,
    required MemoryBrowserRepository browserRepository,
  }) {
    return InsightEvidenceRepository._(database, browserRepository);
  }

  InsightEvidenceRepository._(this._database, this._browserRepository);

  final MindlyDatabase _database;
  final MemoryBrowserRepository _browserRepository;

  Future<List<InsightRelationshipEvidence>> loadTier1Relationships() async {
    final query = _database.select(_database.memoryRelationships)
      ..where(
        (row) =>
            row.relationType.equals('related_to') |
            row.relationType.equals('follows_up_on'),
      )
      ..orderBy([
        (row) => OrderingTerm(expression: row.createdAt),
        (row) => OrderingTerm(expression: row.id),
      ]);
    final rows = await query.get();
    final evidence = <InsightRelationshipEvidence>[];

    for (final row in rows) {
      final fromType = MemoryEntityType.tryParse(row.fromType);
      final toType = MemoryEntityType.tryParse(row.toType);
      if (fromType == null || toType == null) {
        continue;
      }
      if (row.relationType == 'follows_up_on' &&
          (fromType != MemoryEntityType.capture ||
              toType != MemoryEntityType.capture)) {
        continue;
      }
      final fromItem = await _browserRepository.getItem(fromType, row.fromId);
      final toItem = await _browserRepository.getItem(toType, row.toId);
      if (fromItem == null || toItem == null) {
        continue;
      }
      evidence.add(
        InsightRelationshipEvidence(
          id: row.id,
          relationType: row.relationType,
          from: InsightSourceReference(
            type: fromType,
            id: fromItem.id,
            title: fromItem.title,
          ),
          to: InsightSourceReference(
            type: toType,
            id: toItem.id,
            title: toItem.title,
          ),
          createdAt: row.createdAt,
        ),
      );
    }
    return evidence;
  }

  Future<List<InsightCommitmentEvidence>> loadOpenCommitments() async {
    final rows =
        await (_database.select(_database.commitments)..orderBy([
              (row) => OrderingTerm(expression: row.createdAt),
              (row) => OrderingTerm(expression: row.id),
            ]))
            .get();
    final evidence = <InsightCommitmentEvidence>[];

    for (final row in rows) {
      if (row.status.trim().toLowerCase() != 'open') {
        continue;
      }
      final commitmentItem = await _browserRepository.getItem(
        MemoryEntityType.commitment,
        row.id,
      );
      if (commitmentItem == null) {
        continue;
      }
      InsightSourceReference? captureSource;
      final captureId = row.captureId;
      if (captureId != null) {
        final capture = await _browserRepository.getItem(
          MemoryEntityType.capture,
          captureId,
        );
        if (capture != null) {
          captureSource = InsightSourceReference(
            type: MemoryEntityType.capture,
            id: capture.id,
            title: capture.title,
          );
        }
      }
      evidence.add(
        InsightCommitmentEvidence(
          id: row.id,
          text: row.commitmentText,
          dueDate: row.dueDate,
          createdAt: row.createdAt,
          commitmentSource: InsightSourceReference(
            type: MemoryEntityType.commitment,
            id: commitmentItem.id,
            title: commitmentItem.title,
          ),
          captureSource: captureSource,
        ),
      );
    }
    return evidence;
  }

  Future<MemoryDetail?> sourceDetail(InsightSourceReference source) async {
    final item = await _browserRepository.getItem(source.type, source.id);
    if (item == null) {
      return null;
    }
    final content = source.type == MemoryEntityType.capture
        ? await _browserRepository.getCaptureContent(source.id)
        : null;
    final relationships = await _browserRepository.relationshipsFor(
      entityType: source.type.wireName,
      entityId: source.id,
    );
    return MemoryDetail(
      item: item,
      rawText: content?.rawText,
      transcript: content?.transcript,
      summary: content?.summary,
      connections: relationships
          .map(
            (relation) => MemoryGraphEdge(
              id: relation.id,
              fromType: relation.fromType,
              fromId: relation.fromId,
              relationType: relation.relationType,
              toType: relation.toType,
              toId: relation.toId,
            ),
          )
          .toList(growable: false),
    );
  }
}
