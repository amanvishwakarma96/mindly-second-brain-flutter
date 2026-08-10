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
