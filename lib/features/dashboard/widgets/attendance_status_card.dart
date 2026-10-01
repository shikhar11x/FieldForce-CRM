import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../attendance/providers/today_attendance_provider.dart';

class AttendanceStatusCard extends ConsumerWidget {
  const AttendanceStatusCard({super.key});

  String _time(BuildContext context, DateTime t) =>
      TimeOfDay.fromDateTime(t).format(context);

  String _duration(Duration d) => '${d.inHours}h ${d.inMinutes.remainder(60)}m';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final today = ref.watch(todayAttendanceProvider);
    final notifier = ref.read(todayAttendanceProvider.notifier);

    final (title, subtitle, color, icon) = switch (today.status) {
      AttendanceStatus.notCheckedIn => (
          'Not checked in',
          'Check in to start your workday',
          AppColors.warning,
          Icons.schedule_rounded,
        ),
      AttendanceStatus.checkedIn => (
          'Checked in',
          'Since ${_time(context, today.checkIn!)}',
          AppColors.success,
          Icons.check_circle_rounded,
        ),
      AttendanceStatus.checkedOut => (
          'Day complete',
          'Worked ${_duration(today.workedDuration)} · '
              'out at ${_time(context, today.checkOut!)}',
          AppColors.info,
          Icons.verified_rounded,
        ),
    };

    final Widget? action = switch (today.status) {
      AttendanceStatus.notCheckedIn => FilledButton.icon(
          onPressed: () {
            notifier.checkIn();
            context.showSnack('Checked in. Have a productive day!');
          },
          icon: const Icon(Icons.login_rounded),
          label: const Text('Check In'),
        ),
      AttendanceStatus.checkedIn => FilledButton.tonalIcon(
          onPressed: () {
            notifier.checkOut();
            context.showSnack('Checked out. See you tomorrow!');
          },
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Check Out'),
        ),
      AttendanceStatus.checkedOut => null,
    };

    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadius.mdAll,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: AppSpacing.md),
            action,
          ],
        ],
      ),
    );
  }
}