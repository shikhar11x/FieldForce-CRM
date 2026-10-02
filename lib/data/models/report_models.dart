import 'chart_point.dart';

/// Filters shared by every report. A null [employee] or [team] means all.
typedef ReportQuery = ({
  DateTime start,
  DateTime end,
  String? employee,
  String? team,
});

class ReportFilterOptions {
  const ReportFilterOptions({required this.teams, required this.employeeTeams});

  final List<String> teams;

  /// Employee name -> team name.
  final Map<String, String> employeeTeams;

  List<String> employeesIn(String? team) => [
        for (final e in employeeTeams.entries)
          if (team == null || e.value == team) e.key,
      ];
}

// ---------------------------------------------------------------- Sales

class SalesReport {
  const SalesReport({
    required this.revenue,
    required this.target,
    required this.leads,
    required this.conversions,
    required this.lostLeads,
    required this.revenueTrend,
    required this.revenueByEmployee,
  });

  /// Rupees.
  final double revenue;
  final double target;
  final int leads;
  final int conversions;
  final int lostLeads;

  /// Both chart lists are in rupees lakh.
  final List<ChartPoint> revenueTrend;
  final List<ChartPoint> revenueByEmployee;

  double get conversionRate => leads == 0 ? 0 : conversions / leads * 100;
  double get averageDeal => conversions == 0 ? 0 : revenue / conversions;
  double get targetPercent => target == 0 ? 0 : revenue / target * 100;

  int get openLeads {
    final open = leads - conversions - lostLeads;
    return open < 0 ? 0 : open;
  }

  List<ChartPoint> get leadOutcomes => [
        ChartPoint('Won', conversions.toDouble()),
        ChartPoint('Open', openLeads.toDouble()),
        ChartPoint('Lost', lostLeads.toDouble()),
      ];
}

// ------------------------------------------------------------- Employee

class EmployeeReportRow {
  const EmployeeReportRow({
    required this.name,
    required this.team,
    required this.visits,
    required this.tasksCompleted,
    required this.tasksTotal,
    required this.attendancePercent,
    required this.performance,
  });

  final String name;
  final String team;
  final int visits;
  final int tasksCompleted;
  final int tasksTotal;
  final double attendancePercent;

  /// Score out of 100.
  final int performance;
}

class EmployeeReport {
  const EmployeeReport({required this.rows});

  /// Best performance first.
  final List<EmployeeReportRow> rows;

  int get totalVisits => rows.fold<int>(0, (s, r) => s + r.visits);
  int get tasksCompleted => rows.fold<int>(0, (s, r) => s + r.tasksCompleted);
  int get totalTasks => rows.fold<int>(0, (s, r) => s + r.tasksTotal);

  double get averageAttendance => rows.isEmpty
      ? 0
      : rows.fold<double>(0, (s, r) => s + r.attendancePercent) / rows.length;

  double get averagePerformance => rows.isEmpty
      ? 0
      : rows.fold<double>(0, (s, r) => s + r.performance) / rows.length;

  List<ChartPoint> get taskBreakdown {
    final remaining = totalTasks - tasksCompleted;
    final inProgress = (remaining * 0.4).round();
    final pending = (remaining * 0.4).round();
    final overdue = remaining - inProgress - pending;
    return [
      ChartPoint('Completed', tasksCompleted.toDouble()),
      ChartPoint('In progress', inProgress.toDouble()),
      ChartPoint('Pending', pending.toDouble()),
      ChartPoint('Overdue', overdue.toDouble()),
    ];
  }
}

// ------------------------------------------------------------- Customer

class CustomerReport {
  const CustomerReport({
    required this.activeCustomers,
    required this.inactiveCustomers,
    required this.newCustomers,
    required this.totalVisits,
    required this.newCustomerTrend,
    required this.mostVisited,
  });

  final int activeCustomers;
  final int inactiveCustomers;
  final int newCustomers;
  final int totalVisits;
  final List<ChartPoint> newCustomerTrend;
  final List<ChartPoint> mostVisited;

  List<ChartPoint> get statusBreakdown => [
        ChartPoint('Active', activeCustomers.toDouble()),
        ChartPoint('Inactive', inactiveCustomers.toDouble()),
        ChartPoint('New', newCustomers.toDouble()),
      ];
}

// ----------------------------------------------------------- Attendance

class AttendanceReportRow {
  const AttendanceReportRow({
    required this.name,
    required this.percent,
    required this.presentDays,
    required this.lateDays,
    required this.halfDays,
    required this.absentDays,
  });

  final String name;
  final double percent;
  final int presentDays;
  final int lateDays;
  final int halfDays;
  final int absentDays;
}

class AttendanceReport {
  const AttendanceReport({
    required this.rows,
    required this.trend,
    required this.workingDays,
  });

  /// Best attendance first.
  final List<AttendanceReportRow> rows;

  /// Attendance percent per period bucket.
  final List<ChartPoint> trend;
  final int workingDays;

  int get totalPresent => rows.fold<int>(0, (s, r) => s + r.presentDays);
  int get totalLate => rows.fold<int>(0, (s, r) => s + r.lateDays);
  int get totalHalf => rows.fold<int>(0, (s, r) => s + r.halfDays);
  int get totalAbsent => rows.fold<int>(0, (s, r) => s + r.absentDays);

  double get averagePercent => rows.isEmpty
      ? 0
      : rows.fold<double>(0, (s, r) => s + r.percent) / rows.length;

  List<ChartPoint> get breakdown => [
        ChartPoint('Present', totalPresent.toDouble()),
        ChartPoint('Late', totalLate.toDouble()),
        ChartPoint('Half day', totalHalf.toDouble()),
        ChartPoint('Absent', totalAbsent.toDouble()),
      ];
}