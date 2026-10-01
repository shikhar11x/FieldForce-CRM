import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/animate_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../../data/models/task_models.dart';
import '../../../data/models/user_role.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/task_filters_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/task_filter_bar.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(tasksProvider);
    try {
      await ref.read(tasksProvider.future);
    } catch (_) {
      // The error state is rendered by AsyncValueView.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final tasks = ref.watch(filteredTasksProvider);
    final filters = ref.watch(taskFiltersProvider);

    // Briefly null while the router redirects after logout.
    if (user == null) return const SizedBox.shrink();

    final Widget emptyView = filters.isActive
        ? EmptyState(
            icon: Icons.search_off_rounded,
            title: 'No tasks found',
            message: 'Try a different search or clear your filters.',
            actionLabel: 'Clear filters',
            onAction: ref.read(taskFiltersProvider.notifier).reset,
          )
        : const EmptyState(
            icon: Icons.task_alt_rounded,
            title: 'No tasks assigned',
            message: 'New tasks will appear here once they are created.',
          );

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('${user.role.basePath}/tasks/new'),
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('New task'),
      ),
      body: ResponsiveBody(
        maxWidth: 900,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TaskFilterBar(resultCount: tasks.value?.length),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: AsyncValueView<List<TaskItem>>(
                value: tasks,
                onRetry: () => ref.invalidate(tasksProvider),
                loading: const _ListSkeleton(),
                isEmpty: (list) => list.isEmpty,
                empty: emptyView,
                data: (list) => RefreshIndicator(
                  onRefresh: () => _refresh(ref),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: list.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, i) {
                      final task = list[i];
                      return TaskCard(
                        task: task,
                        showAssignee: user.role != UserRole.employee,
                        onTap: () => context.go(
                          '${user.role.basePath}/tasks/${task.id}',
                        ),
                      ).entrance(math.min(i, 5));
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (var i = 0; i < 4; i++) ...[
          const SkeletonBox(height: 150, radius: AppRadius.lg),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}