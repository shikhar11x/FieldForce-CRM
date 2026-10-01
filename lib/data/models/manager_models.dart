import 'chart_point.dart';
import 'dashboard_models.dart';

enum ManagerKpiKind {
  teamSize,
  activeEmployees,
  todaysVisits,
  pendingTasks,
  completedTasks,
  teamAttendance,
}

class ManagerKpi {
  const ManagerKpi({
    required this.kind,
    required this.label,
    required this.value,
    this.changePercent,
    this.lowerIsBetter = false,
  });

  final ManagerKpiKind kind;
  final String label;
  final String value;
  final double? changePercent;
  final bool lowerIsBetter;
}

class TeamMemberStats {
  const TeamMemberStats({
    required this.id,
    required this.name,
    required this.designation,
    required this.visits,
    required this.tasks,
    required this.completionPercent,
  });

  final String id;
  final String name;
  final String designation;
  final int visits;
  final int tasks;
  final int completionPercent;
}

class ManagerDashboardData {
  const ManagerDashboardData({
    required this.kpis,
    required this.weeklyVisits,
    required this.attendanceBreakdown,
    required this.teamMembers,
    required this.activities,
  });

  final List<ManagerKpi> kpis;
  final List<ChartPoint> weeklyVisits;
  final List<ChartPoint> attendanceBreakdown;
  final List<TeamMemberStats> teamMembers;
  final List<ActivityItem> activities;
}