import 'task_enums.dart';

class RouteStop {
  const RouteStop({
    required this.id,
    required this.customer,
    required this.address,
    required this.time,
    required this.status,
    required this.x,
    required this.y,
  });

  final String id;
  final String customer;
  final String address;
  final String time;
  final VisitStatus status;

  /// Normalised 0..1 position used by the mock map preview.
  final double x;
  final double y;
}

class UpcomingTask {
  const UpcomingTask({
    required this.id,
    required this.title,
    required this.customer,
    required this.location,
    required this.time,
    required this.priority,
    required this.status,
  });

  final String id;
  final String title;
  final String customer;
  final String location;
  final String time;
  final TaskPriority priority;
  final TaskStatus status;
}

class EmployeeHomeData {
  const EmployeeHomeData({
    required this.tasksToday,
    required this.route,
    required this.upcomingTasks,
  });

  final int tasksToday;
  final List<RouteStop> route;
  final List<UpcomingTask> upcomingTasks;

  int get visitsToday => route.length;

  int get completedVisits =>
      route.where((s) => s.status == VisitStatus.completed).length;

  int get pendingVisits => route
      .where(
        (s) =>
            s.status == VisitStatus.scheduled ||
            s.status == VisitStatus.started,
      )
      .length;
}