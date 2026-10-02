import '../models/attendance_models.dart';

class MockAttendance {
  const MockAttendance._();

  static const List<({String id, String name, String designation})> members = [
    (id: 'e1', name: 'Rohan Verma', designation: 'Senior Sales Executive'),
    (id: 'e2', name: 'Sneha Reddy', designation: 'Sales Executive'),
    (id: 'e3', name: 'Arjun Nair', designation: 'Service Agent'),
    (id: 'e4', name: 'Kavya Iyer', designation: 'Sales Executive'),
    (id: 'e5', name: 'Imran Khan', designation: 'Service Agent'),
    (id: 'e6', name: 'Neha Kapoor', designation: 'Field Executive'),
  ];

  /// Deterministic records from day 1 up to today (or the whole month if
  /// it is in the past). Sundays are week-offs.
  static List<AttendanceRecord> month(String employee, int year, int month) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final seed = employee.codeUnits.fold<int>(0, (sum, c) => sum + c);
    final records = <AttendanceRecord>[];

    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      if (date.isAfter(today)) break;

      if (date.weekday == DateTime.sunday) {
        records.add(
          AttendanceRecord(date: date, status: AttendanceDayStatus.weekOff),
        );
        continue;
      }

      final isToday = date == today;
      var roll = (seed + day * 7 + month * 3) % 20;
      // Today is still in progress, so it is never absent or half day.
      if (isToday && (roll == 0 || roll == 3)) roll = 5;

      final jitter = (seed + day * 11) % 30;
      DateTime at(int hour, int minute) =>
          DateTime(year, month, day, hour, minute);

      final AttendanceRecord record;
      if (roll == 0) {
        record = AttendanceRecord(
          date: date,
          status: AttendanceDayStatus.absent,
        );
      } else if (roll <= 2) {
        record = AttendanceRecord(
          date: date,
          status: AttendanceDayStatus.lateIn,
          checkIn: at(10, 15 + jitter % 30),
          checkOut: isToday ? null : at(18, 30 + jitter % 25),
        );
      } else if (roll == 3) {
        record = AttendanceRecord(
          date: date,
          status: AttendanceDayStatus.halfDay,
          checkIn: at(9, 30),
          checkOut: isToday ? null : at(13, 30),
        );
      } else {
        record = AttendanceRecord(
          date: date,
          status: AttendanceDayStatus.present,
          checkIn: at(9, jitter),
          checkOut: isToday ? null : at(18, (seed + day * 5) % 40),
        );
      }
      records.add(record);
    }
    return records;
  }

  static List<TeamAttendanceEntry> team() {
    final now = DateTime.now();
    final entries = <TeamAttendanceEntry>[];

    for (final m in members) {
      final records = month(m.name, now.year, now.month);
      entries.add(
        TeamAttendanceEntry(
          id: m.id,
          name: m.name,
          designation: m.designation,
          today: records.isEmpty ? null : records.last,
          summary: AttendanceSummary.fromRecords(records),
        ),
      );
    }
    return entries;
  }
}