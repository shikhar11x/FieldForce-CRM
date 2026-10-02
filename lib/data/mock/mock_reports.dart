import 'dart:math' as math;

import '../models/chart_point.dart';
import '../models/report_models.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

class _Person {
  const _Person({
    required this.name,
    required this.team,
    required this.visitsPerDay,
    required this.tasksPerDay,
    required this.performance,
    required this.revenueLakhPerDay,
    required this.leadsPerDay,
    required this.conversion,
    required this.gapPercent,
    required this.activeCustomers,
    required this.inactiveCustomers,
    required this.newCustomersPerDay,
  });

  final String name;
  final String team;
  final double visitsPerDay;
  final double tasksPerDay;
  final int performance;
  final double revenueLakhPerDay;
  final double leadsPerDay;
  final double conversion;

  /// Share of working days that are not a clean "present".
  final double gapPercent;
  final int activeCustomers;
  final int inactiveCustomers;
  final double newCustomersPerDay;
}

typedef _Split = ({int present, int lateIn, int half, int absent});

/// Deterministic report numbers generated from the selected filters, so
/// every filter change visibly changes the data.
class MockReports {
  const MockReports._();

  static const _people = [
    _Person(
      name: 'Rohan Verma',
      team: 'Sales North',
      visitsPerDay: 5.2,
      tasksPerDay: 3.4,
      performance: 92,
      revenueLakhPerDay: 0.38,
      leadsPerDay: 0.7,
      conversion: 0.34,
      gapPercent: 4,
      activeCustomers: 38,
      inactiveCustomers: 5,
      newCustomersPerDay: 0.22,
    ),
    _Person(
      name: 'Sneha Reddy',
      team: 'Sales South',
      visitsPerDay: 4.8,
      tasksPerDay: 3.1,
      performance: 88,
      revenueLakhPerDay: 0.34,
      leadsPerDay: 0.6,
      conversion: 0.32,
      gapPercent: 6,
      activeCustomers: 31,
      inactiveCustomers: 4,
      newCustomersPerDay: 0.18,
    ),
    _Person(
      name: 'Arjun Nair',
      team: 'Service',
      visitsPerDay: 4.1,
      tasksPerDay: 2.8,
      performance: 81,
      revenueLakhPerDay: 0.20,
      leadsPerDay: 0.4,
      conversion: 0.28,
      gapPercent: 8,
      activeCustomers: 26,
      inactiveCustomers: 6,
      newCustomersPerDay: 0.12,
    ),
    _Person(
      name: 'Kavya Iyer',
      team: 'Sales South',
      visitsPerDay: 3.7,
      tasksPerDay: 2.4,
      performance: 76,
      revenueLakhPerDay: 0.26,
      leadsPerDay: 0.5,
      conversion: 0.26,
      gapPercent: 10,
      activeCustomers: 29,
      inactiveCustomers: 3,
      newCustomersPerDay: 0.15,
    ),
    _Person(
      name: 'Imran Khan',
      team: 'Service',
      visitsPerDay: 3.0,
      tasksPerDay: 2.1,
      performance: 68,
      revenueLakhPerDay: 0.15,
      leadsPerDay: 0.3,
      conversion: 0.22,
      gapPercent: 14,
      activeCustomers: 18,
      inactiveCustomers: 7,
      newCustomersPerDay: 0.10,
    ),
    _Person(
      name: 'Neha Kapoor',
      team: 'Sales North',
      visitsPerDay: 2.5,
      tasksPerDay: 1.8,
      performance: 61,
      revenueLakhPerDay: 0.27,
      leadsPerDay: 0.45,
      conversion: 0.30,
      gapPercent: 16,
      activeCustomers: 24,
      inactiveCustomers: 2,
      newCustomersPerDay: 0.13,
    ),
  ];

  static const _targetLakhPerPersonPerDay = 0.29;
  static const _wave = [0.85, 1.0, 1.15, 0.95, 1.2, 1.05];
  static const _attendanceWave = [-2.0, 1.0, 2.0, -1.0, 0.0, 1.5];

  static const _topCustomers = [
    ('Metro Hardware', 0.22),
    ('Greenfield Foods', 0.18),
    ('Sunrise Traders', 0.15),
    ('Apex Pharma', 0.13),
    ('Ocean Logistics', 0.11),
    ('Bright Electricals', 0.09),
  ];

  // ------------------------------------------------------------ helpers

  static ReportFilterOptions filterOptions() {
    return ReportFilterOptions(
      teams: const ['Sales North', 'Sales South', 'Service'],
      employeeTeams: {for (final p in _people) p.name: p.team},
    );
  }

  static List<_Person> _select(ReportQuery q) => [
        for (final p in _people)
          if ((q.team == null || p.team == q.team) &&
              (q.employee == null || p.name == q.employee))
            p,
      ];

  /// Inclusive number of days, computed in UTC to ignore DST shifts.
  static int _days(ReportQuery q) {
    final start = DateTime.utc(q.start.year, q.start.month, q.start.day);
    final end = DateTime.utc(q.end.year, q.end.month, q.end.day);
    return math.max(1, end.difference(start).inDays + 1);
  }

  static int _workingDays(int days) => math.max(1, (days * 6 / 7).round());

  static int _buckets(int days) => math.min(6, math.max(2, days));

  static double _round(double value, int decimals) {
    final factor = math.pow(10, decimals);
    return (value * factor).round() / factor;
  }

  static String _label(DateTime start, int offset) {
    final d = DateTime(start.year, start.month, start.day + offset);
    return '${d.day} ${_months[d.month - 1]}';
  }

  static List<String> _labels(ReportQuery q) {
    final days = _days(q);
    final n = _buckets(days);
    return [
      for (var i = 0; i < n; i++) _label(q.start, (days * i / n).floor()),
    ];
  }

  /// Splits [total] across the period buckets with a gentle wave, so the
  /// buckets add up to the total.
  static List<ChartPoint> _spread(
    ReportQuery q,
    double total, {
    int decimals = 1,
  }) {
    final labels = _labels(q);
    final weights = [
      for (var i = 0; i < labels.length; i++) _wave[i % _wave.length],
    ];
    final sum = weights.fold<double>(0, (a, b) => a + b);
    return [
      for (var i = 0; i < labels.length; i++)
        ChartPoint(labels[i], _round(total * weights[i] / sum, decimals)),
    ];
  }

  static _Split _split(_Person p, int working) {
    final gap = working * p.gapPercent / 100;
    final absent = (gap * 0.4).round();
    final half = (gap * 0.3).round();
    final lateIn = (gap * 1.1).round();
    final present = math.max(0, working - absent - half - lateIn);
    return (present: present, lateIn: lateIn, half: half, absent: absent);
  }

  /// Late counts as attended and a half day as 0.5, like the attendance
  /// calendar.
  static double _percent(_Split s) {
    final total = s.present + s.lateIn + s.half + s.absent;
    if (total == 0) return 0;
    return _round((s.present + s.lateIn + s.half * 0.5) / total * 100, 1);
  }

  // ------------------------------------------------------------ reports

  static SalesReport sales(ReportQuery q) {
    final people = _select(q);
    final days = _days(q);

    var revenueLakh = 0.0;
    var leads = 0;
    var conversions = 0;
    final byEmployee = <ChartPoint>[];

    for (final p in people) {
      final revenue = p.revenueLakhPerDay * days;
      final personLeads = (p.leadsPerDay * days).round();
      revenueLakh += revenue;
      leads += personLeads;
      conversions += (personLeads * p.conversion).round();
      byEmployee.add(ChartPoint(p.name.split(' ').first, _round(revenue, 1)));
    }

    final lost = math.min((leads * 0.25).round(), leads - conversions);

    return SalesReport(
      revenue: revenueLakh * 100000,
      target:
          people.length * _targetLakhPerPersonPerDay * days * 100000,
      leads: leads,
      conversions: conversions,
      lostLeads: lost,
      revenueTrend: _spread(q, revenueLakh),
      revenueByEmployee: byEmployee,
    );
  }

  static EmployeeReport employees(ReportQuery q) {
    final days = _days(q);
    final working = _workingDays(days);

    final rows = [
      for (final p in _select(q))
        _employeeRow(p, days, working),
    ]..sort((a, b) => b.performance.compareTo(a.performance));

    return EmployeeReport(rows: rows);
  }

  static EmployeeReportRow _employeeRow(_Person p, int days, int working) {
    final tasksTotal = (p.tasksPerDay * working).round();
    final score = math.max(0, math.min(100, p.performance - days % 3));

    return EmployeeReportRow(
      name: p.name,
      team: p.team,
      visits: (p.visitsPerDay * working).round(),
      tasksTotal: tasksTotal,
      tasksCompleted: (tasksTotal * score / 100).round(),
      attendancePercent: _percent(_split(p, working)),
      performance: score,
    );
  }

  static CustomerReport customers(ReportQuery q) {
    final people = _select(q);
    final days = _days(q);
    final working = _workingDays(days);

    var active = 0;
    var inactive = 0;
    var added = 0;
    var visits = 0;

    for (final p in people) {
      active += p.activeCustomers;
      inactive += p.inactiveCustomers;
      added += (p.newCustomersPerDay * days).round();
      visits += (p.visitsPerDay * working).round();
    }

    return CustomerReport(
      activeCustomers: active,
      inactiveCustomers: inactive,
      newCustomers: added,
      totalVisits: visits,
      newCustomerTrend: _spread(q, added.toDouble(), decimals: 0),
      mostVisited: [
        for (final (name, share) in _topCustomers)
          ChartPoint(name, (visits * share).round().toDouble()),
      ],
    );
  }

  static AttendanceReport attendance(ReportQuery q) {
    final days = _days(q);
    final working = _workingDays(days);

    final rows = [
      for (final p in _select(q)) _attendanceRow(p, working),
    ]..sort((a, b) => b.percent.compareTo(a.percent));

    final overall = rows.isEmpty
        ? 0.0
        : rows.fold<double>(0, (s, r) => s + r.percent) / rows.length;

    final labels = _labels(q);
    final trend = [
      for (var i = 0; i < labels.length; i++)
        ChartPoint(
          labels[i],
          _round(
            math.max(
              60.0,
              math.min(100.0, overall + _attendanceWave[i % _attendanceWave.length]),
            ),
            1,
          ),
        ),
    ];

    return AttendanceReport(rows: rows, trend: trend, workingDays: working);
  }

  static AttendanceReportRow _attendanceRow(_Person p, int working) {
    final s = _split(p, working);
    return AttendanceReportRow(
      name: p.name,
      percent: _percent(s),
      presentDays: s.present,
      lateDays: s.lateIn,
      halfDays: s.half,
      absentDays: s.absent,
    );
  }
}