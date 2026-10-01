import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/adaptive_wrap.dart';
import '../../../core/widgets/chart_card.dart';
import '../../../core/widgets/charts/app_bar_chart.dart';
import '../../../core/widgets/charts/app_donut_chart.dart';
import '../../../data/models/manager_models.dart';
import 'dashboard_layout.dart';

class TeamAnalyticsSection extends StatelessWidget {
  const TeamAnalyticsSection({super.key, required this.data});

  final ManagerDashboardData data;

  @override
  Widget build(BuildContext context) {
    return AdaptiveWrap(
      columns: DashboardLayout.chartColumns,
      children: [
        ChartCard(
          title: 'Team performance',
          subtitle: 'Visits completed · this week',
          child: AppBarChart(points: data.weeklyVisits),
        ),
        ChartCard(
          title: 'Team attendance',
          subtitle: 'Today',
          child: AppDonutChart(
            segments: data.attendanceBreakdown,
            centerLabel: 'Members',
            colors: const [
              AppColors.success,
              AppColors.warning,
              AppColors.info,
              AppColors.error,
            ],
          ),
        ),
      ],
    );
  }
}