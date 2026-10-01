import 'chart_point.dart';

enum KpiKind {
  totalEmployees,
  activeEmployees,
  totalCustomers,
  todaysVisits,
  pendingTasks,
  monthlyRevenue,
}

class KpiStat {
  const KpiStat({
    required this.kind,
    required this.label,
    required this.value,
    required this.changePercent,
    this.lowerIsBetter = false,
  });

  final KpiKind  kind;
  final String label;
  final String value;
  final double changePercent;

  /// When true, a decrease is shown as a positive trend (e.g. pending tasks).
  final bool lowerIsBetter;
}

enum ActivityType {
  employeeAdded,
  customerCreated,
  visitCompleted,
  taskAssigned,
  leadConverted,
}

class ActivityItem {
  const ActivityItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timestamp,
  });

  final ActivityType type;
  final String title;
  final String subtitle;
  final DateTime timestamp;
}

class AdminDashboardData {
  const AdminDashboardData({
    required this.kpis,
    required this.employeePerformance,
    required this.monthlyVisits,
    required this.revenue,
    required this.taskCompletion,
    required this.attendanceTrend,
    required this.activities,
  });

  final List<KpiStat> kpis;
  final List<ChartPoint> employeePerformance;
  final List<ChartPoint> monthlyVisits;
  final List<ChartPoint> revenue;
  final List<ChartPoint> taskCompletion;
  final List<ChartPoint> attendanceTrend;
  final List<ActivityItem> activities;
}