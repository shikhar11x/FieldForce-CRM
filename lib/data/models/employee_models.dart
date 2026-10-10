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

class EmployeeHomeData {
  const EmployeeHomeData({required this.route});

  final List<RouteStop> route;

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