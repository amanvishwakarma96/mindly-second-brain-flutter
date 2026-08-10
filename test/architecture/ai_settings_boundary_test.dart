import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AI settings and security logic never import platform screens', () {
    final roots = <Directory>[
      Directory('lib/core/security'),
      Directory('lib/features/ai_settings'),
    ];
    final offenders = <String>[];

    for (final root in roots) {
      for (final entity in root.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final source = entity.readAsStringSync();
        if (source.contains('/screens/')) {
          offenders.add(entity.path);
        }
      }
    }

    expect(offenders, isEmpty);
  });
}
