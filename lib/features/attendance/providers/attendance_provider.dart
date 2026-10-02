import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/attendance_models.dart';
import '../../../data/repositories/attendance_repository.dart';
import '../../../data/repositories/mock_attendance_repository.dart';
import 'today_attendance_provider.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>(
  (ref) => MockAttendanceRepository(),
);

typedef AttendanceQuery = ({String employee, int year, int month});

final attendanceMonthProvider = FutureProvider.autoDispose
    .family<List<AttendanceRecord>, AttendanceQuery>((ref, query) {
  return ref.watch(attendanceRepositoryProvider).getMonth(
        employee: query.employee,
        year: query.year,
        month: query.month,
      );
});

final teamAttendanceProvider =
    FutureProvider.autoDispose<List<TeamAttendanceEntry>>((ref) {
  return ref.watch(attendanceRepositoryProvider).getTeamAttendance();
});

/// Replaces today's generated record with the employee's real check-in
/// state. Only call this for the current month.
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
  return [
    for (final r in records)
      if (r.date != todayDate) r,
    AttendanceRecord(
      date: todayDate,
      status:
          isLate ? AttendanceDayStatus.lateIn : AttendanceDayStatus.present,
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