import 'package:flutter_test/flutter_test.dart';
import 'package:mindly/features/text_capture/domain/memory_extraction.dart';

void main() {
  test('valid extraction payload becomes a typed memory extraction', () {
    final extraction = MemoryExtraction.fromJson({
      'capture_id': 'capture-1',
      'summary': 'Discussed launch timing with Priya.',
      'context': 'work',
      'people': ['Priya', ' priya '],
      'topics': ['Launch'],
      'commitments': ['Send rollout plan'],
      'tone': 'focused',
    }, expectedCaptureId: 'capture-1');

    expect(extraction.captureId, 'capture-1');
    expect(extraction.context, ExtractionContext.work);
    expect(extraction.people, ['Priya']);
    expect(extraction.commitments, ['Send rollout plan']);
    expect(extraction.tone, 'focused');
  });

  test('ambiguous context stays ambiguous', () {
    final extraction = MemoryExtraction.fromJson({
      'capture_id': 'capture-2',
      'summary': 'Remember to call Alex tomorrow.',
      'context': 'ambiguous',
      'people': ['Alex'],
      'topics': ['Follow-up'],
      'commitments': ['Call Alex tomorrow'],
      'tone': null,
    }, expectedCaptureId: 'capture-2');

    expect(extraction.context, ExtractionContext.ambiguous);
  });

  test('invalid schema and mismatched capture IDs are rejected', () {
    expect(
      () => MemoryExtraction.fromJson({
        'capture_id': 'wrong-id',
        'summary': 'Summary',
        'context': 'work',
        'people': <String>[],
        'topics': <String>[],
        'commitments': <String>[],
        'tone': null,
      }, expectedCaptureId: 'capture-3'),
      throwsFormatException,
    );

    expect(
      () => MemoryExtraction.fromJson({
        'capture_id': 'capture-3',
        'summary': 'Summary',
        'context': 'unknown',
        'people': <String>[],
        'topics': <String>[],
        'commitments': <String>[],
        'tone': null,
      }, expectedCaptureId: 'capture-3'),
      throwsFormatException,
    );
  });
}
