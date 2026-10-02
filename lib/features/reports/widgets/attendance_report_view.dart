import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/animate_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/adaptive_wrap.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/chart_card.dart';
import '../../../core/widgets/charts/app_line_chart.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/progress_row.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stat_grid.dart';
import '../../../data/models/report_models.dart';
import '../providers/report_provider.dart';
import 'report_charts.dart';
import 'report_layout.dart';
import 'report_scroll_view.dart';

class AttendanceReportView extends ConsumerWidget {
  const AttendanceReportView({super.key, required this.query});

  final ReportQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = attendanceReportProvider(query);

    return ReportScrollView(
      onRefresh: () => refreshReport(
        () => ref.invalidate(provider),
        () => ref.read(provider.future),
      ),
      child: AsyncValueView<AttendanceReport>(
        value: ref.watch(provider),
        onRetry: () => ref.invalidate(provider),
        loading: const ReportSkeleton(),
        isEmpty: (report) => report.rows.isEmpty,
        empty: const EmptyState(
          icon: Icons.event_busy_rounded,
          title: 'No attendance data',
          message: 'Try different filters to see attendance.',
        ),
        data: (report) => _AttendanceContent(report: report),
      ),
    );
  }
}

class _AttendanceContent extends StatelessWidget {
  const _AttendanceContent({required this.report});

  final AttendanceReport report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Overview'),
        StatGrid(
          columns: reportSixColumns,
          items: [
            StatGridItem(
              label: 'Attendance',
              value: '${report.averagePercent.round()}%',
              icon: Icons.event_available_rounded,
              color: AppColors.accent,
            ),
            StatGridItem(
              label: 'Present',
              value: '${report.totalPresent}',
              icon: Icons.check_circle_rounded,
              color: AppColors.success,
            ),
            StatGridItem(
              label: 'Late',
              value: '${report.totalLate}',
              icon: Icons.schedule_rounded,
              color: AppColors.warning,
            ),
            StatGridItem(
              label: 'Half day',
              value: '${report.totalHalf}',
              icon: Icons.timelapse_rounded,
              color: AppColors.info,
            ),
            StatGridItem(
              label: 'Absent',
              value: '${report.totalAbsent}',
              icon: Icons.event_busy_rounded,
              color: AppColors.error,
            ),
            StatGridItem(
              label: 'Working days',
              value: '${report.workingDays}',
              icon: Icons.calendar_month_rounded,
              color: AppColors.primary,
            ),
          ],
        ).entrance(1),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Present, late, half day and absent are counted in employee-days.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SectionHeader(title: 'Trends'),
        AdaptiveWrap(
          columns: reportChartColumns,
          children: [
            ChartCard(
              title: 'Attendance trend',
              subtitle: 'Present % across the period',
              child: AppLineChart(
                points: report.trend,
                color: AppColors.success,
                minY: 60,
                maxY: 100,
              ),
            ),
            ChartCard(
              title: 'Day status',
              subtitle: 'Employee-days',
              child: ReportDonut(
                segments: report.breakdown,
                centerLabel: 'Days',
                colors: const [
                  AppColors.success,
                  AppColors.warning,
                  AppColors.info,
                  AppColors.error,
                ],
              ),
            ),
          ],
        ).entrance(2),
        const SectionHeader(title: 'Attendance by employee'),
        AppCard(
          child: Column(
            children: [
              for (final (i, r) in report.rows.indexed) ...[
                if (i > 0) const SizedBox(height: AppSpacing.md),
                ProgressRow(
                  label: r.name,
                  value: '${r.percent.round()}%',
                  progress: r.percent / 100,
                  color: r.percent >= 90
                      ? AppColors.success
                      : (r.percent >= 75 ? AppColors.info : AppColors.warning),
                  caption: '${r.presentDays} present · ${r.lateDays} late · '
                      '${r.absentDays} absent',
                ),
              ],
            ],
          ),
        ).entrance(3),
      ],
    );
  }
}