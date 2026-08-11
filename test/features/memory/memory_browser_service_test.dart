import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindly/core/database/mindly_database.dart';
import 'package:mindly/features/memory/application/memory_browser_service.dart';
import 'package:mindly/features/memory/data/hybrid_memory_search_service.dart';
import 'package:mindly/features/memory/data/memory_browser_repository.dart';
import 'package:mindly/features/memory/data/memory_graph_service.dart';
import 'package:mindly/features/memory/data/memory_repository.dart';
import 'package:mindly/features/memory/data/vector_search_service.dart';
import 'package:mindly/features/memory/domain/memory_models.dart';

void main() {
  late MindlyDatabase database;
  late MemoryRepository memoryRepository;
  late MemoryBrowserRepository browserRepository;
  late VectorSearchService vectors;
  late MemoryGraphService graphService;
  late HybridMemorySearchService searchService;
  late MemoryBrowserService browserService;

  setUp(() {
    database = MindlyDatabase(NativeDatabase.memory());
    memoryRepository = MemoryRepository(database);
    browserRepository = MemoryBrowserRepository(database);
    vectors = VectorSearchService(database);
    graphService = MemoryGraphService(browserRepository);
    searchService = HybridMemorySearchService(
      lexicalRepository: memoryRepository,
      browserRepository: browserRepository,
      vectorSearch: vectors,
    );
    browserService = MemoryBrowserService(
      browserRepository: browserRepository,
      searchService: searchService,
      graphService: graphService,
    );
  });

  tearDown(() => database.close());

  test('capture browser is newest-first and respects filters', () async {
    await memoryRepository.saveCapture(
      id: 'old-work',
      mode: 'text',
      context: 'work',
      summary: 'Older work note',
      isPinned: true,
      createdAt: DateTime.utc(2026, 1, 1),
    );
    await memoryRepository.saveCapture(
      id: 'new-work',
      mode: 'audio',
      context: 'work',
      summary: 'Newer work note',
      createdAt: DateTime.utc(2026, 2, 1),
    );
    await memoryRepository.saveCapture(
      id: 'personal',
      mode: 'text',
      context: 'personal',
      summary: 'Personal note',
      isPinned: true,
      createdAt: DateTime.utc(2026, 3, 1),
    );

    final all = await browserService.list(MemoryEntityType.capture);
    expect(all.map((item) => item.id), ['personal', 'new-work', 'old-work']);

    final work = await browserService.list(
      MemoryEntityType.capture,
      captureFilter: const CaptureBrowserFilter(context: 'work'),
    );
    expect(work.map((item) => item.id), ['new-work', 'old-work']);

    final pinnedText = await browserService.list(
      MemoryEntityType.capture,
      captureFilter: const CaptureBrowserFilter(
        mode: 'text',
        isPinned: true,
      ),
    );
    expect(pinnedText.map((item) => item.id), ['personal', 'old-work']);
  });

  test('people, topics and commitments browse without cross-type leakage', () async {
    await memoryRepository.savePerson(id: 'p1', displayName: 'Maya');
    await memoryRepository.saveTopic(id: 't1', label: 'Launch');
    await memoryRepository.saveCommitment(id: 'k1', text: 'Send draft');

    final people = await browserService.list(MemoryEntityType.person);
    final topics = await browserService.list(MemoryEntityType.topic);
    final commitments = await browserService.list(MemoryEntityType.commitment);

    expect(people.single.type, MemoryEntityType.person);
    expect(people.single.title, 'Maya');
    expect(topics.single.type, MemoryEntityType.topic);
    expect(topics.single.title, 'Launch');
    expect(commitments.single.type, MemoryEntityType.commitment);
    expect(commitments.single.title, 'Send draft');
  });

  test('detail resolves capture source and direct graph connections', () async {
    await memoryRepository.saveCapture(
      id: 'c1',
      mode: 'text',
      context: 'work',
      rawText: 'Meet Maya about launch',
      summary: 'Launch meeting',
    );
    await memoryRepository.savePerson(id: 'p1', displayName: 'Maya');
    await memoryRepository.link(
      id: 'r1',
      fromType: 'person',
      fromId: 'p1',
      relationType: 'mentioned_in',
      toType: 'capture',
      toId: 'c1',
    );

    final detail = await browserService.detail(MemoryEntityType.capture, 'c1');

    expect(detail, isNotNull);
    expect(detail!.rawText, 'Meet Maya about launch');
    expect(detail.summary, 'Launch meeting');
    expect(detail.connections.single.relationType, 'mentioned_in');
    expect(
      await browserService.detail(MemoryEntityType.capture, 'missing'),
      isNull,
    );
  });

  test('hybrid search stays lexical-only without a real query vector', () async {
    await memoryRepository.saveCapture(
      id: 'c1',
      mode: 'text',
      context: 'work',
      summary: 'Alpha launch plan',
    );
    await vectors.upsert(
      id: 'e1',
      ownerType: 'capture',
      ownerId: 'c1',
      model: 'embed-a',
      vector: [1, 0],
    );

    final lexicalOnly = await browserService.search(query: 'Alpha');
    expect(lexicalOnly.single.id, 'c1');
    expect(lexicalOnly.single.lexicalRank, 1);
    expect(lexicalOnly.single.semanticScore, isNull);
  });

  test('hybrid search merges real vector hits and isolates model/dimension', () async {
    await memoryRepository.saveCapture(
      id: 'c1',
      mode: 'text',
      context: 'work',
      summary: 'Alpha launch plan',
    );
    await memoryRepository.saveCapture(
      id: 'c2',
      mode: 'text',
      context: 'work',
      summary: 'Budget planning',
    );
    await vectors.upsert(
      id: 'e1',
      ownerType: 'capture',
      ownerId: 'c1',
      model: 'embed-a',
      vector: [1, 0],
    );
    await vectors.upsert(
      id: 'e2',
      ownerType: 'capture',
      ownerId: 'c2',
      model: 'embed-a',
      vector: [0.8, 0.2],
    );
    await vectors.upsert(
      id: 'e3',
      ownerType: 'capture',
      ownerId: 'c2',
      model: 'embed-b',
      vector: [1, 0],
    );
    await vectors.upsert(
      id: 'e4',
      ownerType: 'capture',
      ownerId: 'c2',
      model: 'embed-a',
      vector: [1, 0, 0],
    );

    final hits = await browserService.search(
      query: 'Alpha',
      semanticModel: 'embed-a',
      queryVector: [1, 0],
    );

    expect(hits.first.id, 'c1');
    expect(hits.first.lexicalRank, 1);
    expect(hits.first.semanticScore, isNotNull);
    expect(hits.map((hit) => hit.id), contains('c2'));
  });

  test('graph traversal is bidirectional, bounded, and cycle-safe', () async {
    await memoryRepository.saveCapture(
      id: 'c1',
      mode: 'text',
      context: 'work',
      summary: 'Launch',
    );
    await memoryRepository.saveTopic(id: 't1', label: 'Planning');
    await memoryRepository.saveCommitment(id: 'k1', text: 'Send draft');
    await memoryRepository.link(
      id: 'r1',
      fromType: 'capture',
      fromId: 'c1',
      relationType: 'related_to',
      toType: 'topic',
      toId: 't1',
    );
    await memoryRepository.link(
      id: 'r2',
      fromType: 'topic',
      fromId: 't1',
      relationType: 'related_to',
      toType: 'commitment',
      toId: 'k1',
    );
    await memoryRepository.link(
      id: 'r3',
      fromType: 'topic',
      fromId: 't1',
      relationType: 'follows_up_on',
      toType: 'capture',
      toId: 'c1',
    );

    final depthOne = await browserService.graph(
      MemoryEntityType.capture,
      'c1',
      maxDepth: 1,
    );
    expect(depthOne, isNotNull);
    expect(depthOne!.nodes.map((node) => node.item.id), ['c1', 't1']);

    final depthTwo = await browserService.graph(
      MemoryEntityType.capture,
      'c1',
      maxDepth: 2,
    );
    expect(depthTwo, isNotNull);
    expect(depthTwo!.nodes.map((node) => node.item.id), ['c1', 't1', 'k1']);
    expect(depthTwo.edges.map((edge) => edge.id).toSet(), {'r1', 'r2', 'r3'});
  });
}
