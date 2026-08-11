import 'dart:math' as math;

import 'package:mindly/features/memory/data/memory_browser_repository.dart';
import 'package:mindly/features/memory/data/memory_repository.dart';
import 'package:mindly/features/memory/data/vector_search_service.dart';
import 'package:mindly/features/memory/domain/memory_models.dart';

class HybridMemorySearchService {
  factory HybridMemorySearchService({
    required MemoryRepository lexicalRepository,
    required MemoryBrowserRepository browserRepository,
    required VectorSearchService vectorSearch,
  }) {
    return HybridMemorySearchService._(
      lexicalRepository,
      browserRepository,
      vectorSearch,
    );
  }

  HybridMemorySearchService._(
    this._lexicalRepository,
    this._browserRepository,
    this._vectorSearch,
  );

  static const _rrfK = 60.0;

  final MemoryRepository _lexicalRepository;
  final MemoryBrowserRepository _browserRepository;
  final VectorSearchService _vectorSearch;

  Future<List<HybridMemorySearchHit>> search({
    required String query,
    String? semanticModel,
    List<double>? queryVector,
    int limit = 20,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty || limit <= 0) {
      return const [];
    }

    final candidateLimit = math.max(20, limit * 4);
    final lexical = await _lexicalRepository.keywordSearch(
      trimmed,
      limit: candidateLimit,
    );
    final accumulators = <String, _SearchAccumulator>{};

    for (var index = 0; index < lexical.length; index += 1) {
      final hit = lexical[index];
      final type = MemoryEntityType.tryParse(hit.entityType);
      if (type == null) {
        continue;
      }
      final key = _key(type, hit.entityId);
      final accumulator = accumulators.putIfAbsent(
        key,
        () => _SearchAccumulator(type: type, id: hit.entityId),
      );
      accumulator
        ..content = hit.content
        ..lexicalRank = index + 1
        ..score += 1 / (_rrfK + index + 1);
    }

    final model = semanticModel?.trim();
    if (queryVector != null && model != null && model.isNotEmpty) {
      final semantic = await _vectorSearch.search(
        model: model,
        query: queryVector,
        limit: candidateLimit,
      );
      for (var index = 0; index < semantic.length; index += 1) {
        final hit = semantic[index];
        final type = MemoryEntityType.tryParse(hit.ownerType);
        if (type == null) {
          continue;
        }
        final key = _key(type, hit.ownerId);
        final accumulator = accumulators.putIfAbsent(
          key,
          () => _SearchAccumulator(type: type, id: hit.ownerId),
        );
        accumulator
          ..semanticScore = hit.score
          ..score += 1 / (_rrfK + index + 1);

        if (accumulator.content == null) {
          final item = await _browserRepository.getItem(type, hit.ownerId);
          if (item != null) {
            accumulator.content = [
              item.title,
              item.subtitle,
            ].whereType<String>().join(' · ');
          }
        }
      }
    }

    final results =
        accumulators.values
            .where((value) => value.content != null)
            .map(
              (value) => HybridMemorySearchHit(
                type: value.type,
                id: value.id,
                content: value.content!,
                score: value.score,
                lexicalRank: value.lexicalRank,
                semanticScore: value.semanticScore,
              ),
            )
            .toList(growable: false)
          ..sort((left, right) {
            final score = right.score.compareTo(left.score);
            if (score != 0) {
              return score;
            }
            final type = left.type.index.compareTo(right.type.index);
            if (type != 0) {
              return type;
            }
            return left.id.compareTo(right.id);
          });

    return results
        .take(math.min(limit, results.length))
        .toList(growable: false);
  }

  String _key(MemoryEntityType type, String id) => '${type.wireName}:$id';
}

class _SearchAccumulator {
  _SearchAccumulator({required this.type, required this.id});

  final MemoryEntityType type;
  final String id;
  String? content;
  int? lexicalRank;
  double? semanticScore;
  double score = 0;
}
