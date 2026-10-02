import '../mock/mock_reports.dart';
import '../models/report_models.dart';
import 'report_repository.dart';

class MockReportRepository implements ReportRepository {
  // Simulated latency so loading skeletons are visible.
  Future<void> _latency() =>
      Future<void>.delayed(const Duration(milliseconds: 700));

  @override
  Future<ReportFilterOptions> getFilterOptions() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return MockReports.filterOptions();
  }

  @override
  Future<SalesReport> getSalesReport(ReportQuery query) async {
    await _latency();
    return MockReports.sales(query);
  }

  @override
  Future<EmployeeReport> getEmployeeReport(ReportQuery query) async {
    await _latency();
    return MockReports.employees(query);
  }

  @override
  Future<CustomerReport> getCustomerReport(ReportQuery query) async {
    await _latency();
    return MockReports.customers(query);
  }

  @override
  Future<AttendanceReport> getAttendanceReport(ReportQuery query) async {
    await _latency();
    return MockReports.attendance(query);
  }
}