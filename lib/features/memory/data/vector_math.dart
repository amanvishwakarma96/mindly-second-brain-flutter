import 'dart:math' as math;

abstract final class VectorMath {
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
