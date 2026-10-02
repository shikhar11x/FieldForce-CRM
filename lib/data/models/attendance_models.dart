enum AttendanceDayStatus {
  present('Present'),
  lateIn('Late'),
  halfDay('Half day'),
  absent('Absent'),
  weekOff('Week off');

  const AttendanceDayStatus(this.label);
  final String label;
}

class AttendanceRecord {
  const AttendanceRecord({
    required this.date,
    required this.status,
    this.checkIn,
    this.checkOut,
  });

  /// Date only (midnight, local time).
  final DateTime date;
  final AttendanceDayStatus status;
  final DateTime? checkIn;
  final DateTime? checkOut;

  Duration? get worked {
    final start = checkIn;
    final end = checkOut;
    if (start == null || end == null) return null;
    return end.difference(start);
  }
}

class AttendanceSummary {
  const AttendanceSummary({
    required this.presentDays,
    required this.lateDays,
    required this.halfDays,
    required this.absentDays,
    required this.totalWorked,
  });

  factory AttendanceSummary.fromRecords(List<AttendanceRecord> records) {
    var present = 0;
    var lateIn = 0;
    var half = 0;
    var absent = 0;
    var worked = Duration.zero;

    for (final r in records) {
      switch (r.status) {
        case AttendanceDayStatus.present:
          present++;
        case AttendanceDayStatus.lateIn:
          lateIn++;
        case AttendanceDayStatus.halfDay:
          half++;
        case AttendanceDayStatus.absent:
          absent++;
        case AttendanceDayStatus.weekOff:
          break;
      }
      worked += r.worked ?? Duration.zero;
    }

    return AttendanceSummary(
      presentDays: present,
      lateDays: lateIn,
      halfDays: half,
      absentDays: absent,
      totalWorked: worked,
    );
  }

  final int presentDays;
  final int lateDays;
  final int halfDays;
  final int absentDays;
  final Duration totalWorked;

  int get workingDays => presentDays + lateDays + halfDays + absentDays;

  /// Late counts as attended, half day as 0.5.
  double get percent => workingDays == 0
      ? 0
      : (presentDays + lateDays + halfDays * 0.5) / workingDays * 100;
}

class TeamAttendanceEntry {
  const TeamAttendanceEntry({
    required this.id,
    required this.name,
    required this.designation,
    required this.today,
    required this.summary,
  });

  final String id;
  final String name;
  final String designation;
  final AttendanceRecord? today;

  /// Summary of the current month.
  final AttendanceSummary summary;
}