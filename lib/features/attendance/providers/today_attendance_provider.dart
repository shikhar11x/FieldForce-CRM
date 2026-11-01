import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/api_config.dart';
import '../../../core/location/device_location.dart';
import '../../../data/models/attendance_models.dart';
import '../../../data/models/user_role.dart';
import '../../auth/providers/auth_provider.dart';
import 'attendance_provider.dart';

// Purane imports (`AttendanceStatus`, `TodayAttendance`) isi file se chalte rahein.
export '../../../data/models/attendance_models.dart'
    show AttendanceStatus, TodayAttendance;

/// Employee ka aaj ka status. Server se load hota hai, aur check-in /
/// check-out server pe hote hain (GPS ke saath). Logout ya account badalne
/// par reset ho jaata hai.
class TodayAttendanceNotifier extends Notifier<TodayAttendance> {
  @override
  TodayAttendance build() {
    final who = ref.watch(
      authProvider.select((s) => (s.user?.id, s.user?.role)),
    );
    if (who.$1 != null && who.$2 == UserRole.employee) {
      Future<void>.microtask(_load);
    }
    return const TodayAttendance();
  }

  Future<void> _load() async {
    try {
      final today = await ref.read(attendanceRepositoryProvider).getToday();
      if (ref.mounted) state = today;
    } catch (_) {
      // Load fail ho to card "not checked in" dikhata hai; action pe server sahi batata hai.
    }
  }

  Future<DeviceFix> _fix() async {
    if (ApiConfig.useMockAuth) {
      return const DeviceFix(
        latitude: 0,
        longitude: 0,
        accuracyMeters: 0,
      );
    }
    return getDeviceFix();
  }

  /// Throws [LocationException] ya ApiException. UI unhe dikhata hai.
  Future<void> checkIn() async {
    final fix = await _fix();
    final saved = await ref.read(attendanceRepositoryProvider).checkIn(fix);
    state = saved;
    ref.invalidate(attendanceMonthProvider);
  }

  Future<void> checkOut() async {
    final fix = await _fix();
    final saved = await ref.read(attendanceRepositoryProvider).checkOut(fix);
    state = saved;
    ref.invalidate(attendanceMonthProvider);
  }
}

final todayAttendanceProvider =
    NotifierProvider<TodayAttendanceNotifier, TodayAttendance>(
  TodayAttendanceNotifier.new,
);

/// Check-in / out chal raha hai (double tap se bachne ke liye).
class AttendanceBusyNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final attendanceBusyProvider =
    NotifierProvider<AttendanceBusyNotifier, bool>(AttendanceBusyNotifier.new);