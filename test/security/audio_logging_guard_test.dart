import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Phase 4 audio code does not log credentials or raw audio', () {
    final directory = Directory('lib/features/audio_capture');
    final forbiddenLogging = <String>[
      'print(',
      'debugPrint(',
      'developer.log(',
      'logger.',
    ];

    for (final entity in directory.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      final source = entity.readAsStringSync();
      for (final token in forbiddenLogging) {
        expect(
          source.contains(token),
          isFalse,
          reason: '${entity.path} contains a logging call in audio code.',
        );
      }
      expect(
        source.contains("apiKey: apiKey") && source.contains('toString()'),
        isFalse,
        reason: '${entity.path} risks stringifying an API key.',
      );
    }
  });
}
