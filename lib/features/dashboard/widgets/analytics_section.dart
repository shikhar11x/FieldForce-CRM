import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/adaptive_wrap.dart';
import '../../../core/widgets/chart_card.dart';
import '../../../core/widgets/charts/app_bar_chart.dart';
import '../../../core/widgets/charts/app_donut_chart.dart';
import '../../../core/widgets/charts/app_line_chart.dart';
import '../../../data/models/dashboard_models.dart';
import 'dashboard_layout.dart';

class AnalyticsSection extends StatelessWidget {
  const AnalyticsSection({super.key, required this.data});

  final AdminDashboardData data;

  @override
  Widget build(BuildContext context) {
    return AdaptiveWrap(
      columns: DashboardLayout.chartColumns,
      children: [
        ChartCard(
          title: 'Employee performance',
          subtitle: 'Top performers · score out of 100',
          child: AppBarChart(points: data.employeePerformance, maxY: 100),
        ),
        ChartCard(
          title: 'Monthly visits',
          subtitle: 'Last 6 months',
          child: AppLineChart(points: data.monthlyVisits),
        ),
        ChartCard(
          title: 'Revenue',
          subtitle: '₹ lakh per month',
          child: AppBarChart(
            points: data.revenue,
            color: AppColors.secondary,
          ),
        ),
        ChartCard(
          title: 'Task completion',
          subtitle: 'This month',
          child: AppDonutChart(
            segments: data.taskCompletion,
            centerLabel: 'Tasks',
            colors: const [
              AppColors.success,
              AppColors.primary,
              AppColors.warning,
              AppColors.error,
            ],
          ),
        ),
        ChartCard(
          title: 'Attendance trend',
          subtitle: 'Present % · this week',
          child: AppLineChart(
            points: data.attendanceTrend,
            color: AppColors.success,
            minY: 80,
            maxY: 100,
          ),
        ),
      ],
    );
  }
}