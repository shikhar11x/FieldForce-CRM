import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/adaptive_wrap.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../../data/models/task_models.dart';
import '../../tasks/providers/task_provider.dart';
import '../../tasks/widgets/task_card.dart';
import 'dashboard_layout.dart';

/// Soonest open tasks, read from the same list as the Tasks module.
class UpcomingTasks extends ConsumerWidget {
  const UpcomingTasks({super.key, required this.basePath});

  /// Role route prefix, e.g. `/employee`.
  final String basePath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueView<List<TaskItem>>(
      value: ref.watch(upcomingTasksProvider),
      onRetry: () => ref.invalidate(tasksProvider),
      loading: const SkeletonBox(height: 150, radius: AppRadius.lg),
      isEmpty: (tasks) => tasks.isEmpty,
      empty: const AppCard(
        child: EmptyState(
          icon: Icons.task_alt_rounded,
          title: 'No tasks assigned',
          message: 'New tasks from your manager will appear here.',
        ),
      ),
      data: (tasks) => AdaptiveWrap(
        columns: DashboardLayout.chartColumns,
        children: [
          for (final task in tasks)
            TaskCard(
              task: task,
              showAssignee: false,
              onTap: () => context.go('$basePath/tasks/${task.id}'),
            ),
        ],
      ),
    );
  }
}