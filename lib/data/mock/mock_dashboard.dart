import '../models/chart_point.dart';
import '../models/dashboard_models.dart';

class MockDashboard {
  const MockDashboard._();

  static AdminDashboardData admin() {
    final now = DateTime.now();

    return AdminDashboardData(
      kpis: const [
        KpiStat(
          kind: KpiKind.totalEmployees,
          label: 'Total Employees',
          value: '128',
          changePercent: 4.2,
        ),
        KpiStat(
          kind: KpiKind.activeEmployees,
          label: 'Active Employees',
          value: '96',
          changePercent: 2.1,
        ),
        KpiStat(
          kind: KpiKind.totalCustomers,
          label: 'Total Customers',
          value: '1,284',
          changePercent: 8.5,
        ),
        KpiStat(
          kind: KpiKind.todaysVisits,
          label: "Today's Visits",
          value: '214',
          changePercent: 12.0,
        ),
        KpiStat(
          kind: KpiKind.pendingTasks,
          label: 'Pending Tasks',
          value: '67',
          changePercent: -5.4,
          lowerIsBetter: true,
        ),
        KpiStat(
          kind: KpiKind.monthlyRevenue,
          label: 'Monthly Revenue',
          value: '₹48.6L',
          changePercent: 14.8,
        ),
      ],
      employeePerformance: const [
        ChartPoint('Rohan', 92),
        ChartPoint('Sneha', 88),
        ChartPoint('Arjun', 84),
        ChartPoint('Kavya', 79),
        ChartPoint('Imran', 74),
        ChartPoint('Neha', 71),
      ],
      monthlyVisits: const [
        ChartPoint('Apr', 820),
        ChartPoint('May', 905),
        ChartPoint('Jun', 870),
        ChartPoint('Jul', 980),
        ChartPoint('Aug', 1040),
        ChartPoint('Sep', 1120),
      ],
      revenue: const [
        ChartPoint('Apr', 32.4),
        ChartPoint('May', 36.8),
        ChartPoint('Jun', 35.1),
        ChartPoint('Jul', 41.2),
        ChartPoint('Aug', 44.9),
        ChartPoint('Sep', 48.6),
      ],
      taskCompletion: const [
        ChartPoint('Completed', 312),
        ChartPoint('In progress', 84),
        ChartPoint('Pending', 67),
        ChartPoint('Overdue', 23),
      ],
      attendanceTrend: const [
        ChartPoint('Mon', 91),
        ChartPoint('Tue', 94),
        ChartPoint('Wed', 92),
        ChartPoint('Thu', 95),
        ChartPoint('Fri', 89),
        ChartPoint('Sat', 86),
      ],
      activities: [
        ActivityItem(
          type: ActivityType.employeeAdded,
          title: 'New employee added',
          subtitle: 'Neha Kapoor joined Field Sales',
          timestamp: now.subtract(const Duration(minutes: 5)),
        ),
        ActivityItem(
          type: ActivityType.customerCreated,
          title: 'Customer created',
          subtitle: 'Sunrise Traders added by Arjun Nair',
          timestamp: now.subtract(const Duration(minutes: 22)),
        ),
        ActivityItem(
          type: ActivityType.visitCompleted,
          title: 'Visit completed',
          subtitle: 'Rohan Verma at Metro Hardware',
          timestamp: now.subtract(const Duration(minutes: 48)),
        ),
        ActivityItem(
          type: ActivityType.taskAssigned,
          title: 'Task assigned',
          subtitle: 'Follow-up call assigned to Kavya Iyer',
          timestamp: now.subtract(const Duration(hours: 2)),
        ),
        ActivityItem(
          type: ActivityType.leadConverted,
          title: 'Lead converted',
          subtitle: 'Greenfield Foods moved to Won · ₹3.2L',
          timestamp: now.subtract(const Duration(hours: 5)),
        ),
      ],
    );
  }
}