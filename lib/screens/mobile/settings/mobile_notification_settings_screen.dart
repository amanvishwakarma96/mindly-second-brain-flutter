import 'package:flutter/material.dart';
import 'package:mindly/features/notifications/application/notification_controller.dart';
import 'package:mindly/features/notifications/domain/notification_models.dart';
import 'package:mindly/shared/design_tokens/mindly_spacing.dart';

class MobileNotificationSettingsScreen extends StatefulWidget {
  const MobileNotificationSettingsScreen({super.key, required this.controller});

  static const screenKey = ValueKey<String>(
    'screen-mobile-notification-settings',
  );

  final NotificationController controller;

  @override
  State<MobileNotificationSettingsScreen> createState() =>
      _MobileNotificationSettingsScreenState();
}

class _MobileNotificationSettingsScreenState
    extends State<MobileNotificationSettingsScreen> {
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

  Future<void> _pickDigestTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _preferences.digestHour,
        minute: _preferences.digestMinute,
      ),
    );
    if (picked == null) return;
    setState(() {
      _preferences = _preferences.copyWith(
        digestHour: picked.hour,
        digestMinute: picked.minute,
      );
    });
  }

  Future<void> _pickQuietTime({required bool start}) async {
    final minutes = start
        ? _preferences.quietStartMinutes
        : _preferences.quietEndMinutes;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
    );
    if (picked == null) return;
    final value = picked.hour * 60 + picked.minute;
    setState(() {
      _preferences = start
          ? _preferences.copyWith(quietStartMinutes: value)
          : _preferences.copyWith(quietEndMinutes: value);
    });
  }

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
      key: MobileNotificationSettingsScreen.screenKey,
      appBar: AppBar(title: const Text('Notifications')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(MindlySpacing.md),
              children: [
                Text(
                  'A quiet nudge, only when it helps',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: MindlySpacing.sm),
                Text(capabilities.message),
                const SizedBox(height: MindlySpacing.lg),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Tier 2 pattern alerts'),
                  subtitle: const Text(
                    'Notify once when a new local pattern or commitment needs attention.',
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
                  decoration: const InputDecoration(labelText: 'Digest frequency'),
                  items: [
                    for (final value in NotificationDigestFrequency.values)
                      DropdownMenuItem(
                        value: value,
                        child: Text(value.displayName),
                      ),
                  ],
                  onChanged: capabilities.canSchedule
                      ? (value) => setState(
                          () => _preferences = _preferences.copyWith(
                            digestFrequency:
                                value ?? NotificationDigestFrequency.off,
                          ),
                        )
                      : null,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Digest time'),
                  subtitle: Text(
                    _formatMinutes(
                      _preferences.digestHour * 60 + _preferences.digestMinute,
                    ),
                  ),
                  trailing: const Icon(Icons.schedule_rounded),
                  onTap: capabilities.canSchedule ? _pickDigestTime : null,
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Quiet hours'),
                  subtitle: const Text('Delay alerts until your quiet window ends.'),
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
                if (_preferences.quietHoursEnabled) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Quiet starts'),
                    subtitle: Text(
                      _formatMinutes(_preferences.quietStartMinutes),
                    ),
                    onTap: () => _pickQuietTime(start: true),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Quiet ends'),
                    subtitle: Text(
                      _formatMinutes(_preferences.quietEndMinutes),
                    ),
                    onTap: () => _pickQuietTime(start: false),
                  ),
                ],
                const SizedBox(height: MindlySpacing.lg),
                FilledButton(
                  onPressed: capabilities.canSchedule && !_saving ? _save : null,
                  child: Text(_saving ? 'Saving…' : 'Save preferences'),
                ),
                if (_status.isNotEmpty) ...[
                  const SizedBox(height: MindlySpacing.md),
                  Text(_status),
                ],
              ],
            ),
    );
  }

  String _formatMinutes(int value) {
    final time = TimeOfDay(hour: value ~/ 60, minute: value % 60);
    return time.format(context);
  }
}
