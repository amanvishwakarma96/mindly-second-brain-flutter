import 'package:mindly/core/database/mindly_database.dart';
import 'package:mindly/features/memory/application/memory_browser_service.dart';
import 'package:mindly/features/memory/data/hybrid_memory_search_service.dart';
import 'package:mindly/features/memory/data/memory_browser_repository.dart';
import 'package:mindly/features/memory/data/memory_graph_service.dart';
import 'package:mindly/features/memory/data/memory_repository.dart';
import 'package:mindly/features/memory/data/vector_search_service.dart';
import 'package:mindly/features/memory/domain/memory_models.dart';

abstract class MemoryBrowserController {
  factory MemoryBrowserController.production() {
    final database = MindlyDatabase.defaults();
    final browserRepository = MemoryBrowserRepository(database);
    final graphService = MemoryGraphService(browserRepository);
    final searchService = HybridMemorySearchService(
      lexicalRepository: MemoryRepository(database),
      browserRepository: browserRepository,
      vectorSearch: VectorSearchService(database),
    );
    return DefaultMemoryBrowserController(
      MemoryBrowserService(
        browserRepository: browserRepository,
        searchService: searchService,
        graphService: graphService,
      ),
    );
  }

  Future<List<MemoryListItem>> list(
    MemoryEntityType type, {
    CaptureBrowserFilter captureFilter = const CaptureBrowserFilter(),
    int limit = 100,
  });

  Future<List<HybridMemorySearchHit>> search({
    required String query,
    String? semanticModel,
    List<double>? queryVector,
    int limit = 20,
  });

  Future<MemoryDetail?> detail(MemoryEntityType type, String id);

  Future<MemoryGraphNeighborhood?> graph(
    MemoryEntityType type,
    String id, {
    int maxDepth = 2,
    int maxNodes = 100,
  });
}

class DefaultMemoryBrowserController implements MemoryBrowserController {
  const DefaultMemoryBrowserController(this._service);

  final MemoryBrowserService _service;

  @override
  Future<List<MemoryListItem>> list(
    MemoryEntityType type, {
    CaptureBrowserFilter captureFilter = const CaptureBrowserFilter(),
    int limit = 100,
  }) {
    return _service.list(
      type,
      captureFilter: captureFilter,
      limit: limit,
    );
  }

  @override
  Future<List<HybridMemorySearchHit>> search({
    required String query,
    String? semanticModel,
    List<double>? queryVector,
    int limit = 20,
  }) {
    return _service.search(
      query: query,
      semanticModel: semanticModel,
      queryVector: queryVector,
      limit: limit,
    );
  }

  @override
  Future<MemoryDetail?> detail(MemoryEntityType type, String id) {
    return _service.detail(type, id);
  }

  @override
  Future<MemoryGraphNeighborhood?> graph(
    MemoryEntityType type,
    String id, {
    int maxDepth = 2,
    int maxNodes = 100,
  }) {
    return _service.graph(type, id, maxDepth: maxDepth, maxNodes: maxNodes);
  }
}
