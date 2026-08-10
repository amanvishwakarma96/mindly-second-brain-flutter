import 'dart:io';
import 'dart:math';

import 'package:mindly/features/memory/data/vector_math.dart';

void main() {
  const count = 10000;
  const dimensions = 64;
  final random = Random(42);
  final query = List<double>.generate(
    dimensions,
    (_) => random.nextDouble(),
    growable: false,
  );
  final corpus = List<List<double>>.generate(
    count,
    (_) => List<double>.generate(
      dimensions,
      (_) => random.nextDouble(),
      growable: false,
    ),
    growable: false,
  );

  final watch = Stopwatch()..start();
  var best = -2.0;
  for (final vector in corpus) {
    final score = VectorMath.cosineSimilarity(query, vector);
    if (score > best) {
      best = score;
    }
  }
  watch.stop();

  if (!best.isFinite) {
    throw StateError('Vector benchmark produced an invalid result.');
  }
  stdout.writeln(
    'Mindly vector characterization: $count x $dimensions in '
    '${watch.elapsedMilliseconds} ms; best=$best',
  );
}
