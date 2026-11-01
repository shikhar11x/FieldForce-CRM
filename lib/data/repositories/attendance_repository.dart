import '../../core/location/device_location.dart';
import '../models/attendance_models.dart';

abstract class AttendanceRepository {
  Future<TodayAttendance> getToday();
  Future<TodayAttendance> checkIn(DeviceFix fix);
  Future<TodayAttendance> checkOut(DeviceFix fix);

  /// [employeeId] null = logged-in employee khud. Manager / admin ke liye
  /// zaroori. [employee] (naam) sirf mock mode me kaam aata hai.
  Future<List<AttendanceRecord>> getMonth({
    required String employee,
    String? employeeId,
    required int year,
    required int month,
  });

  Future<List<TeamAttendanceEntry>> getTeamAttendance();
}