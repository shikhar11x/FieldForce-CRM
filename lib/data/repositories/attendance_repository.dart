import '../models/attendance_models.dart';

/// Phase 2 swaps the mock implementation for an API-backed one.
abstract class AttendanceRepository {
  Future<List<AttendanceRecord>> getMonth({
    required String employee,
    required int year,
    required int month,
  });

  Future<List<TeamAttendanceEntry>> getTeamAttendance();
}