import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/report_models.dart';
import '../../../data/repositories/mock_report_repository.dart';
import '../../../data/repositories/report_repository.dart';

final reportRepositoryProvider = Provider<ReportRepository>(
  (ref) => MockReportRepository(),
);

final reportFilterOptionsProvider = FutureProvider<ReportFilterOptions>((ref) {
  return ref.watch(reportRepositoryProvider).getFilterOptions();
});

// Not autoDispose on purpose: each filter combination stays cached for the
// session, so switching report tabs doesn't reload.
final salesReportProvider =
    FutureProvider.family<SalesReport, ReportQuery>((ref, query) {
  return ref.watch(reportRepositoryProvider).getSalesReport(query);
});

final employeeReportProvider =
    FutureProvider.family<EmployeeReport, ReportQuery>((ref, query) {
  return ref.watch(reportRepositoryProvider).getEmployeeReport(query);
});

final customerReportProvider =
    FutureProvider.family<CustomerReport, ReportQuery>((ref, query) {
  return ref.watch(reportRepositoryProvider).getCustomerReport(query);
});

final attendanceReportProvider =
    FutureProvider.family<AttendanceReport, ReportQuery>((ref, query) {
  return ref.watch(reportRepositoryProvider).getAttendanceReport(query);
});