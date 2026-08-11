import 'package:flutter/material.dart';
import 'package:mindly/features/insights/domain/insight_models.dart';
import 'package:mindly/shared/design_tokens/mindly_spacing.dart';

enum _Tier3ProviderChoice { openAi, anthropic, compatible }

Future<Tier3ProviderProfile?> showTier3ProviderPicker(
  BuildContext context,
) async {
  final choice = await showDialog<_Tier3ProviderChoice>(
    context: context,
    builder: (dialogContext) => SimpleDialog(
      title: const Text('Choose your AI provider'),
      children: [
        SimpleDialogOption(
          onPressed: () =>
              Navigator.of(dialogContext).pop(_Tier3ProviderChoice.openAi),
          child: ListTile(
            leading: const Icon(Icons.auto_awesome_rounded),
            title: const Text('OpenAI'),
            subtitle: Text(Tier3ProviderProfile.openAiDefault.rateCard.model),
          ),
        ),
        SimpleDialogOption(
          onPressed: () =>
              Navigator.of(dialogContext).pop(_Tier3ProviderChoice.anthropic),
          child: ListTile(
            leading: const Icon(Icons.auto_awesome_outlined),
            title: const Text('Anthropic'),
            subtitle: Text(
              Tier3ProviderProfile.anthropicDefault.rateCard.model,
            ),
          ),
        ),
        SimpleDialogOption(
          onPressed: () =>
              Navigator.of(dialogContext).pop(_Tier3ProviderChoice.compatible),
          child: const ListTile(
            leading: Icon(Icons.hub_outlined),
            title: Text('OpenAI-compatible'),
            subtitle: Text('Custom base URL, model, and token rates'),
          ),
        ),
      ],
    ),
  );

  return switch (choice) {
    _Tier3ProviderChoice.openAi => Tier3ProviderProfile.openAiDefault,
    _Tier3ProviderChoice.anthropic => Tier3ProviderProfile.anthropicDefault,
    _Tier3ProviderChoice.compatible => _showCompatibleProviderDialog(context),
    null => null,
  };
}

Future<Tier3ProviderProfile?> _showCompatibleProviderDialog(
  BuildContext context,
) async {
  final baseUrlController = TextEditingController();
  final modelController = TextEditingController();
  final inputRateController = TextEditingController();
  final outputRateController = TextEditingController();

  try {
    return await showDialog<Tier3ProviderProfile>(
      context: context,
      builder: (dialogContext) {
        String? errorText;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('OpenAI-compatible provider'),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: baseUrlController,
                      decoration: const InputDecoration(
                        labelText: 'API base URL',
                        hintText: 'https://provider.example/v1',
                      ),
                    ),
                    const SizedBox(height: MindlySpacing.sm),
                    TextField(
                      controller: modelController,
                      decoration: const InputDecoration(labelText: 'Model'),
                    ),
                    const SizedBox(height: MindlySpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: inputRateController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Input \$/1M tokens',
                            ),
                          ),
                        ),
                        const SizedBox(width: MindlySpacing.sm),
                        Expanded(
                          child: TextField(
                            controller: outputRateController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Output \$/1M tokens',
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: MindlySpacing.sm),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          errorText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  try {
                    final profile = Tier3ProviderProfile.compatible(
                      baseUrl: baseUrlController.text,
                      model: modelController.text,
                      inputUsdPerMillionTokens:
                          double.tryParse(inputRateController.text) ?? -1,
                      outputUsdPerMillionTokens:
                          double.tryParse(outputRateController.text) ?? -1,
                    );
                    Navigator.of(dialogContext).pop(profile);
                  } on Object {
                    setState(() {
                      errorText =
                          'Enter a valid HTTP(S) base URL, model, and non-negative token rates.';
                    });
                  }
                },
                child: const Text('Use provider'),
              ),
            ],
          ),
        );
      },
    );
  } finally {
    baseUrlController.dispose();
    modelController.dispose();
    inputRateController.dispose();
    outputRateController.dispose();
  }
}
