import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/animate_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/adaptive_wrap.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/chart_card.dart';
import '../../../core/widgets/charts/app_bar_chart.dart';
import '../../../core/widgets/charts/app_line_chart.dart';
import '../../../core/widgets/progress_row.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stat_grid.dart';
import '../../../data/models/report_models.dart';
import '../providers/report_provider.dart';
import 'report_charts.dart';
import 'report_layout.dart';
import 'report_scroll_view.dart';

class SalesReportView extends ConsumerWidget {
  const SalesReportView({super.key, required this.query});

  final ReportQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = salesReportProvider(query);

    return ReportScrollView(
      onRefresh: () => refreshReport(
        () => ref.invalidate(provider),
        () => ref.read(provider.future),
      ),
      child: AsyncValueView<SalesReport>(
        value: ref.watch(provider),
        onRetry: () => ref.invalidate(provider),
        loading: const ReportSkeleton(),
        data: (report) => _SalesContent(report: report),
      ),
    );
  }
}

class _SalesContent extends StatelessWidget {
  const _SalesContent({required this.report});

  final SalesReport report;

  @override
  Widget build(BuildContext context) {
    final percent = report.targetPercent;
    final targetColor = percent >= 100
        ? AppColors.success
        : (percent >= 75 ? AppColors.primary : AppColors.warning);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Overview'),
        StatGrid(
          columns: reportSixColumns,
          items: [
            StatGridItem(
              label: 'Revenue',
              value: formatInr(report.revenue),
              icon: Icons.account_balance_wallet_rounded,
              color: AppColors.accent,
            ),
            StatGridItem(
              label: 'Leads',
              value: '${report.leads}',
              icon: Icons.filter_alt_rounded,
              color: AppColors.primary,
            ),
            StatGridItem(
              label: 'Conversions',
              value: '${report.conversions}',
              icon: Icons.emoji_events_rounded,
              color: AppColors.success,
            ),
            StatGridItem(
              label: 'Conversion rate',
              value: '${report.conversionRate.round()}%',
              icon: Icons.trending_up_rounded,
              color: AppColors.info,
            ),
            StatGridItem(
              label: 'Avg. deal size',
              value: formatInr(report.averageDeal),
              icon: Icons.payments_rounded,
              color: AppColors.secondary,
            ),
            StatGridItem(
              label: 'Target achieved',
              value: '${percent.round()}%',
              icon: Icons.flag_rounded,
              color: AppColors.warning,
            ),
          ],
        ).entrance(1),
        const SectionHeader(title: 'Revenue target'),
        AppCard(
          child: ProgressRow(
            label: 'Revenue vs target',
            value: '${percent.round()}%',
            progress: percent / 100,
            color: targetColor,
            caption:
                '${formatInr(report.revenue)} of ${formatInr(report.target)}',
          ),
        ).entrance(2),
        const SectionHeader(title: 'Trends'),
        AdaptiveWrap(
          columns: reportChartColumns,
          children: [
            ChartCard(
              title: 'Revenue trend',
              subtitle: '₹ lakh',
              child: AppLineChart(
                points: report.revenueTrend,
                color: AppColors.accent,
              ),
            ),
            ChartCard(
              title: 'Revenue by employee',
              subtitle: '₹ lakh',
              child: AppBarChart(
                points: report.revenueByEmployee,
                color: AppColors.secondary,
              ),
            ),
            ChartCard(
              title: 'Lead outcomes',
              subtitle: 'Created in this period',
              child: ReportDonut(
                segments: report.leadOutcomes,
                centerLabel: 'Leads',
                colors: const [
                  AppColors.success,
                  AppColors.primary,
                  AppColors.error,
                ],
              ),
            ),
          ],
        ).entrance(3),
      ],
    );
  }
}