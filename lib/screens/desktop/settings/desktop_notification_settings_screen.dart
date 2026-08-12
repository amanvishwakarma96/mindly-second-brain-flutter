import 'package:flutter/material.dart';
import 'package:mindly/features/notifications/application/notification_controller.dart';
import 'package:mindly/features/notifications/domain/notification_models.dart';
import 'package:mindly/shared/design_tokens/mindly_spacing.dart';

class DesktopNotificationSettingsScreen extends StatefulWidget {
  const DesktopNotificationSettingsScreen({super.key, required this.controller});

  static const screenKey = ValueKey<String>(
    'screen-desktop-notification-settings',
  );

  final NotificationController controller;

  @override
  State<DesktopNotificationSettingsScreen> createState() =>
      _DesktopNotificationSettingsScreenState();
}

class _DesktopNotificationSettingsScreenState
    extends State<DesktopNotificationSettingsScreen> {
  NotificationPreferences _preferences = const NotificationPreferences();
  bool _loading = true;
  bool _saving = false;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final preferences = await widget.controller.loadPreferences();
    if (!mounted) return;
    setState(() {
      _preferences = preferences;
      _loading = false;
    });
  }

  Future<TimeOfDay?> _pick(int minutes) => showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
  );

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _status = '';
    });
    final outcome = await widget.controller.savePreferences(_preferences);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _status = outcome.saved
          ? 'Notification preferences saved on this device.'
          : outcome.message ?? 'Notification preferences were not changed.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final capabilities = widget.controller.capabilities;
    return Scaffold(
      key: DesktopNotificationSettingsScreen.screenKey,
      appBar: AppBar(title: const Text('Notification preferences')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(MindlySpacing.xl),
                child: SizedBox(
                  width: 720,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(MindlySpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Helpful, not noisy',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: MindlySpacing.sm),
                          Text(capabilities.message),
                          const SizedBox(height: MindlySpacing.lg),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Tier 2 pattern alerts'),
                            subtitle: const Text(
                              'Schedule one local alert for each newly surfaced Tier 2 insight.',
                            ),
                            value: _preferences.tier2AlertsEnabled,
                            onChanged: capabilities.canSchedule
                                ? (value) => setState(
                                    () => _preferences = _preferences.copyWith(
                                      tier2AlertsEnabled: value,
                                    ),
                                  )
                                : null,
                          ),
                          const Divider(),
                          DropdownButtonFormField<NotificationDigestFrequency>(
                            initialValue: _preferences.digestFrequency,
                            decoration: const InputDecoration(
                              labelText: 'Digest frequency',
                            ),
                            items: [
                              for (final value
                                  in NotificationDigestFrequency.values)
                                DropdownMenuItem(
                                  value: value,
                                  child: Text(value.displayName),
                                ),
                            ],
                            onChanged: capabilities.canSchedule
                                ? (value) => setState(
                                    () => _preferences = _preferences.copyWith(
                                      digestFrequency: value ??
                                          NotificationDigestFrequency.off,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: MindlySpacing.md),
                          _TimeRow(
                            label: 'Digest time',
                            value: _format(
                              _preferences.digestHour * 60 +
                                  _preferences.digestMinute,
                            ),
                            enabled: capabilities.canSchedule,
                            onTap: () async {
                              final picked = await _pick(
                                _preferences.digestHour * 60 +
                                    _preferences.digestMinute,
                              );
                              if (picked == null) return;
                              setState(() {
                                _preferences = _preferences.copyWith(
                                  digestHour: picked.hour,
                                  digestMinute: picked.minute,
                                );
                              });
                            },
                          ),
                          const Divider(),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Quiet hours'),
                            subtitle: const Text(
                              'Alerts that land in this window wait until quiet hours end.',
                            ),
                            value: _preferences.quietHoursEnabled,
                            onChanged: capabilities.canSchedule
                                ? (enabled) => setState(() {
                                    _preferences = enabled
                                        ? _preferences.copyWith(
                                            quietStartMinutes: 22 * 60,
                                            quietEndMinutes: 7 * 60,
                                          )
                                        : _preferences.copyWith(
                                            quietEndMinutes:
                                                _preferences.quietStartMinutes,
                                          );
                                  })
                                : null,
                          ),
                          if (_preferences.quietHoursEnabled)
                            Row(
                              children: [
                                Expanded(
                                  child: _TimeRow(
                                    label: 'Quiet starts',
                                    value: _format(
                                      _preferences.quietStartMinutes,
                                    ),
                                    enabled: true,
                                    onTap: () async {
                                      final picked = await _pick(
                                        _preferences.quietStartMinutes,
                                      );
                                      if (picked == null) return;
                                      setState(() {
                                        _preferences = _preferences.copyWith(
                                          quietStartMinutes:
                                              picked.hour * 60 + picked.minute,
                                        );
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: MindlySpacing.lg),
                                Expanded(
                                  child: _TimeRow(
                                    label: 'Quiet ends',
                                    value: _format(
                                      _preferences.quietEndMinutes,
                                    ),
                                    enabled: true,
                                    onTap: () async {
                                      final picked = await _pick(
                                        _preferences.quietEndMinutes,
                                      );
                                      if (picked == null) return;
                                      setState(() {
                                        _preferences = _preferences.copyWith(
                                          quietEndMinutes:
                                              picked.hour * 60 + picked.minute,
                                        );
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: MindlySpacing.lg),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton(
                              onPressed:
                                  capabilities.canSchedule && !_saving
                                  ? _save
                                  : null,
                              child: Text(_saving ? 'Saving…' : 'Save'),
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
                ),
              ),
            ),
    );
  }

  String _format(int value) =>
      TimeOfDay(hour: value ~/ 60, minute: value % 60).format(context);
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(value),
      trailing: const Icon(Icons.schedule_rounded),
      onTap: enabled ? onTap : null,
    );
  }
}
