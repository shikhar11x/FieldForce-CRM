import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/stat_grid.dart';
import '../../../data/models/manager_models.dart';
import 'dashboard_layout.dart';

class TeamKpiGrid extends StatelessWidget {
  const TeamKpiGrid({super.key, required this.kpis});

  final List<ManagerKpi> kpis;

  (IconData, Color) _styleFor(ManagerKpiKind kind) => switch (kind) {
        ManagerKpiKind.teamSize => (Icons.groups_rounded, AppColors.primary),
        ManagerKpiKind.activeEmployees =>
          (Icons.directions_walk_rounded, AppColors.success),
        ManagerKpiKind.todaysVisits => (Icons.place_rounded, AppColors.info),
        ManagerKpiKind.pendingTasks =>
          (Icons.pending_actions_rounded, AppColors.warning),
        ManagerKpiKind.completedTasks =>
          (Icons.task_alt_rounded, AppColors.secondary),
        ManagerKpiKind.teamAttendance =>
          (Icons.event_available_rounded, AppColors.accent),
      };

  @override
  Widget build(BuildContext context) {
    return StatGrid(
      columns: DashboardLayout.kpiColumns,
      items: [
        for (final kpi in kpis)
          StatGridItem(
            label: kpi.label,
            value: kpi.value,
            icon: _styleFor(kpi.kind).$1,
            color: _styleFor(kpi.kind).$2,
            changePercent: kpi.changePercent,
            lowerIsBetter: kpi.lowerIsBetter,
          ),
      ],
    );
  }
}