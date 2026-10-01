import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/task_enums.dart';
import '../../../data/models/task_models.dart';
import 'task_provider.dart';

enum TaskSort {
  dueDate('Due date'),
  priority('Priority'),
  title('Title (A-Z)');

  const TaskSort(this.label);
  final String label;
}

class TaskFilters {
  const TaskFilters({
    this.query = '',
    this.status,
    this.priority,
    this.sort = TaskSort.dueDate,
  });

  final String query;

  /// Null means "All".
  final TaskStatus? status;
  final TaskPriority? priority;
  final TaskSort sort;

  bool get isActive =>
      query.trim().isNotEmpty || status != null || priority != null;
}

class TaskFiltersNotifier extends Notifier<TaskFilters> {
  @override
  TaskFilters build() => const TaskFilters();

  void setQuery(String query) => state = TaskFilters(
        query: query,
        status: state.status,
        priority: state.priority,
        sort: state.sort,
      );

  void setStatus(TaskStatus? status) => state = TaskFilters(
        query: state.query,
        status: status,
        priority: state.priority,
        sort: state.sort,
      );

  void setPriority(TaskPriority? priority) => state = TaskFilters(
        query: state.query,
        status: state.status,
        priority: priority,
        sort: state.sort,
      );

  void setSort(TaskSort sort) => state = TaskFilters(
        query: state.query,
        status: state.status,
        priority: state.priority,
        sort: sort,
      );

  /// Clears search, status and priority; keeps the chosen sort order.
  void reset() => state = TaskFilters(sort: state.sort);
}

final taskFiltersProvider =
    NotifierProvider<TaskFiltersNotifier, TaskFilters>(
  TaskFiltersNotifier.new,
);

bool _matchesQuery(TaskItem t, String query) {
  if (query.isEmpty) return true;
  return [t.title, t.description, t.customer, t.assignee, t.location]
      .any((value) => value.toLowerCase().contains(query));
}

List<TaskItem> applyTaskFilters(List<TaskItem> source, TaskFilters f) {
  final query = f.query.trim().toLowerCase();

  final result = source.where((t) {
    if (f.status != null && t.status != f.status) return false;
    if (f.priority != null && t.priority != f.priority) return false;
    return _matchesQuery(t, query);
  }).toList();

  switch (f.sort) {
    case TaskSort.dueDate:
      result.sort((a, b) => a.due.compareTo(b.due));
    case TaskSort.priority:
      result.sort((a, b) {
        final byPriority = b.priority.index.compareTo(a.priority.index);
        return byPriority != 0 ? byPriority : a.due.compareTo(b.due);
      });
    case TaskSort.title:
      result.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
  }
  return result;
}

final filteredTasksProvider =
    Provider.autoDispose<AsyncValue<List<TaskItem>>>((ref) {
  final tasks = ref.watch(scopedTasksProvider);
  final filters = ref.watch(taskFiltersProvider);
  return tasks.whenData((list) => applyTaskFilters(list, filters));
});

/// Count shown on each status tab. Respects search and priority, but not
/// the selected status. The `null` key is the "All" tab.
final taskStatusCountsProvider =
    Provider.autoDispose<Map<TaskStatus?, int>>((ref) {
  final tasks = ref.watch(scopedTasksProvider).value ?? const <TaskItem>[];
  final f = ref.watch(taskFiltersProvider);
  final query = f.query.trim().toLowerCase();

  final base = tasks
      .where(
        (t) =>
            (f.priority == null || t.priority == f.priority) &&
            _matchesQuery(t, query),
      )
      .toList();

  return {
    null: base.length,
    for (final s in TaskStatus.values)
      s: base.where((t) => t.status == s).length,
  };
});