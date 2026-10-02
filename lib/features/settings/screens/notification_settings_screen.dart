import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/notification_style_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/settings_tile.dart';
import '../../../data/models/notification_models.dart';
import '../providers/settings_provider.dart';

String _hint(NotificationCategory c) => switch (c) {
      NotificationCategory.tasks => 'New assignments, due dates and overdue alerts',
      NotificationCategory.visits => 'Schedules, changes and completions',
      NotificationCategory.attendance => 'Check-in reminders and late alerts',
      NotificationCategory.leads => 'Stage changes and new assignments',
      NotificationCategory.system => 'Reports, updates and security notices',
    };

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);
    final pushOn = settings.pushEnabled;

    return Scaffold(
      appBar: AppBar(title: const Text('Notification settings')),
      body: ResponsiveBody(
        maxWidth: 600,
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          children: [
            SettingsGroup(
              children: [
                SettingsSwitchTile(
                  icon: Icons.notifications_active_rounded,
                  title: 'Push notifications',
                  subtitle: 'Receive alerts on this device',
                  value: pushOn,
                  onChanged: notifier.setPush,
                ),
              ],
            ),
            const SectionHeader(title: 'Categories'),
            SettingsGroup(
              children: [
                for (final category in NotificationCategory.values)
                  SettingsSwitchTile(
                    icon: category.icon,
                    color: category.color,
                    title: category.label,
                    subtitle: _hint(category),
                    value: pushOn && settings.isCategoryEnabled(category),
                    onChanged: pushOn
                        ? (on) => notifier.setCategory(category, on)
                        : null,
                  ),
              ],
            ),
            const SectionHeader(title: 'Delivery'),
            SettingsGroup(
              children: [
                SettingsSwitchTile(
                  icon: Icons.mark_email_unread_outlined,
                  title: 'Daily email summary',
                  subtitle: 'A digest of what happened each day',
                  value: settings.emailSummary,
                  onChanged: notifier.setEmailSummary,
                ),
                SettingsSwitchTile(
                  icon: Icons.volume_up_outlined,
                  title: 'Sound',
                  value: pushOn && settings.sound,
                  onChanged: pushOn ? notifier.setSound : null,
                ),
                SettingsSwitchTile(
                  icon: Icons.vibration_rounded,
                  title: 'Vibration',
                  value: pushOn && settings.vibration,
                  onChanged: pushOn ? notifier.setVibration : null,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'These preferences apply on this device for now. Push '
              'delivery arrives in Phase 2.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}