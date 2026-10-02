import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/animate_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/adaptive_wrap.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/chart_card.dart';
import '../../../core/widgets/charts/app_bar_chart.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stat_grid.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/chart_point.dart';
import '../../../data/models/report_models.dart';
import '../providers/report_provider.dart';
import 'report_charts.dart';
import 'report_layout.dart';
import 'report_scroll_view.dart';

class EmployeeReportView extends ConsumerWidget {
  const EmployeeReportView({super.key, required this.query});

  final ReportQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = employeeReportProvider(query);

    return ReportScrollView(
      onRefresh: () => refreshReport(
        () => ref.invalidate(provider),
        () => ref.read(provider.future),
      ),
      child: AsyncValueView<EmployeeReport>(
        value: ref.watch(provider),
        onRetry: () => ref.invalidate(provider),
        loading: const ReportSkeleton(),
        isEmpty: (report) => report.rows.isEmpty,
        empty: const EmptyState(
          icon: Icons.groups_outlined,
          title: 'No employees found',
          message: 'Try different filters to see employee data.',
        ),
        data: (report) => _EmployeeContent(report: report),
      ),
    );
  }
}

class _EmployeeContent extends StatelessWidget {
  const _EmployeeContent({required this.report});

  final EmployeeReport report;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Overview'),
        StatGrid(
          columns: reportFourColumns,
          items: [
            StatGridItem(
              label: 'Total visits',
              value: '${report.totalVisits}',
              icon: Icons.place_rounded,
              color: AppColors.info,
            ),
            StatGridItem(
              label: 'Tasks completed',
              value: '${report.tasksCompleted}',
              icon: Icons.task_alt_rounded,
              color: AppColors.success,
            ),
            StatGridItem(
              label: 'Avg. attendance',
              value: '${report.averageAttendance.round()}%',
              icon: Icons.event_available_rounded,
              color: AppColors.accent,
            ),
            StatGridItem(
              label: 'Avg. performance',
              value: '${report.averagePerformance.round()}',
              icon: Icons.speed_rounded,
              color: AppColors.primary,
            ),
          ],
        ).entrance(1),
        const SectionHeader(title: 'Breakdown'),
        AdaptiveWrap(
          columns: reportChartColumns,
          children: [
            ChartCard(
              title: 'Visits by employee',
              subtitle: 'Selected period',
              child: AppBarChart(
                points: [
                  for (final r in report.rows)
                    ChartPoint(r.name.split(' ').first, r.visits.toDouble()),
                ],
                color: AppColors.info,
              ),
            ),
            ChartCard(
              title: 'Task status',
              subtitle: 'All assigned tasks',
              child: ReportDonut(
                segments: report.taskBreakdown,
                centerLabel: 'Tasks',
                colors: const [
                  AppColors.success,
                  AppColors.primary,
                  AppColors.warning,
                  AppColors.error,
                ],
              ),
            ),
          ],
        ).entrance(2),
        const SectionHeader(title: 'Performance ranking'),
        AppCard(
          child: Column(
            children: [
              for (final (i, row) in report.rows.indexed) ...[
                if (i > 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Divider(),
                  ),
                _EmployeeRow(row: row),
              ],
            ],
          ),
        ).entrance(3),
      ],
    );
  }
}

class _EmployeeRow extends StatelessWidget {
  const _EmployeeRow({required this.row});

  final EmployeeReportRow row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final color = row.performance >= 85
        ? AppColors.success
        : (row.performance >= 70 ? AppColors.info : AppColors.warning);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InitialsAvatar(name: row.name, radius: 18),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  Text(
                    row.team,
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            StatusChip(label: 'Score ${row.performance}', color: color),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: row.performance / 100,
            minHeight: 6,
            color: color,
            backgroundColor: color.withValues(alpha: 0.15),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '${row.visits} visits · ${row.tasksCompleted}/${row.tasksTotal} '
          'tasks · ${row.attendancePercent.round()}% attendance',
          style: theme.textTheme.bodySmall?.copyWith(color: muted),
        ),
      ],
    );
  }
}