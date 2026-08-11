import 'dart:collection';

import 'package:mindly/features/memory/data/memory_browser_repository.dart';
import 'package:mindly/features/memory/domain/memory_models.dart';

class MemoryGraphService {
  MemoryGraphService(this._repository);

  final MemoryBrowserRepository _repository;

  Future<MemoryGraphNeighborhood?> load({
    required MemoryEntityType rootType,
    required String rootId,
    int maxDepth = 2,
    int maxNodes = 100,
  }) async {
    if (maxDepth < 0) {
      throw ArgumentError.value(
        maxDepth,
        'maxDepth',
        'Must be zero or greater.',
      );
    }
    if (maxNodes <= 0) {
      throw ArgumentError.value(
        maxNodes,
        'maxNodes',
        'Must be greater than zero.',
      );
    }

    final root = await _repository.getItem(rootType, rootId);
    if (root == null) {
      return null;
    }

    final nodes = <String, MemoryGraphNode>{
      _key(rootType, rootId): MemoryGraphNode(item: root, depth: 0),
    };
    final edges = <String, MemoryGraphEdge>{};
    final queue = Queue<_TraversalEntry>()
      ..add(_TraversalEntry(type: rootType, id: rootId, depth: 0));

    while (queue.isNotEmpty && nodes.length <= maxNodes) {
      final current = queue.removeFirst();
      if (current.depth >= maxDepth) {
        continue;
      }

      final relationships = await _repository.relationshipsFor(
        entityType: current.type.wireName,
        entityId: current.id,
      );

      for (final relation in relationships) {
        final outgoing =
            relation.fromType == current.type.wireName &&
            relation.fromId == current.id;
        final neighborTypeName = outgoing ? relation.toType : relation.fromType;
        final neighborId = outgoing ? relation.toId : relation.fromId;
        final neighborType = MemoryEntityType.tryParse(neighborTypeName);
        if (neighborType == null) {
          continue;
        }

        final neighborKey = _key(neighborType, neighborId);
        if (!nodes.containsKey(neighborKey)) {
          if (nodes.length >= maxNodes) {
            continue;
          }
          final item = await _repository.getItem(neighborType, neighborId);
          if (item == null) {
            continue;
          }
          final depth = current.depth + 1;
          nodes[neighborKey] = MemoryGraphNode(item: item, depth: depth);
          if (depth < maxDepth) {
            queue.add(
              _TraversalEntry(type: neighborType, id: neighborId, depth: depth),
            );
          }
        }

        edges.putIfAbsent(
          relation.id,
          () => MemoryGraphEdge(
            id: relation.id,
            fromType: relation.fromType,
            fromId: relation.fromId,
            relationType: relation.relationType,
            toType: relation.toType,
            toId: relation.toId,
          ),
        );
      }
    }

    final orderedNodes = nodes.values.toList(growable: false)
      ..sort((left, right) {
        final depth = left.depth.compareTo(right.depth);
        if (depth != 0) {
          return depth;
        }
        final type = left.item.type.index.compareTo(right.item.type.index);
        if (type != 0) {
          return type;
        }
        return left.item.id.compareTo(right.item.id);
      });
    final orderedEdges = edges.values.toList(growable: false)
      ..sort((left, right) => left.id.compareTo(right.id));

    return MemoryGraphNeighborhood(
      root: root,
      nodes: orderedNodes,
      edges: orderedEdges,
    );
  }

  String _key(MemoryEntityType type, String id) => '${type.wireName}:$id';
}

class _TraversalEntry {
  const _TraversalEntry({
    required this.type,
    required this.id,
    required this.depth,
  });

  final MemoryEntityType type;
  final String id;
  final int depth;
}
