import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/duration_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../../core/widgets/stat_grid.dart';
import '../../../data/models/attendance_models.dart';
import '../providers/attendance_provider.dart';
import '../providers/today_attendance_provider.dart';
import 'attendance_calendar.dart';
import 'attendance_history_list.dart';
import 'attendance_layout.dart';

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// Month switcher, summary, calendar and daily log for one employee.
/// Set [isSelf] to merge in the live check-in state for the current month.
class AttendanceMonthView extends ConsumerStatefulWidget {
  const AttendanceMonthView({
    super.key,
    required this.employee,
    this.isSelf = false,
  });

  final String employee;
  final bool isSelf;

  @override
  ConsumerState<AttendanceMonthView> createState() =>
      _AttendanceMonthViewState();
}

class _AttendanceMonthViewState extends ConsumerState<AttendanceMonthView> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _month.year == now.year && _month.month == now.month;
  }

  void _shift(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  @override
  Widget build(BuildContext context) {
    final query = (
      employee: widget.employee,
      year: _month.year,
      month: _month.month,
    );
    final records = ref.watch(attendanceMonthProvider(query));
    final TodayAttendance? today =
        widget.isSelf ? ref.watch(todayAttendanceProvider) : null;

    final merged = records.whenData(
      (list) => (today != null && _isCurrentMonth)
          ? mergeToday(list, today)
          : list,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MonthSwitcher(
          label: '${_monthNames[_month.month - 1]} ${_month.year}',
          onPrevious: () => _shift(-1),
          onNext: _isCurrentMonth ? null : () => _shift(1),
        ),
        AsyncValueView<List<AttendanceRecord>>(
          value: merged,
          onRetry: () => ref.invalidate(attendanceMonthProvider(query)),
          loading: const _MonthSkeleton(),
          data: (list) => _MonthContent(
            year: _month.year,
            month: _month.month,
            records: list,
          ),
        ),
      ],
    );
  }
}

class _MonthSwitcher extends StatelessWidget {
  const _MonthSwitcher({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Previous month',
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: onPrevious,
        ),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          tooltip: 'Next month',
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: onNext,
        ),
      ],
    );
  }
}

class _MonthContent extends StatelessWidget {
  const _MonthContent({
    required this.year,
    required this.month,
    required this.records,
  });

  final int year;
  final int month;
  final List<AttendanceRecord> records;

  @override
  Widget build(BuildContext context) {
    final summary = AttendanceSummary.fromRecords(records);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Summary'),
        StatGrid(
          columns: attendanceStatColumns,
          items: [
            StatGridItem(
              label: 'Attendance',
              value: '${summary.percent.round()}%',
              icon: Icons.event_available_rounded,
              color: AppColors.accent,
            ),
            StatGridItem(
              label: 'Present',
              value: '${summary.presentDays}',
              icon: Icons.check_circle_rounded,
              color: AppColors.success,
            ),
            StatGridItem(
              label: 'Late',
              value: '${summary.lateDays}',
              icon: Icons.schedule_rounded,
              color: AppColors.warning,
            ),
            StatGridItem(
              label: 'Half day',
              value: '${summary.halfDays}',
              icon: Icons.timelapse_rounded,
              color: AppColors.info,
            ),
            StatGridItem(
              label: 'Absent',
              value: '${summary.absentDays}',
              icon: Icons.event_busy_rounded,
              color: AppColors.error,
            ),
            StatGridItem(
              label: 'Hours worked',
              value: summary.totalWorked.hoursMinutes,
              icon: Icons.timer_outlined,
              color: AppColors.primary,
            ),
          ],
        ),
        const SectionHeader(title: 'Calendar'),
        AppCard(
          child: AttendanceCalendar(
            year: year,
            month: month,
            records: records,
          ),
        ),
        const SectionHeader(title: 'Daily log'),
        AttendanceHistoryList(records: records),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _MonthSkeleton extends StatelessWidget {
  const _MonthSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: AppSpacing.xl),
        SkeletonBox(height: 112, radius: AppRadius.lg),
        SizedBox(height: AppSpacing.lg),
        SkeletonBox(height: 112, radius: AppRadius.lg),
        SizedBox(height: AppSpacing.lg),
        SkeletonBox(height: 300, radius: AppRadius.lg),
      ],
    );
  }
}