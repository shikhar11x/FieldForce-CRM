import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AttendanceStatus { notCheckedIn, checkedIn, checkedOut }

class TodayAttendance {
  const TodayAttendance({
    this.status = AttendanceStatus.notCheckedIn,
    this.checkIn,
    this.checkOut,
  });

  final AttendanceStatus status;
  final DateTime? checkIn;
  final DateTime? checkOut;

  Duration get workedDuration {
    final start = checkIn;
    if (start == null) return Duration.zero;
    return (checkOut ?? DateTime.now()).difference(start);
  }
}

/// Local-only state for Phase 1. Phase 2 backs this with the attendance API.
class TodayAttendanceNotifier extends Notifier<TodayAttendance> {
  @override
  TodayAttendance build() => const TodayAttendance();

  void checkIn() {
    if (state.status != AttendanceStatus.notCheckedIn) return;
    state = TodayAttendance(
      status: AttendanceStatus.checkedIn,
      checkIn: DateTime.now(),
    );
  }

  void checkOut() {
    if (state.status != AttendanceStatus.checkedIn) return;
    state = TodayAttendance(
      status: AttendanceStatus.checkedOut,
      checkIn: state.checkIn,
      checkOut: DateTime.now(),
    );
  }
}

final todayAttendanceProvider =
    NotifierProvider<TodayAttendanceNotifier, TodayAttendance>(
  TodayAttendanceNotifier.new,
);