import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/adaptive_wrap.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../data/models/dashboard_models.dart';
import 'dashboard_layout.dart';

class KpiGrid extends StatelessWidget {
  const KpiGrid({super.key, required this.kpis});

  final List<KpiStat> kpis;

  (IconData, Color) _styleFor(KpiKind kind) => switch (kind) {
        KpiKind.totalEmployees => (Icons.groups_rounded, AppColors.primary),
        KpiKind.activeEmployees =>
          (Icons.how_to_reg_rounded, AppColors.success),
        KpiKind.totalCustomers =>
          (Icons.business_center_rounded, AppColors.secondary),
        KpiKind.todaysVisits => (Icons.place_rounded, AppColors.info),
        KpiKind.pendingTasks =>
          (Icons.pending_actions_rounded, AppColors.warning),
        KpiKind.monthlyRevenue =>
          (Icons.account_balance_wallet_rounded, AppColors.accent),
      };

  @override
  Widget build(BuildContext context) {
    return AdaptiveWrap(
      columns: DashboardLayout.kpiColumns,
      children: [
        for (final kpi in kpis)
          StatCard(
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