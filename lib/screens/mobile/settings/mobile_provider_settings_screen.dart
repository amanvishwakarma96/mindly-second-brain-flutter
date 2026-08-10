import 'package:flutter/material.dart';
import 'package:mindly/features/ai_settings/application/provider_settings_controller.dart';
import 'package:mindly/features/ai_settings/domain/cost_models.dart';
import 'package:mindly/shared/design_tokens/mindly_spacing.dart';

class MobileProviderSettingsScreen extends StatefulWidget {
  const MobileProviderSettingsScreen({super.key, this.controller});

  static const screenKey = ValueKey<String>('screen-mobile-provider-settings');

  final ProviderSettingsController? controller;

  @override
  State<MobileProviderSettingsScreen> createState() =>
      _MobileProviderSettingsScreenState();
}

class _MobileProviderSettingsScreenState
    extends State<MobileProviderSettingsScreen> {
  late final ProviderSettingsController _controller;
  final _keyController = TextEditingController();
  final _dailyController = TextEditingController();
  final _weeklyController = TextEditingController();
  String _providerId = 'openai';
  String _status = '';

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ProviderSettingsController.production();
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
    await _controller.saveKey(_providerId, _keyController.text);
    if (!mounted) return;
    _keyController.clear();
    setState(() => _status = 'API key saved securely on this device.');
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
      key: MobileProviderSettingsScreen.screenKey,
      appBar: AppBar(title: const Text('AI providers')),
      body: ListView(
        padding: const EdgeInsets.all(MindlySpacing.md),
        children: [
          Text(
            'Bring your own API key',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: MindlySpacing.md),
          DropdownButtonFormField<String>(
            initialValue: _providerId,
            decoration: const InputDecoration(labelText: 'Provider'),
            items: const [
              DropdownMenuItem(value: 'openai', child: Text('OpenAI')),
              DropdownMenuItem(value: 'anthropic', child: Text('Anthropic')),
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
          FilledButton(onPressed: _saveKey, child: const Text('Save key')),
          TextButton(onPressed: _removeKey, child: const Text('Remove key')),
          const Divider(height: MindlySpacing.xl),
          Text('Spend caps', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: MindlySpacing.sm),
          TextField(
            controller: _dailyController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Daily cap (USD)'),
          ),
          const SizedBox(height: MindlySpacing.sm),
          TextField(
            controller: _weeklyController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Weekly cap (USD)'),
          ),
          const SizedBox(height: MindlySpacing.md),
          OutlinedButton(
            onPressed: _saveCaps,
            child: const Text('Save spend caps'),
          ),
          if (_status.isNotEmpty) ...[
            const SizedBox(height: MindlySpacing.md),
            Text(_status),
          ],
        ],
      ),
    );
  }
}
