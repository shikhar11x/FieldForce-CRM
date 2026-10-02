import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/models/report_models.dart';
import '../providers/report_filters_provider.dart';
import '../providers/report_provider.dart';

/// Date range, team and employee filters.
class ReportFilterBar extends ConsumerWidget {
  const ReportFilterBar({super.key});

  Future<void> _pickRange(
    BuildContext context,
    WidgetRef ref,
    ReportQuery current,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(today.year - 2),
      lastDate: today,
      initialDateRange: DateTimeRange(start: current.start, end: current.end),
    );
    if (picked == null || !context.mounted) return;

    ref
        .read(reportFiltersProvider.notifier)
        .setCustomRange(picked.start, picked.end);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filters = ref.watch(reportFiltersProvider);
    final notifier = ref.read(reportFiltersProvider.notifier);
    final options = ref.watch(reportFilterOptionsProvider).value;

    final teams = options?.teams ?? const <String>[];
    final employeeTeams = options?.employeeTeams ?? const <String, String>{};
    final employees = options?.employeesIn(filters.team) ?? const <String>[];
    final isCustom = filters.period == ReportPeriod.custom;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            PopupMenuButton<ReportPeriod>(
              tooltip: 'Date range',
              onSelected: (period) {
                if (period == ReportPeriod.custom) {
                  _pickRange(context, ref, filters.query);
                } else {
                  notifier.setPeriod(period);
                }
              },
              itemBuilder: (context) => [
                for (final period in ReportPeriod.values)
                  CheckedPopupMenuItem<ReportPeriod>(
                    value: period,
                    checked: period == filters.period,
                    child: Text(period.label),
                  ),
              ],
              child: _FilterButton(
                icon: Icons.date_range_rounded,
                label: isCustom ? filters.rangeLabel : filters.period.label,
              ),
            ),
            // An empty string stands for "All" because popup menus do not
            // report null selections.
            PopupMenuButton<String>(
              tooltip: 'Team',
              enabled: options != null,
              onSelected: (value) => notifier.setTeam(
                value.isEmpty ? null : value,
                employeeTeams,
              ),
              itemBuilder: (context) => [
                CheckedPopupMenuItem<String>(
                  value: '',
                  checked: filters.team == null,
                  child: const Text('All teams'),
                ),
                for (final team in teams)
                  CheckedPopupMenuItem<String>(
                    value: team,
                    checked: filters.team == team,
                    child: Text(team),
                  ),
              ],
              child: _FilterButton(
                icon: Icons.groups_rounded,
                label: filters.team ?? 'All teams',
                active: filters.team != null,
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Employee',
              enabled: options != null,
              onSelected: (value) =>
                  notifier.setEmployee(value.isEmpty ? null : value),
              itemBuilder: (context) => [
                CheckedPopupMenuItem<String>(
                  value: '',
                  checked: filters.employee == null,
                  child: const Text('All employees'),
                ),
                for (final name in employees)
                  CheckedPopupMenuItem<String>(
                    value: name,
                    checked: filters.employee == name,
                    child: Text(name),
                  ),
              ],
              child: _FilterButton(
                icon: Icons.person_outline_rounded,
                label: filters.employee ?? 'All employees',
                active: filters.employee != null,
              ),
            ),
            if (filters.hasScope)
              TextButton(
                onPressed: notifier.clearScope,
                child: const Text('Clear'),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Showing ${filters.rangeLabel}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.icon,
    required this.label,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = active ? scheme.primary : scheme.onSurfaceVariant;

    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active ? scheme.primary.withValues(alpha: 0.08) : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? scheme.primary : scheme.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
                color: active ? scheme.primary : null,
              ),
            ),
          ),
          Icon(Icons.arrow_drop_down_rounded, size: 20, color: color),
        ],
      ),
    );
  }
}