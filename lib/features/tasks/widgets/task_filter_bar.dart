import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/models/task_enums.dart';
import '../providers/task_filters_provider.dart';

/// Search field, status tabs (with counts), priority filter and sort.
class TaskFilterBar extends ConsumerStatefulWidget {
  const TaskFilterBar({super.key, this.resultCount});

  final int? resultCount;

  @override
  ConsumerState<TaskFilterBar> createState() => _TaskFilterBarState();
}

class _TaskFilterBarState extends ConsumerState<TaskFilterBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filters = ref.watch(taskFiltersProvider);
    final notifier = ref.read(taskFiltersProvider.notifier);
    final counts = ref.watch(taskStatusCountsProvider);
    final count = widget.resultCount;
    final tabs = <TaskStatus?>[null, ...TaskStatus.values];

    // Keeps the text field in sync when filters are reset elsewhere.
    ref.listen(taskFiltersProvider, (_, next) {
      if (next.query.isEmpty && _controller.text.isNotEmpty) {
        _controller.clear();
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          textInputAction: TextInputAction.search,
          onChanged: notifier.setQuery,
          decoration: InputDecoration(
            hintText: 'Search tasks, customers or locations',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: filters.query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      _controller.clear();
                      notifier.setQuery('');
                    },
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: tabs.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, i) {
              final status = tabs[i];
              final label = status?.label ?? 'All';
              return ChoiceChip(
                label: Text('$label ${counts[status] ?? 0}'),
                selected: filters.status == status,
                showCheckmark: false,
                onSelected: (_) => notifier.setStatus(status),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: Text(
                count == null
                    ? ''
                    : '$count ${count == 1 ? 'task' : 'tasks'}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            // Index -1 stands for "All priorities" because popup menus
            // do not report null selections.
            PopupMenuButton<int>(
              tooltip: 'Filter by priority',
              onSelected: (i) => notifier.setPriority(
                i < 0 ? null : TaskPriority.values[i],
              ),
              itemBuilder: (context) => [
                CheckedPopupMenuItem<int>(
                  value: -1,
                  checked: filters.priority == null,
                  child: const Text('All priorities'),
                ),
                for (final (i, p) in TaskPriority.values.indexed)
                  CheckedPopupMenuItem<int>(
                    value: i,
                    checked: filters.priority == p,
                    child: Text(p.label),
                  ),
              ],
              child: _MenuLabel(
                icon: Icons.flag_outlined,
                text: filters.priority?.label ?? 'All priorities',
              ),
            ),
            PopupMenuButton<TaskSort>(
              tooltip: 'Sort',
              onSelected: notifier.setSort,
              itemBuilder: (context) => [
                for (final sort in TaskSort.values)
                  CheckedPopupMenuItem<TaskSort>(
                    value: sort,
                    checked: sort == filters.sort,
                    child: Text(sort.label),
                  ),
              ],
              child: _MenuLabel(
                icon: Icons.sort_rounded,
                text: filters.sort.label,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MenuLabel extends StatelessWidget {
  const _MenuLabel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.labelLarge?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}