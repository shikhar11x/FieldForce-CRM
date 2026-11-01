import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/api_config.dart';
import '../../../core/network/api_providers.dart';
import '../../../data/models/attendance_models.dart';
import '../../../data/repositories/api_attendance_repository.dart';
import '../../../data/repositories/attendance_repository.dart';
import '../../../data/repositories/mock_attendance_repository.dart';
import '../../auth/providers/auth_provider.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  if (ApiConfig.useMockAuth) return MockAttendanceRepository();
  return ApiAttendanceRepository(ref.watch(apiClientProvider));
});

/// [employee] sirf mock mode ke liye (naam). [employeeId] null = khud ka data.
typedef AttendanceQuery = ({
  String employee,
  String? employeeId,
  int year,
  int month,
});

final attendanceMonthProvider = FutureProvider.autoDispose
    .family<List<AttendanceRecord>, AttendanceQuery>((ref, query) {
  // Account badalne par dobara load ho.
  ref.watch(authProvider.select((s) => s.user?.id));
  return ref.watch(attendanceRepositoryProvider).getMonth(
        employee: query.employee,
        employeeId: query.employeeId,
        year: query.year,
        month: query.month,
      );
});

final teamAttendanceProvider =
    FutureProvider.autoDispose<List<TeamAttendanceEntry>>((ref) {
  ref.watch(authProvider.select((s) => s.user?.id));
  return ref.watch(attendanceRepositoryProvider).getTeamAttendance();
});

/// Replaces today's record with the employee's real check-in state, so the
/// calendar reacts instantly. Only call this for the current month.
List<AttendanceRecord> mergeToday(
  List<AttendanceRecord> records,
  TodayAttendance today,
) {
  final now = DateTime.now();
  final todayDate = DateTime(now.year, now.month, now.day);
  final checkIn = today.checkIn;

  if (checkIn == null) {
    // Not checked in yet: leave today blank (but keep a week-off).
    return [
      for (final r in records)
        if (r.date != todayDate || r.status == AttendanceDayStatus.weekOff) r,
    ];
  }

  final isLate = checkIn.hour * 60 + checkIn.minute > 10 * 60;
  final worked = today.checkOut?.difference(checkIn);
  final status = (worked != null && worked.inMinutes < 4 * 60)
      ? AttendanceDayStatus.halfDay
      : (isLate ? AttendanceDayStatus.lateIn : AttendanceDayStatus.present);

  return [
    for (final r in records)
      if (r.date != todayDate) r,
    AttendanceRecord(
      date: todayDate,
      status: status,
      checkIn: checkIn,
      checkOut: today.checkOut,
    ),
  ];
}

TeamAttendanceEntry? findTeamEntry(
  List<TeamAttendanceEntry> entries,
  String id,
) {
  for (final entry in entries) {
    if (entry.id == id) return entry;
  }
  return null;
}