import 'package:flutter/material.dart';
import 'package:mindly/features/ai_settings/application/provider_settings_controller.dart';
import 'package:mindly/features/ai_settings/domain/cost_models.dart';
import 'package:mindly/features/ai_settings/web_key_warning.dart';
import 'package:mindly/shared/design_tokens/mindly_spacing.dart';

class WebProviderSettingsScreen extends StatefulWidget {
  const WebProviderSettingsScreen({super.key, this.controller});

  static const screenKey = ValueKey<String>('screen-web-provider-settings');

  final ProviderSettingsController? controller;

  @override
  State<WebProviderSettingsScreen> createState() =>
      _WebProviderSettingsScreenState();
}

class _WebProviderSettingsScreenState extends State<WebProviderSettingsScreen> {
  late final ProviderSettingsController _controller;
  final _keyController = TextEditingController();
  final _dailyController = TextEditingController();
  final _weeklyController = TextEditingController();
  String _providerId = 'openai';
  String _status = '';
  bool _riskAccepted = false;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? ProviderSettingsController.production();
    _loadCaps();
  }

  @override
  void dispose() {
    _keyController.dispose();
    _dailyController.dispose();
    _weeklyController.dispose();
    super.dispose();
  }

  Future<void> _loadCaps() async {
    final caps = await _controller.loadCaps();
    if (!mounted) return;
    _dailyController.text = caps.dailyUsd?.toString() ?? '';
    _weeklyController.text = caps.weeklyUsd?.toString() ?? '';
  }

  Future<void> _saveKey() async {
    await _controller.saveKey(
      _providerId,
      _keyController.text,
      webRiskAccepted: _riskAccepted,
    );
    if (!mounted) return;
    _keyController.clear();
    setState(() => _status = 'API key saved for this browser profile.');
  }

  Future<void> _removeKey() async {
    await _controller.removeKey(_providerId);
    if (!mounted) return;
    setState(() => _status = 'API key removed.');
  }

  Future<void> _saveCaps() async {
    await _controller.saveCaps(
      SpendCaps(
        dailyUsd: double.tryParse(_dailyController.text),
        weeklyUsd: double.tryParse(_weeklyController.text),
      ),
    );
    if (!mounted) return;
    setState(() => _status = 'Spend caps updated.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: WebProviderSettingsScreen.screenKey,
      appBar: AppBar(title: const Text('AI provider settings')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(MindlySpacing.xl),
            children: [
              Text(
                'Bring your own API key',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: MindlySpacing.md),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(MindlySpacing.md),
                  child: Text(webApiKeyWarning),
                ),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _riskAccepted,
                onChanged: (value) =>
                    setState(() => _riskAccepted = value ?? false),
                title: const Text(
                  'I understand the browser key-storage risk.',
                ),
              ),
              DropdownButtonFormField<String>(
                initialValue: _providerId,
                decoration: const InputDecoration(labelText: 'Provider'),
                items: const [
                  DropdownMenuItem(value: 'openai', child: Text('OpenAI')),
                  DropdownMenuItem(
                    value: 'anthropic',
                    child: Text('Anthropic'),
                  ),
                  DropdownMenuItem(
                    value: 'compatible',
                    child: Text('OpenAI-compatible'),
                  ),
                ],
                onChanged: (value) => setState(() => _providerId = value!),
              ),
              const SizedBox(height: MindlySpacing.md),
              TextField(
                controller: _keyController,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                decoration: const InputDecoration(labelText: 'API key'),
              ),
              const SizedBox(height: MindlySpacing.md),
              Wrap(
                spacing: MindlySpacing.sm,
                children: [
                  FilledButton(
                    onPressed: _riskAccepted ? _saveKey : null,
                    child: const Text('Save / rotate key'),
                  ),
                  TextButton(
                    onPressed: _removeKey,
                    child: const Text('Remove key'),
                  ),
                ],
              ),
              const Divider(height: MindlySpacing.xl),
              Text(
                'Cost controls',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: MindlySpacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _dailyController,
                      decoration: const InputDecoration(
                        labelText: 'Daily cap (USD)',
                      ),
                    ),
                  ),
                  const SizedBox(width: MindlySpacing.md),
                  Expanded(
                    child: TextField(
                      controller: _weeklyController,
                      decoration: const InputDecoration(
                        labelText: 'Weekly cap (USD)',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: MindlySpacing.md),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton(
                  onPressed: _saveCaps,
                  child: const Text('Save spend caps'),
                ),
              ),
              if (_status.isNotEmpty) ...[
                const SizedBox(height: MindlySpacing.md),
                Text(_status),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
