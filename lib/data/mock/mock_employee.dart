import '../models/employee_models.dart';
import '../models/task_enums.dart';

class MockEmployee {
  const MockEmployee._();

  static EmployeeHomeData home() {
    return const EmployeeHomeData(
      tasksToday: 6,
      route: [
        RouteStop(
          id: 'r1',
          customer: 'Metro Hardware',
          address: 'Sector 14 Market Road',
          time: '9:30 AM',
          status: VisitStatus.completed,
          x: 0.05,
          y: 0.72,
        ),
        RouteStop(
          id: 'r2',
          customer: 'Sunrise Traders',
          address: 'Sector 9 Main Bazaar',
          time: '11:00 AM',
          status: VisitStatus.completed,
          x: 0.27,
          y: 0.30,
        ),
        RouteStop(
          id: 'r3',
          customer: 'Greenfield Foods',
          address: 'Industrial Area Phase 2',
          time: '1:30 PM',
          status: VisitStatus.started,
          x: 0.50,
          y: 0.58,
        ),
        RouteStop(
          id: 'r4',
          customer: 'Apex Pharma',
          address: 'Civil Lines Road',
          time: '3:00 PM',
          status: VisitStatus.scheduled,
          x: 0.74,
          y: 0.22,
        ),
        RouteStop(
          id: 'r5',
          customer: 'Bright Electricals',
          address: 'Model Town Chowk',
          time: '4:30 PM',
          status: VisitStatus.scheduled,
          x: 0.95,
          y: 0.62,
        ),
      ],
      upcomingTasks: [
        UpcomingTask(
          id: 't1',
          title: 'Collect signed contract',
          customer: 'Sunrise Traders',
          location: 'Sector 9 Main Bazaar',
          time: '2:00 PM',
          priority: TaskPriority.high,
          status: TaskStatus.pending,
        ),
        UpcomingTask(
          id: 't2',
          title: 'Product demo for new range',
          customer: 'Greenfield Foods',
          location: 'Industrial Area Phase 2',
          time: '3:30 PM',
          priority: TaskPriority.urgent,
          status: TaskStatus.inProgress,
        ),
        UpcomingTask(
          id: 't3',
          title: 'Payment follow-up',
          customer: 'Metro Hardware',
          location: 'Sector 14 Market Road',
          time: '5:00 PM',
          priority: TaskPriority.medium,
          status: TaskStatus.pending,
        ),
        UpcomingTask(
          id: 't4',
          title: 'Deliver product samples',
          customer: 'Apex Pharma',
          location: 'Civil Lines Road',
          time: '6:00 PM',
          priority: TaskPriority.low,
          status: TaskStatus.pending,
        ),
      ],
    );
  }
}