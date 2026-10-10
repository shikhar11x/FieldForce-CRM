import 'package:flutter/material.dart';

import '../../../core/extensions/task_style_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/icon_text.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/task_models.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.showAssignee = true,
  });

  final TaskItem task;

  /// Null = card tap nahi hota (jaise Admin, jiske paas Tasks section nahi).
  final VoidCallback? onTap;
  final bool showAssignee;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overdue = task.isOverdue;
    final dueText = overdue
        ? '${task.dueLabel(context)} · Overdue'
        : task.dueLabel(context);

    return AppCard(
      onTap: onTap,
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
          IconText(icon: Icons.business_rounded, text: task.customer),
          const SizedBox(height: 4),
          IconText(
            icon: Icons.place_outlined,
            text: task.location.isEmpty ? 'No location' : task.location,
          ),
          if (showAssignee) ...[
            const SizedBox(height: 4),
            IconText(
              icon: Icons.person_outline_rounded,
              text: task.assignee,
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(),
          ),
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 16,
                color: overdue
                    ? AppColors.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  dueText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: overdue ? AppColors.error : null,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              StatusChip(label: task.status.label, color: task.status.color),
            ],
          ),
        ],
      ),
    );
  }
}