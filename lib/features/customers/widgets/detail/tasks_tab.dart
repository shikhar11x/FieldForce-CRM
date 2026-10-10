import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../../data/models/task_models.dart';
import '../../../../data/models/user_role.dart';
import '../../../tasks/providers/task_provider.dart';
import '../../../tasks/widgets/task_card.dart';

/// Tasks for one customer, read from the shared task list.
class TasksTab extends ConsumerWidget {
  const TasksTab({super.key, required this.customerName, required this.role});

  final String customerName;
  final UserRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final createPath = newTaskPath(role, customer: customerName);
    final canOpen = createPath != null;

    return AsyncValueView<List<TaskItem>>(
      value: ref.watch(customerTasksProvider(customerName)),
      onRetry: () => ref.invalidate(tasksProvider),
      loading: const _TasksSkeleton(),
      isEmpty: (tasks) => tasks.isEmpty,
      empty: EmptyState(
        icon: Icons.task_alt_rounded,
        title: 'No tasks assigned',
        message: 'Tasks for this customer will appear here.',
        actionLabel: canOpen ? 'Create task' : null,
        onAction: canOpen ? () => context.go(createPath) : null,
      ),
      data: (tasks) => ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          if (canOpen) ...[
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: () => context.go(createPath),
                icon: const Icon(Icons.add_task_rounded),
                label: const Text('New task'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          for (final task in tasks) ...[
            TaskCard(
              task: task,
              onTap: canOpen
                  ? () => context.go('${role.basePath}/tasks/${task.id}')
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _TasksSkeleton extends StatelessWidget {
  const _TasksSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SkeletonBox(height: 150, radius: AppRadius.lg),
        SizedBox(height: AppSpacing.md),
        SkeletonBox(height: 150, radius: AppRadius.lg),
      ],
    );
  }
}