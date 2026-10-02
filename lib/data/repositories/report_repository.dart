import '../models/report_models.dart';

/// Phase 2 swaps the mock implementation for an API-backed one.
abstract class ReportRepository {
  Future<ReportFilterOptions> getFilterOptions();
  Future<SalesReport> getSalesReport(ReportQuery query);
  Future<EmployeeReport> getEmployeeReport(ReportQuery query);
  Future<CustomerReport> getCustomerReport(ReportQuery query);
  Future<AttendanceReport> getAttendanceReport(ReportQuery query);
}