import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/datetime_extensions.dart';
import '../../../data/models/report_models.dart';

enum ReportPeriod {
  last7('Last 7 days'),
  last30('Last 30 days'),
  last90('Last 90 days'),
  thisMonth('This month'),
  custom('Custom range');

  const ReportPeriod(this.label);
  final String label;
}

DateTime _daysBefore(DateTime day, int days) =>
    DateTime(day.year, day.month, day.day - days);

class ReportFilters {
  const ReportFilters({
    this.period = ReportPeriod.last30,
    this.customStart,
    this.customEnd,
    this.employee,
    this.team,
  });

  final ReportPeriod period;
  final DateTime? customStart;
  final DateTime? customEnd;

  /// Null means all employees / all teams.
  final String? employee;
  final String? team;

  bool get hasScope => employee != null || team != null;

  /// Date-only values, so the same day always produces the same query.
  ReportQuery get query {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final (start, end) = switch (period) {
      ReportPeriod.last7 => (_daysBefore(today, 6), today),
      ReportPeriod.last30 => (_daysBefore(today, 29), today),
      ReportPeriod.last90 => (_daysBefore(today, 89), today),
      ReportPeriod.thisMonth => (DateTime(today.year, today.month), today),
      ReportPeriod.custom => (
          customStart ?? _daysBefore(today, 29),
          customEnd ?? today,
        ),
    };

    return (start: start, end: end, employee: employee, team: team);
  }

  /// e.g. "12 Sep - 11 Oct 2026".
  String get rangeLabel {
    final q = query;
    final from = q.start.year == q.end.year ? q.start.dayMonth : q.start.shortDate;
    return '$from - ${q.end.shortDate}';
  }
}

class ReportFiltersNotifier extends Notifier<ReportFilters> {
  @override
  ReportFilters build() => const ReportFilters();

  void setPeriod(ReportPeriod period) => state = ReportFilters(
        period: period,
        customStart: state.customStart,
        customEnd: state.customEnd,
        employee: state.employee,
        team: state.team,
      );

  void setCustomRange(DateTime start, DateTime end) => state = ReportFilters(
        period: ReportPeriod.custom,
        customStart: DateTime(start.year, start.month, start.day),
        customEnd: DateTime(end.year, end.month, end.day),
        employee: state.employee,
        team: state.team,
      );

  /// Picking a team drops the selected employee if they are not in it.
  void setTeam(String? team, Map<String, String> employeeTeams) {
    final employee = state.employee;
    final keepEmployee =
        employee != null && (team == null || employeeTeams[employee] == team);

    state = ReportFilters(
      period: state.period,
      customStart: state.customStart,
      customEnd: state.customEnd,
      employee: keepEmployee ? employee : null,
      team: team,
    );
  }

  void setEmployee(String? employee) => state = ReportFilters(
        period: state.period,
        customStart: state.customStart,
        customEnd: state.customEnd,
        employee: employee,
        team: state.team,
      );

  /// Clears team and employee; keeps the date range.
  void clearScope() => state = ReportFilters(
        period: state.period,
        customStart: state.customStart,
        customEnd: state.customEnd,
      );
}

final reportFiltersProvider =
    NotifierProvider<ReportFiltersNotifier, ReportFilters>(
  ReportFiltersNotifier.new,
);