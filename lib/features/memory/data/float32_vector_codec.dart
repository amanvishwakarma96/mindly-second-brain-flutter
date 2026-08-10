import 'dart:typed_data';

abstract final class Float32VectorCodec {
  static Uint8List encode(List<double> values) {
    if (values.isEmpty) {
      throw ArgumentError.value(values, 'values', 'Vector must not be empty.');
    }
    if (values.any((value) => !value.isFinite)) {
      throw ArgumentError.value(values, 'values', 'Vector values must be finite.');
    }

    final bytes = ByteData(values.length * Float32List.bytesPerElement);
    for (var index = 0; index < values.length; index++) {
      bytes.setFloat32(
        index * Float32List.bytesPerElement,
        values[index],
        Endian.little,
      );
    }
    return bytes.buffer.asUint8List();
  }

  static List<double> decode(Uint8List bytes) {
    if (bytes.isEmpty || bytes.lengthInBytes % Float32List.bytesPerElement != 0) {
      throw ArgumentError.value(
        bytes.lengthInBytes,
        'bytes',
        'Invalid Float32 vector byte length.',
      );
    }

    final data = ByteData.sublistView(bytes);
    return List<double>.generate(
      bytes.lengthInBytes ~/ Float32List.bytesPerElement,
      (index) => data.getFloat32(
        index * Float32List.bytesPerElement,
        Endian.little,
      ),
      growable: false,
    );
  }
}
