import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindly/core/database/mindly_database.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  test('fresh database creates version 2 schema and FTS table', () async {
    final database = MindlyDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    expect(database.schemaVersion, 2);
    final fts = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'memory_fts'",
        )
        .getSingleOrNull();
    expect(fts, isNotNull);
  });

  test('migrates v1 capture schema to the complete v2 data layer', () async {
    final directory = await Directory.systemTemp.createTemp(
      'mindly-migration-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/migration.sqlite');

    final raw = sqlite.sqlite3.open(file.path);
    raw.execute('''
      CREATE TABLE captures (
        id TEXT NOT NULL PRIMARY KEY,
        mode TEXT NOT NULL,
        context TEXT NOT NULL,
        raw_text TEXT,
        transcript TEXT,
        summary TEXT,
        audio_path TEXT,
        is_incomplete INTEGER NOT NULL DEFAULT 0 CHECK (is_incomplete IN (0, 1)),
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    raw.execute('PRAGMA user_version = 1');
    raw.close();

    final database = MindlyDatabase(NativeDatabase(file));
    addTearDown(database.close);

    final columns = await database
        .customSelect('PRAGMA table_info(captures)')
        .get();
    expect(
      columns.map((row) => row.read<String>('name')),
      contains('is_pinned'),
    );

    final tableRows = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type IN ('table', 'view')",
        )
        .get();
    final tableNames = tableRows.map((row) => row.read<String>('name')).toSet();
    expect(
      tableNames,
      containsAll(<String>{
        'captures',
        'people',
        'topics',
        'commitments',
        'memory_relationships',
        'memory_embeddings',
        'memory_fts',
      }),
    );
  });
}
