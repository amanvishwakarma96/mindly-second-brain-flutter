import 'package:mindly/features/memory/data/memory_browser_repository.dart';
import 'package:mindly/features/memory/data/memory_graph_service.dart';
import 'package:mindly/features/memory/data/hybrid_memory_search_service.dart';
import 'package:mindly/features/memory/domain/memory_models.dart';

class MemoryBrowserService {
  factory MemoryBrowserService({
    required MemoryBrowserRepository browserRepository,
    required HybridMemorySearchService searchService,
    required MemoryGraphService graphService,
  }) {
    return MemoryBrowserService._(
      browserRepository,
      searchService,
      graphService,
    );
  }

  MemoryBrowserService._(
    this._browserRepository,
    this._searchService,
    this._graphService,
  );

  final MemoryBrowserRepository _browserRepository;
  final HybridMemorySearchService _searchService;
  final MemoryGraphService _graphService;

  Future<List<MemoryListItem>> list(
    MemoryEntityType type, {
    CaptureBrowserFilter captureFilter = const CaptureBrowserFilter(),
    int limit = 100,
  }) {
    return _browserRepository.list(
      type,
      captureFilter: captureFilter,
      limit: limit,
    );
  }

  Future<List<HybridMemorySearchHit>> search({
    required String query,
    String? semanticModel,
    List<double>? queryVector,
    int limit = 20,
  }) {
    return _searchService.search(
      query: query,
      semanticModel: semanticModel,
      queryVector: queryVector,
      limit: limit,
    );
  }

  Future<MemoryDetail?> detail(MemoryEntityType type, String id) async {
    final item = await _browserRepository.getItem(type, id);
    if (item == null) {
      return null;
    }

    MemoryCaptureContent? captureContent;
    if (type == MemoryEntityType.capture) {
      captureContent = await _browserRepository.getCaptureContent(id);
    }
    final graph = await _graphService.load(
      rootType: type,
      rootId: id,
      maxDepth: 1,
    );

    return MemoryDetail(
      item: item,
      rawText: captureContent?.rawText,
      transcript: captureContent?.transcript,
      summary: captureContent?.summary,
      connections: graph?.edges ?? const [],
    );
  }

  Future<MemoryGraphNeighborhood?> graph(
    MemoryEntityType type,
    String id, {
    int maxDepth = 2,
    int maxNodes = 100,
  }) {
    return _graphService.load(
      rootType: type,
      rootId: id,
      maxDepth: maxDepth,
      maxNodes: maxNodes,
    );
  }
}
