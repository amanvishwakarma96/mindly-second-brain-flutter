import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Phase 6 insight engine has no provider or network dependency', () {
    final root = Directory('lib/features/insights');
    expect(root.existsSync(), isTrue);

    final source = root
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .map((file) => file.readAsStringSync())
        .join('\n');

    for (final forbidden in <String>[
      "package:http/",
      "dart:io'",
      'ai_provider_transport',
      'provider_key_service',
      '/v1/responses',
      '/v1/messages',
      '/v1/audio/transcriptions',
    ]) {
      expect(
        source,
        isNot(contains(forbidden)),
        reason: 'Tier 1/2 insights must remain local-only: found $forbidden',
      );
    }
  });
}
