import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('provider credentials have no obvious logging path or Drift column', () {
    final offenders = <String>[];
    final loggingPattern = RegExp(
      r'(print|debugPrint|log)\s*\([^;\n]*(apiKey|rawKey|secret|credential)',
      caseSensitive: false,
    );

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final source = entity.readAsStringSync();
      if (loggingPattern.hasMatch(source)) {
        offenders.add(entity.path);
      }
    }

    expect(offenders, isEmpty);

    final databaseSource = File(
      'lib/core/database/mindly_database.dart',
    ).readAsStringSync();
    expect(databaseSource, isNot(contains('apiKey')));
    expect(databaseSource, isNot(contains('provider-key')));
  });
}
