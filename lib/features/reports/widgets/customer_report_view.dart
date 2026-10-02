import 'dart:math' as math;

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
import '../../../core/widgets/progress_row.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stat_grid.dart';
import '../../../data/models/report_models.dart';
import '../providers/report_provider.dart';
import 'report_charts.dart';
import 'report_layout.dart';
import 'report_scroll_view.dart';

class CustomerReportView extends ConsumerWidget {
  const CustomerReportView({super.key, required this.query});

  final ReportQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = customerReportProvider(query);

    return ReportScrollView(
      onRefresh: () => refreshReport(
        () => ref.invalidate(provider),
        () => ref.read(provider.future),
      ),
      child: AsyncValueView<CustomerReport>(
        value: ref.watch(provider),
        onRetry: () => ref.invalidate(provider),
        loading: const ReportSkeleton(),
        data: (report) => _CustomerContent(report: report),
      ),
    );
  }
}

class _CustomerContent extends StatelessWidget {
  const _CustomerContent({required this.report});

  final CustomerReport report;

  @override
  Widget build(BuildContext context) {
    final maxVisits = report.mostVisited.fold<double>(
      0,
      (m, p) => math.max(m, p.value),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Overview'),
        StatGrid(
          columns: reportFourColumns,
          items: [
            StatGridItem(
              label: 'Active customers',
              value: '${report.activeCustomers}',
              icon: Icons.business_center_rounded,
              color: AppColors.success,
            ),
            StatGridItem(
              label: 'New customers',
              value: '${report.newCustomers}',
              icon: Icons.person_add_alt_1_rounded,
              color: AppColors.info,
            ),
            StatGridItem(
              label: 'Inactive',
              value: '${report.inactiveCustomers}',
              icon: Icons.pause_circle_outline_rounded,
              color: AppColors.warning,
            ),
            StatGridItem(
              label: 'Total visits',
              value: '${report.totalVisits}',
              icon: Icons.place_rounded,
              color: AppColors.primary,
            ),
          ],
        ).entrance(1),
        const SectionHeader(title: 'Growth'),
        AdaptiveWrap(
          columns: reportChartColumns,
          children: [
            ChartCard(
              title: 'New customers',
              subtitle: 'Added in this period',
              child: AppLineChart(
                points: report.newCustomerTrend,
                color: AppColors.info,
              ),
            ),
            ChartCard(
              title: 'Customers by status',
              subtitle: 'Current',
              child: ReportDonut(
                segments: report.statusBreakdown,
                centerLabel: 'Customers',
                colors: const [
                  AppColors.success,
                  AppColors.lightTextSecondary,
                  AppColors.info,
                ],
              ),
            ),
          ],
        ).entrance(2),
        const SectionHeader(title: 'Most visited customers'),
        AppCard(
          child: Column(
            children: [
              for (final (i, p) in report.mostVisited.indexed) ...[
                if (i > 0) const SizedBox(height: AppSpacing.md),
                ProgressRow(
                  label: p.label,
                  value: '${p.value.round()} visits',
                  progress: maxVisits == 0 ? 0 : p.value / maxVisits,
                  color: AppColors.primary,
                ),
              ],
            ],
          ),
        ).entrance(3),
      ],
    );
  }
}