import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'mindly_database.g.dart';

class Captures extends Table {
  TextColumn get id => text()();
  TextColumn get mode => text()();
  TextColumn get context => text()();
  TextColumn get rawText => text().nullable()();
  TextColumn get transcript => text().nullable()();
  TextColumn get summary => text().nullable()();
  TextColumn get audioPath => text().nullable()();
  BoolColumn get isIncomplete =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class People extends Table {
  TextColumn get id => text()();
  TextColumn get displayName => text()();
  TextColumn get normalizedName => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Topics extends Table {
  TextColumn get id => text()();
  TextColumn get label => text()();
  TextColumn get normalizedLabel => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Commitments extends Table {
  TextColumn get id => text()();
  TextColumn get captureId => text()
      .nullable()
      .references(Captures, #id, onDelete: KeyAction.cascade)();
  TextColumn get commitmentText => text().named('text')();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get owner => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('open'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class MemoryRelationships extends Table {
  TextColumn get id => text()();
  TextColumn get fromType => text()();
  TextColumn get fromId => text()();
  TextColumn get relationType => text()();
  TextColumn get toType => text()();
  TextColumn get toId => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class MemoryEmbeddings extends Table {
  TextColumn get id => text()();
  TextColumn get ownerType => text()();
  TextColumn get ownerId => text()();
  TextColumn get model => text()();
  IntColumn get dimensions => integer()();
  BlobColumn get vector => blob()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {ownerType, ownerId, model},
      ];
}

@DriftDatabase(
  tables: [
    Captures,
    People,
    Topics,
    Commitments,
    MemoryRelationships,
    MemoryEmbeddings,
  ],
)
class MindlyDatabase extends _$MindlyDatabase {
  MindlyDatabase(super.executor);

  MindlyDatabase.defaults()
      : super(
          driftDatabase(
            name: 'mindly',
            native: const DriftNativeOptions(shareAcrossIsolates: true),
            web: DriftWebOptions(
              sqlite3Wasm: Uri.parse('sqlite3.wasm'),
              driftWorker: Uri.parse('drift_worker.js'),
            ),
          ),
        );

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _createSearchIndex();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(captures, captures.isPinned);
            await m.createTable(people);
            await m.createTable(topics);
            await m.createTable(commitments);
            await m.createTable(memoryRelationships);
            await m.createTable(memoryEmbeddings);
          }
          await _createSearchIndex();
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> _createSearchIndex() async {
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS memory_fts USING fts5(
        entity_type UNINDEXED,
        entity_id UNINDEXED,
        content,
        tokenize = 'unicode61'
      )
    ''');
  }
}
