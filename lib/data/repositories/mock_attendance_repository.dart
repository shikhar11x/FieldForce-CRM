import '../../core/location/device_location.dart';
import '../../core/network/api_exception.dart';
import '../mock/mock_attendance.dart';
import '../models/attendance_models.dart';
import 'attendance_repository.dart';

class MockAttendanceRepository implements AttendanceRepository {
  TodayAttendance _today = const TodayAttendance();

  @override
  Future<TodayAttendance> getToday() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _today;
  }

  @override
  Future<TodayAttendance> checkIn(DeviceFix fix) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (_today.status != AttendanceStatus.notCheckedIn) {
      throw const ApiException('You have already checked in today.');
    }
    return _today = TodayAttendance(
      status: AttendanceStatus.checkedIn,
      checkIn: DateTime.now(),
    );
  }

  @override
  Future<TodayAttendance> checkOut(DeviceFix fix) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (_today.status != AttendanceStatus.checkedIn) {
      throw const ApiException('Check in before checking out.');
    }
    return _today = TodayAttendance(
      status: AttendanceStatus.checkedOut,
      checkIn: _today.checkIn,
      checkOut: DateTime.now(),
    );
  }

  @override
  Future<List<AttendanceRecord>> getMonth({
    required String employee,
    String? employeeId,
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