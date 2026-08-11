import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Tier 1 and Tier 2 insight engine stays provider/network independent', () {
    final files = <File>[
      File('lib/features/insights/application/proactive_insight_service.dart'),
      File('lib/features/insights/application/insight_controller.dart'),
      File('lib/features/insights/data/insight_evidence_repository.dart'),
      File('lib/features/insights/data/insight_preference_store.dart'),
      File('lib/features/insights/domain/insight_models.dart'),
    ];
    expect(files.every((file) => file.existsSync()), isTrue);
    final source = files.map((file) => file.readAsStringSync()).join('\n');

    for (final forbidden in <String>[
      "package:http/",
      'ai_provider_transport',
      'tier3_insight_transport',
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
