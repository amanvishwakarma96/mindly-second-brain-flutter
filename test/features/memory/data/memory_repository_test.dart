import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindly/core/database/mindly_database.dart';
import 'package:mindly/features/memory/data/memory_repository.dart';
import 'package:mindly/features/memory/data/vector_search_service.dart';

void main() {
  late MindlyDatabase database;
  late MemoryRepository repository;
  late VectorSearchService vectors;

  setUp(() {
    database = MindlyDatabase(NativeDatabase.memory());
    repository = MemoryRepository(database);
    vectors = VectorSearchService(database);
  });

  tearDown(() => database.close());

  test('capture, entities, commitments and relationships round-trip', () async {
    await repository.saveCapture(
      id: 'c1',
      mode: 'text_first',
      context: 'work',
      rawText: 'Discuss launch plan with Maya',
      summary: 'Launch planning',
    );
    await repository.savePerson(id: 'p1', displayName: 'Maya');
    await repository.saveTopic(id: 't1', label: 'Launch Plan');
    await repository.saveCommitment(
      id: 'k1',
      captureId: 'c1',
      text: 'Send launch draft',
    );
    await repository.link(
      id: 'r1',
      fromType: 'person',
      fromId: 'p1',
      relationType: 'mentioned_in',
      toType: 'capture',
      toId: 'c1',
    );

    expect(await database.select(database.captures).get(), hasLength(1));
    expect(await database.select(database.people).get(), hasLength(1));
    expect(await database.select(database.topics).get(), hasLength(1));
    expect(await database.select(database.commitments).get(), hasLength(1));
    expect(
      await database.select(database.memoryRelationships).get(),
      hasLength(1),
    );
  });

  test('FTS reflects inserts, updates and deletes', () async {
    await repository.saveCapture(
      id: 'c1',
      mode: 'text_first',
      context: 'personal',
      summary: 'Plan a Jaipur trip',
    );
    expect((await repository.keywordSearch('Jaipur')).single.entityId, 'c1');

    await repository.saveCapture(
      id: 'c1',
      mode: 'text_first',
      context: 'personal',
      summary: 'Plan a Pune trip',
    );
    expect(await repository.keywordSearch('Jaipur'), isEmpty);
    expect((await repository.keywordSearch('Pune')).single.entityId, 'c1');

    await repository.deleteMemory(entityType: 'capture', entityId: 'c1');
    expect(await repository.keywordSearch('Pune'), isEmpty);
  });

  test('vector search ranks closest vectors and isolates model/dimension', () async {
    await vectors.upsert(
      id: 'e1',
      ownerType: 'capture',
      ownerId: 'c1',
      model: 'model-a',
      vector: [1, 0, 0],
    );
    await vectors.upsert(
      id: 'e2',
      ownerType: 'capture',
      ownerId: 'c2',
      model: 'model-a',
      vector: [0.8, 0.2, 0],
    );
    await vectors.upsert(
      id: 'e3',
      ownerType: 'capture',
      ownerId: 'c3',
      model: 'model-b',
      vector: [1, 0, 0],
    );
    await vectors.upsert(
      id: 'e4',
      ownerType: 'capture',
      ownerId: 'c4',
      model: 'model-a',
      vector: [1, 0],
    );

    final hits = await vectors.search(model: 'model-a', query: [1, 0, 0]);
    expect(hits.map((hit) => hit.ownerId), ['c1', 'c2']);
  });

  test('full wipe removes structured, FTS and vector data', () async {
    await repository.saveCapture(
      id: 'c1',
      mode: 'text_first',
      context: 'work',
      summary: 'Quarterly planning',
    );
    await vectors.upsert(
      id: 'e1',
      ownerType: 'capture',
      ownerId: 'c1',
      model: 'model-a',
      vector: [1, 0],
    );

    await repository.wipeAll();

    expect(await database.select(database.captures).get(), isEmpty);
    expect(await database.select(database.memoryEmbeddings).get(), isEmpty);
    expect(await repository.keywordSearch('Quarterly'), isEmpty);
  });
}
