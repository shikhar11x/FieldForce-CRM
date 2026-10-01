import '../models/chart_point.dart';
import '../models/dashboard_models.dart';
import '../models/manager_models.dart';

class MockManager {
  const MockManager._();

  static ManagerDashboardData dashboard() {
    final now = DateTime.now();

    return ManagerDashboardData(
      kpis: const [
        ManagerKpi(
          kind: ManagerKpiKind.teamSize,
          label: 'Team Members',
          value: '24',
        ),
        ManagerKpi(
          kind: ManagerKpiKind.activeEmployees,
          label: 'Active in Field',
          value: '21',
          changePercent: 3.4,
        ),
        ManagerKpi(
          kind: ManagerKpiKind.todaysVisits,
          label: "Today's Visits",
          value: '63',
          changePercent: 6.8,
        ),
        ManagerKpi(
          kind: ManagerKpiKind.pendingTasks,
          label: 'Pending Tasks',
          value: '17',
          changePercent: -12.0,
          lowerIsBetter: true,
        ),
        ManagerKpi(
          kind: ManagerKpiKind.completedTasks,
          label: 'Completed Tasks',
          value: '58',
          changePercent: 9.3,
        ),
        ManagerKpi(
          kind: ManagerKpiKind.teamAttendance,
          label: 'Team Attendance',
          value: '92%',
          changePercent: 1.5,
        ),
      ],
      weeklyVisits: const [
        ChartPoint('Mon', 34),
        ChartPoint('Tue', 41),
        ChartPoint('Wed', 38),
        ChartPoint('Thu', 46),
        ChartPoint('Fri', 43),
        ChartPoint('Sat', 29),
      ],
      attendanceBreakdown: const [
        ChartPoint('Present', 19),
        ChartPoint('Late', 3),
        ChartPoint('Half day', 1),
        ChartPoint('Absent', 1),
      ],
      teamMembers: const [
        TeamMemberStats(
          id: 'e1',
          name: 'Rohan Verma',
          designation: 'Senior Sales Executive',
          visits: 38,
          tasks: 24,
          completionPercent: 92,
        ),
        TeamMemberStats(
          id: 'e2',
          name: 'Sneha Reddy',
          designation: 'Sales Executive',
          visits: 34,
          tasks: 21,
          completionPercent: 88,
        ),
        TeamMemberStats(
          id: 'e3',
          name: 'Arjun Nair',
          designation: 'Service Agent',
          visits: 29,
          tasks: 19,
          completionPercent: 81,
        ),
        TeamMemberStats(
          id: 'e4',
          name: 'Kavya Iyer',
          designation: 'Sales Executive',
          visits: 26,
          tasks: 17,
          completionPercent: 76,
        ),
        TeamMemberStats(
          id: 'e5',
          name: 'Imran Khan',
          designation: 'Service Agent',
          visits: 21,
          tasks: 15,
          completionPercent: 68,
        ),
        TeamMemberStats(
          id: 'e6',
          name: 'Neha Kapoor',
          designation: 'Field Executive',
          visits: 17,
          tasks: 12,
          completionPercent: 61,
        ),
      ],
      activities: [
        ActivityItem(
          type: ActivityType.visitCompleted,
          title: 'Visit completed',
          subtitle: 'Rohan Verma at Metro Hardware',
          timestamp: now.subtract(const Duration(minutes: 12)),
        ),
        ActivityItem(
          type: ActivityType.leadConverted,
          title: 'Lead converted',
          subtitle: 'Sneha Reddy won Greenfield Foods · ₹3.2L',
          timestamp: now.subtract(const Duration(minutes: 40)),
        ),
        ActivityItem(
          type: ActivityType.taskAssigned,
          title: 'Task assigned',
          subtitle: 'Payment follow-up assigned to Imran Khan',
          timestamp: now.subtract(const Duration(hours: 1, minutes: 30)),
        ),
        ActivityItem(
          type: ActivityType.customerCreated,
          title: 'Customer created',
          subtitle: 'Sunrise Traders added by Arjun Nair',
          timestamp: now.subtract(const Duration(hours: 3)),
        ),
      ],
    );
  }
}