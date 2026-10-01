import 'package:flutter/material.dart';

import '../../../core/extensions/task_style_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/adaptive_wrap.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/employee_models.dart';
import 'dashboard_layout.dart';

class UpcomingTasks extends StatelessWidget {
  const UpcomingTasks({super.key, required this.tasks});

  final List<UpcomingTask> tasks;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const AppCard(
        child: EmptyState(
          icon: Icons.task_alt_rounded,
          title: 'No tasks assigned',
          message: 'New tasks from your manager will appear here.',
        ),
      );
    }

    return AdaptiveWrap(
      columns: DashboardLayout.chartColumns,
      children: [for (final task in tasks) _TaskCard(task: task)],
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});

  final UpcomingTask task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              StatusChip(
                label: task.priority.label,
                color: task.priority.color,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(icon: Icons.business_rounded, text: task.customer),
          const SizedBox(height: 4),
          _InfoRow(icon: Icons.place_outlined, text: task.location),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 16, color: muted),
              const SizedBox(width: 4),
              Text(task.time, style: theme.textTheme.labelLarge),
              const Spacer(),
              StatusChip(label: task.status.label, color: task.status.color),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Row(
      children: [
        Icon(icon, size: 16, color: muted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
        ),
      ],
    );
  }
}