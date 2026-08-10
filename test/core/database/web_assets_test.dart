import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Drift web runtime assets are present and non-trivial', () {
    final wasm = File('web/sqlite3.wasm');
    final worker = File('web/drift_worker.js');
    expect(wasm.existsSync(), isTrue);
    expect(worker.existsSync(), isTrue);
    expect(wasm.lengthSync(), greaterThan(500000));
    expect(worker.lengthSync(), greaterThan(300000));
  });
}
