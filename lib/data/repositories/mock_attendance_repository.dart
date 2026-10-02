import '../mock/mock_attendance.dart';
import '../models/attendance_models.dart';
import 'attendance_repository.dart';

class MockAttendanceRepository implements AttendanceRepository {
  @override
  Future<List<AttendanceRecord>> getMonth({
    required String employee,
    required int year,
    required int month,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return MockAttendance.month(employee, year, month);
  }

  @override
  Future<List<TeamAttendanceEntry>> getTeamAttendance() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return MockAttendance.team();
  }
}