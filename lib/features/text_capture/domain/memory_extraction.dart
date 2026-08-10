enum ExtractionContext { work, personal, ambiguous }

class MemoryExtraction {
  const MemoryExtraction({
    required this.captureId,
    required this.summary,
    required this.context,
    required this.people,
    required this.topics,
    required this.commitments,
    this.tone,
  });

  final String captureId;
  final String summary;
  final ExtractionContext context;
  final List<String> people;
  final List<String> topics;
  final List<String> commitments;
  final String? tone;

  MemoryExtraction copyWith({ExtractionContext? context}) {
    return MemoryExtraction(
      captureId: captureId,
      summary: summary,
      context: context ?? this.context,
      people: people,
      topics: topics,
      commitments: commitments,
      tone: tone,
    );
  }

  factory MemoryExtraction.fromJson(
    Map<String, Object?> json, {
    required String expectedCaptureId,
  }) {
    final captureId = _requiredString(json, 'capture_id');
    if (captureId != expectedCaptureId) {
      throw const FormatException(
        'Extraction capture ID does not match source.',
      );
    }

    final contextValue = _requiredString(json, 'context');
    final context = switch (contextValue) {
      'work' => ExtractionContext.work,
      'personal' => ExtractionContext.personal,
      'ambiguous' => ExtractionContext.ambiguous,
      _ => throw const FormatException('Unsupported extraction context.'),
    };

    return MemoryExtraction(
      captureId: captureId,
      summary: _requiredString(json, 'summary'),
      context: context,
      people: _stringList(json, 'people'),
      topics: _stringList(json, 'topics'),
      commitments: _stringList(json, 'commitments'),
      tone: _optionalString(json, 'tone'),
    );
  }

  static Map<String, Object?> get jsonSchema => {
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'capture_id': {'type': 'string'},
      'summary': {'type': 'string'},
      'context': {
        'type': 'string',
        'enum': ['work', 'personal', 'ambiguous'],
      },
      'people': {
        'type': 'array',
        'items': {'type': 'string'},
      },
      'topics': {
        'type': 'array',
        'items': {'type': 'string'},
      },
      'commitments': {
        'type': 'array',
        'items': {'type': 'string'},
      },
      'tone': {
        'type': ['string', 'null'],
      },
    },
    'required': [
      'capture_id',
      'summary',
      'context',
      'people',
      'topics',
      'commitments',
      'tone',
    ],
  };

  static String _requiredString(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Missing required extraction field: $key.');
    }
    return value.trim();
  }

  static String? _optionalString(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is! String) {
      throw FormatException('Invalid extraction field: $key.');
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static List<String> _stringList(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is! List) {
      throw FormatException('Invalid extraction field: $key.');
    }
    final seen = <String>{};
    final result = <String>[];
    for (final item in value) {
      if (item is! String) {
        throw FormatException('Invalid extraction list item: $key.');
      }
      final trimmed = item.trim();
      if (trimmed.isEmpty) continue;
      final normalized = trimmed.toLowerCase();
      if (seen.add(normalized)) result.add(trimmed);
    }
    return List.unmodifiable(result);
  }
}
