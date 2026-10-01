import 'package:flutter/material.dart';

import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../core/extensions/task_style_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../data/models/customer_models.dart';

class TasksTab extends StatelessWidget {
  const TasksTab({super.key, required this.tasks});

  final List<CustomerTask> tasks;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const EmptyState(
        icon: Icons.task_alt_rounded,
        title: 'No tasks assigned',
        message: 'Tasks for this customer will appear here.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      itemCount: tasks.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, i) => _TaskCard(task: tasks[i]),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});

  final CustomerTask task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final time = TimeOfDay.fromDateTime(task.due).format(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(task.title, style: theme.textTheme.titleSmall),
              ),
              const SizedBox(width: AppSpacing.sm),
              StatusChip(
                label: task.priority.label,
                color: task.priority.color,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 16, color: muted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Due ${task.due.dayLabel}, $time',
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ),
              StatusChip(label: task.status.label, color: task.status.color),
            ],
          ),
        ],
      ),
    );
  }
}