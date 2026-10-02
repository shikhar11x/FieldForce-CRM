import 'package:flutter/material.dart';

import '../../../core/extensions/attendance_style_extensions.dart';
import '../../../core/extensions/duration_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/attendance_models.dart';

/// Daily log, newest first. Week-offs are left out.
class AttendanceHistoryList extends StatelessWidget {
  const AttendanceHistoryList({super.key, required this.records});

  final List<AttendanceRecord> records;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  String _times(BuildContext context, AttendanceRecord r) {
    final start = r.checkIn;
    final end = r.checkOut;
    if (start == null) return 'No check-in recorded';

    String format(DateTime t) => TimeOfDay.fromDateTime(t).format(context);
    if (end == null) return '${format(start)} - working';
    return '${format(start)} - ${format(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final days = records
        .where((r) => r.status != AttendanceDayStatus.weekOff)
        .toList()
        .reversed
        .toList();

    if (days.isEmpty) {
      return const AppCard(
        child: EmptyState(
          icon: Icons.event_busy_rounded,
          title: 'No attendance records',
          message: 'Records for this month will appear here.',
        ),
      );
    }

    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        children: [
          for (final (i, r) in days.indexed) ...[
            if (i > 0) const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 44,
                    child: Column(
                      children: [
                        Text('${r.date.day}', style: theme.textTheme.titleMedium),
                        Text(
                          _weekdays[r.date.weekday - 1],
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      _times(context, r),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      StatusChip(label: r.status.label, color: r.status.color),
                      if (r.worked != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          r.worked!.hoursMinutes,
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: muted),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}