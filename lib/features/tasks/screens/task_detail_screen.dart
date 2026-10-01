import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/task_style_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/detail_row.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/task_enums.dart';
import '../../../data/models/task_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/task_provider.dart';

class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final tasks = ref.watch(tasksProvider);

    // Briefly null while the router redirects after logout.
    if (user == null) return const SizedBox.shrink();

    final list = tasks.value;
    final task = list == null ? null : findTask(list, taskId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task details'),
        actions: [
          if (task != null)
            IconButton(
              tooltip: 'Edit task',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  context.go('${user.role.basePath}/tasks/$taskId/edit'),
            ),
        ],
      ),
      body: ResponsiveBody(
        maxWidth: 700,
        child: AsyncValueView<List<TaskItem>>(
          value: tasks,
          onRetry: () => ref.invalidate(tasksProvider),
          loading: const _DetailSkeleton(),
          data: (_) => task == null
              ? const EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'Task not found',
                  message: 'It may have been removed.',
                )
              : _TaskDetailContent(task: task),
        ),
      ),
    );
  }
}

class _TaskDetailContent extends StatelessWidget {
  const _TaskDetailContent({required this.task});

  final TaskItem task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = task.description.trim();

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.title, style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  StatusChip(
                    label: task.status.label,
                    color: task.status.color,
                  ),
                  StatusChip(
                    label: '${task.priority.label} priority',
                    color: task.priority.color,
                  ),
                  if (task.isOverdue)
                    const StatusChip(label: 'Overdue', color: AppColors.error),
                ],
              ),
            ],
          ),
        ),
        const SectionHeader(title: 'Description'),
        AppCard(
          child: SizedBox(
            width: double.infinity,
            child: Text(
              description.isEmpty ? 'No description provided.' : description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: description.isEmpty
                    ? theme.colorScheme.onSurfaceVariant
                    : null,
              ),
            ),
          ),
        ),
        const SectionHeader(title: 'Details'),
        AppCard(
          child: Column(
            children: [
              DetailRow(
                icon: Icons.business_rounded,
                label: 'Customer',
                value: task.customer,
              ),
              DetailRow(
                icon: Icons.person_outline_rounded,
                label: 'Assigned to',
                value: task.assignee,
              ),
              DetailRow(
                icon: Icons.event_rounded,
                label: 'Due',
                value: task.dueLabel(context),
              ),
              DetailRow(
                icon: Icons.place_outlined,
                label: 'Location',
                value: task.location.isEmpty ? 'Not specified' : task.location,
              ),
            ],
          ),
        ),
        const SectionHeader(title: 'Update status'),
        _StatusActions(task: task),
      ],
    );
  }
}

class _StatusActions extends ConsumerStatefulWidget {
  const _StatusActions({required this.task});

  final TaskItem task;

  @override
  ConsumerState<_StatusActions> createState() => _StatusActionsState();
}

class _StatusActionsState extends ConsumerState<_StatusActions> {
  bool _busy = false;

  Future<void> _change(TaskStatus status, String message) async {
    setState(() => _busy = true);
    try {
      await ref.read(tasksProvider.notifier).changeStatus(
            widget.task,
            status,
          );
      if (mounted) context.showSnack(message);
    } catch (_) {
      if (mounted) {
        context.showSnack('Could not update the task. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel this task?'),
        content: const Text(
          'The task stays in your list as Cancelled. You can reopen it later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep task'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Cancel task'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _change(TaskStatus.cancelled, 'Task cancelled.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;

    final actions = switch (task.status) {
      TaskStatus.pending => <Widget>[
          FilledButton.icon(
            onPressed: _busy
                ? null
                : () => _change(TaskStatus.inProgress, 'Task started.'),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start task'),
          ),
          OutlinedButton.icon(
            onPressed: _busy ? null : _cancel,
            icon: const Icon(Icons.close_rounded),
            label: const Text('Cancel task'),
          ),
        ],
      TaskStatus.inProgress => <Widget>[
          FilledButton.icon(
            onPressed: _busy
                ? null
                : () => _change(TaskStatus.completed, 'Task completed.'),
            icon: const Icon(Icons.check_rounded),
            label: const Text('Mark complete'),
          ),
          OutlinedButton.icon(
            onPressed: _busy ? null : _cancel,
            icon: const Icon(Icons.close_rounded),
            label: const Text('Cancel task'),
          ),
        ],
      TaskStatus.completed || TaskStatus.cancelled => <Widget>[
          OutlinedButton.icon(
            onPressed: _busy
                ? null
                : () => _change(TaskStatus.pending, 'Task reopened.'),
            icon: const Icon(Icons.replay_rounded),
            label: const Text('Reopen task'),
          ),
        ],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, action) in actions.indexed) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm),
          action,
        ],
      ],
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SkeletonBox(height: 100, radius: AppRadius.lg),
        SizedBox(height: AppSpacing.lg),
        SkeletonBox(height: 90, radius: AppRadius.lg),
        SizedBox(height: AppSpacing.lg),
        SkeletonBox(height: 200, radius: AppRadius.lg),
      ],
    );
  }
}