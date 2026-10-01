import '../mock/mock_dashboard.dart';
import '../mock/mock_employee.dart';
import '../mock/mock_manager.dart';
import '../models/dashboard_models.dart';
import '../models/employee_models.dart';
import '../models/manager_models.dart';
import 'dashboard_repository.dart';

class MockDashboardRepository implements DashboardRepository {
  // Simulated latency so loading skeletons are visible.
  Future<void> _latency() =>
      Future<void>.delayed(const Duration(milliseconds: 1200));

  @override
  Future<AdminDashboardData> getAdminDashboard() async {
    await _latency();
    return MockDashboard.admin();
  }

  @override
  Future<ManagerDashboardData> getManagerDashboard() async {
    await _latency();
    return MockManager.dashboard();
  }

  @override
  Future<EmployeeHomeData> getEmployeeHome() async {
    await _latency();
    return MockEmployee.home();
  }
}