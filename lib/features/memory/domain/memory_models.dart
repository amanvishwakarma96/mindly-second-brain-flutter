enum MemoryEntityType {
  capture,
  person,
  topic,
  commitment;

  String get wireName => name;

  static MemoryEntityType? tryParse(String value) {
    for (final type in values) {
      if (type.wireName == value) {
        return type;
      }
    }
    return null;
  }
}

class CaptureBrowserFilter {
  const CaptureBrowserFilter({this.context, this.mode, this.isPinned});

  final String? context;
  final String? mode;
  final bool? isPinned;
}

class MemoryListItem {
  const MemoryListItem({
    required this.type,
    required this.id,
    required this.title,
    this.subtitle,
    this.createdAt,
    this.context,
    this.mode,
    this.isPinned = false,
  });

  final MemoryEntityType type;
  final String id;
  final String title;
  final String? subtitle;
  final DateTime? createdAt;
  final String? context;
  final String? mode;
  final bool isPinned;
}

class MemoryCaptureContent {
  const MemoryCaptureContent({this.rawText, this.transcript, this.summary});

  final String? rawText;
  final String? transcript;
  final String? summary;
}

class MemoryRelationshipView {
  const MemoryRelationshipView({
    required this.id,
    required this.fromType,
    required this.fromId,
    required this.relationType,
    required this.toType,
    required this.toId,
  });

  final String id;
  final String fromType;
  final String fromId;
  final String relationType;
  final String toType;
  final String toId;
}

class MemoryGraphNode {
  const MemoryGraphNode({required this.item, required this.depth});

  final MemoryListItem item;
  final int depth;
}

class MemoryGraphEdge {
  const MemoryGraphEdge({
    required this.id,
    required this.fromType,
    required this.fromId,
    required this.relationType,
    required this.toType,
    required this.toId,
  });

  final String id;
  final String fromType;
  final String fromId;
  final String relationType;
  final String toType;
  final String toId;
}

class MemoryGraphNeighborhood {
  const MemoryGraphNeighborhood({
    required this.root,
    required this.nodes,
    required this.edges,
  });

  final MemoryListItem root;
  final List<MemoryGraphNode> nodes;
  final List<MemoryGraphEdge> edges;
}

class MemoryDetail {
  const MemoryDetail({
    required this.item,
    this.rawText,
    this.transcript,
    this.summary,
    this.connections = const [],
  });

  final MemoryListItem item;
  final String? rawText;
  final String? transcript;
  final String? summary;
  final List<MemoryGraphEdge> connections;
}

class MemorySearchHit {
  const MemorySearchHit({
    required this.entityType,
    required this.entityId,
    required this.content,
    required this.rank,
  });

  final String entityType;
  final String entityId;
  final String content;
  final double rank;
}

class VectorSearchHit {
  const VectorSearchHit({
    required this.ownerType,
    required this.ownerId,
    required this.score,
  });

  final String ownerType;
  final String ownerId;
  final double score;
}

class HybridMemorySearchHit {
  const HybridMemorySearchHit({
    required this.type,
    required this.id,
    required this.content,
    required this.score,
    this.lexicalRank,
    this.semanticScore,
  });

  final MemoryEntityType type;
  final String id;
  final String content;
  final double score;
  final int? lexicalRank;
  final double? semanticScore;
}
