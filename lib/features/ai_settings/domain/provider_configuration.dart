enum AiProviderKind { openAi, anthropic, compatible }

class ProviderConfiguration {
  const ProviderConfiguration({
    required this.id,
    required this.kind,
    required this.displayName,
    this.baseUrl,
    this.defaultModel,
  });

  const ProviderConfiguration.openAi({this.defaultModel})
    : id = 'openai',
      kind = AiProviderKind.openAi,
      displayName = 'OpenAI',
      baseUrl = null;

  const ProviderConfiguration.anthropic({this.defaultModel})
    : id = 'anthropic',
      kind = AiProviderKind.anthropic,
      displayName = 'Anthropic',
      baseUrl = null;

  const ProviderConfiguration.compatible({
    this.defaultModel,
    this.baseUrl,
  }) : id = 'compatible',
       kind = AiProviderKind.compatible,
       displayName = 'OpenAI-compatible';

  final String id;
  final AiProviderKind kind;
  final String displayName;
  final String? baseUrl;
  final String? defaultModel;

  Map<String, Object?> toJson() => {
    'id': id,
    'kind': kind.name,
    'displayName': displayName,
    if (baseUrl != null) 'baseUrl': baseUrl,
    if (defaultModel != null) 'defaultModel': defaultModel,
  };

  @override
  String toString() =>
      'ProviderConfiguration(id: $id, kind: ${kind.name}, '
      'displayName: $displayName)';
}
