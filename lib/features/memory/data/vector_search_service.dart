import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:mindly/core/database/mindly_database.dart';
import 'package:mindly/features/memory/data/float32_vector_codec.dart';
import 'package:mindly/features/memory/domain/memory_models.dart';

class VectorSearchService {
  VectorSearchService(this._database);

  final MindlyDatabase _database;

  Future<void> upsert({
    required String id,
    required String ownerType,
    required String ownerId,
    required String model,
    required List<double> vector,
  }) async {
    final encoded = Float32VectorCodec.encode(vector);
    await _database.into(_database.memoryEmbeddings).insertOnConflictUpdate(
          MemoryEmbeddingsCompanion.insert(
            id: id,
            ownerType: ownerType,
            ownerId: ownerId,
            model: model,
            dimensions: vector.length,
            vector: encoded,
            createdAt: DateTime.now().toUtc(),
          ),
        );
  }

  Future<List<VectorSearchHit>> search({
    required String model,
    required List<double> query,
    String? ownerType,
    int limit = 10,
  }) async {
    if (limit <= 0) {
      return const [];
    }
    Float32VectorCodec.encode(query);

    final select = _database.select(_database.memoryEmbeddings)
      ..where(
        (row) => row.model.equals(model) & row.dimensions.equals(query.length),
      );
    if (ownerType != null) {
      select.where((row) => row.ownerType.equals(ownerType));
    }

    final rows = await select.get();
    final hits = rows
        .map(
          (row) => VectorSearchHit(
            ownerType: row.ownerType,
            ownerId: row.ownerId,
            score: cosineSimilarity(
              query,
              Float32VectorCodec.decode(row.vector),
            ),
          ),
        )
        .toList(growable: false)
      ..sort((left, right) => right.score.compareTo(left.score));

    return hits.take(math.min(limit, hits.length)).toList(growable: false);
  }

  static double cosineSimilarity(List<double> left, List<double> right) {
    if (left.length != right.length || left.isEmpty) {
      throw ArgumentError(
        'Vectors must be non-empty and have identical dimensions.',
      );
    }

    var dot = 0.0;
    var leftNorm = 0.0;
    var rightNorm = 0.0;
    for (var index = 0; index < left.length; index++) {
      dot += left[index] * right[index];
      leftNorm += left[index] * left[index];
      rightNorm += right[index] * right[index];
    }

    if (leftNorm == 0 || rightNorm == 0) {
      return 0;
    }
    return dot / (math.sqrt(leftNorm) * math.sqrt(rightNorm));
  }
}
