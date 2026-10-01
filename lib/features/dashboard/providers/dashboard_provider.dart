import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/dashboard_models.dart';
import '../../../data/models/employee_models.dart';
import '../../../data/models/manager_models.dart';
import '../../../data/repositories/dashboard_repository.dart';
import '../../../data/repositories/mock_dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => MockDashboardRepository(),
);

final adminDashboardProvider =
    FutureProvider.autoDispose<AdminDashboardData>((ref) {
  return ref.watch(dashboardRepositoryProvider).getAdminDashboard();
});

final managerDashboardProvider =
    FutureProvider.autoDispose<ManagerDashboardData>((ref) {
  return ref.watch(dashboardRepositoryProvider).getManagerDashboard();
});

final employeeHomeProvider =
    FutureProvider.autoDispose<EmployeeHomeData>((ref) {
  return ref.watch(dashboardRepositoryProvider).getEmployeeHome();
});