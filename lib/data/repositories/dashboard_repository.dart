import '../models/dashboard_models.dart';
import '../models/employee_models.dart';
import '../models/manager_models.dart';

/// Phase 2 swaps the mock implementation for an API-backed one.
abstract class DashboardRepository {
  Future<AdminDashboardData> getAdminDashboard();
  Future<ManagerDashboardData> getManagerDashboard();
  Future<EmployeeHomeData> getEmployeeHome();
}