import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/duration_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../providers/today_attendance_provider.dart';

/// Working hours today with progress toward an 8-hour day. Refreshes
/// every 30 seconds while the screen is open.
class WorkedTodayCard extends ConsumerStatefulWidget {
  const WorkedTodayCard({super.key});

  @override
  ConsumerState<WorkedTodayCard> createState() => _WorkedTodayCardState();
}

class _WorkedTodayCardState extends ConsumerState<WorkedTodayCard> {
  static const _target = Duration(hours: 8);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final today = ref.watch(todayAttendanceProvider);
    final worked = today.workedDuration;
    final progress =
        (worked.inMinutes / _target.inMinutes).clamp(0.0, 1.0).toDouble();

    final note = switch (today.status) {
      AttendanceStatus.notCheckedIn => 'Check in to start tracking',
      AttendanceStatus.checkedIn => 'Tracking live',
      AttendanceStatus.checkedOut => 'Day complete',
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.mdAll,
                ),
                child: const Icon(
                  Icons.timer_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Working hours today',
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                    Text(
                      worked.hoursMinutes,
                      style: theme.textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Target 8h', style: theme.textTheme.labelLarge),
                  Text(
                    note,
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              color: AppColors.primary,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }
}