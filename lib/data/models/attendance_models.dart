enum AttendanceDayStatus {
  present('Present', 'PRESENT'),
  lateIn('Late', 'LATE'),
  halfDay('Half day', 'HALF_DAY'),
  absent('Absent', 'ABSENT'),
  weekOff('Week off', 'WEEK_OFF');

  const AttendanceDayStatus(this.label, this.apiValue);
  final String label;
  final String apiValue;

  static AttendanceDayStatus fromApi(String value) =>
      AttendanceDayStatus.values.firstWhere(
        (s) => s.apiValue == value,
        orElse: () => AttendanceDayStatus.absent,
      );
}

DateTime? _parseTime(Object? value) =>
    value is String ? DateTime.parse(value).toLocal() : null;

class AttendanceRecord {
  const AttendanceRecord({
    required this.date,
    required this.status,
    this.checkIn,
    this.checkOut,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      // 'YYYY-MM-DD' local midnight ban jaata hai.
      date: DateTime.parse(json['date'] as String),
      status: AttendanceDayStatus.fromApi(json['status'] as String),
      checkIn: _parseTime(json['checkIn']),
      checkOut: _parseTime(json['checkOut']),
    );
  }

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

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    int n(String key) => (json[key] as num).toInt();
    return AttendanceSummary(
      presentDays: n('presentDays'),
      lateDays: n('lateDays'),
      halfDays: n('halfDays'),
      absentDays: n('absentDays'),
      totalWorked: Duration(minutes: n('workedMinutes')),
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

  factory TeamAttendanceEntry.fromJson(Map<String, dynamic> json) {
    final today = json['today'];
    return TeamAttendanceEntry(
      id: json['id'] as String,
      name: json['name'] as String,
      designation: json['designation'] as String,
      today: today == null
          ? null
          : AttendanceRecord.fromJson(today as Map<String, dynamic>),
      summary:
          AttendanceSummary.fromJson(json['summary'] as Map<String, dynamic>),
    );
  }

  final String id;
  final String name;
  final String designation;
  final AttendanceRecord? today;

  /// Summary of the current month.
  final AttendanceSummary summary;
}

enum AttendanceStatus { notCheckedIn, checkedIn, checkedOut }

/// Employee ka aaj ka check-in / check-out.
class TodayAttendance {
  const TodayAttendance({
    this.status = AttendanceStatus.notCheckedIn,
    this.checkIn,
    this.checkOut,
  });

  factory TodayAttendance.fromJson(Map<String, dynamic> json) {
    final checkIn = _parseTime(json['checkIn']);
    final checkOut = _parseTime(json['checkOut']);
    return TodayAttendance(
      status: checkOut != null
          ? AttendanceStatus.checkedOut
          : (checkIn != null
              ? AttendanceStatus.checkedIn
              : AttendanceStatus.notCheckedIn),
      checkIn: checkIn,
      checkOut: checkOut,
    );
  }

  final AttendanceStatus status;
  final DateTime? checkIn;
  final DateTime? checkOut;

  Duration get workedDuration {
    final start = checkIn;
    if (start == null) return Duration.zero;
    return (checkOut ?? DateTime.now()).difference(start);
  }
}