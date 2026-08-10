import 'package:flutter_test/flutter_test.dart';
import 'package:mindly/features/memory/data/float32_vector_codec.dart';

void main() {
  test('Float32 vectors round-trip with expected precision', () {
    final decoded = Float32VectorCodec.decode(
      Float32VectorCodec.encode([1.25, -2.5, 3.125]),
    );
    expect(decoded[0], closeTo(1.25, 0.00001));
    expect(decoded[1], closeTo(-2.5, 0.00001));
    expect(decoded[2], closeTo(3.125, 0.00001));
  });

  test('rejects empty and non-finite vectors', () {
    expect(() => Float32VectorCodec.encode([]), throwsArgumentError);
    expect(() => Float32VectorCodec.encode([double.nan]), throwsArgumentError);
  });
}
