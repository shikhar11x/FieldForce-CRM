import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/task_enums.dart';
import '../../../data/models/task_models.dart';
import '../../../data/models/user_role.dart';
import '../../../data/repositories/mock_task_repository.dart';
import '../../../data/repositories/task_repository.dart';
import '../../auth/providers/auth_provider.dart';

final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => MockTaskRepository(),
);

/// Holds the task list for the session. Writes go through the repository,
/// so Phase 2 only has to replace the repository implementation.
class TasksNotifier extends AsyncNotifier<List<TaskItem>> {
  TaskRepository get _repo => ref.read(taskRepositoryProvider);

  List<TaskItem> get _current => state.value ?? const <TaskItem>[];

  @override
  Future<List<TaskItem>> build() {
    return ref.watch(taskRepositoryProvider).getTasks();
  }

  Future<void> addTask(TaskItem task) async {
    final saved = await _repo.createTask(task);
    state = AsyncData([saved, ..._current]);
  }

  Future<void> saveTask(TaskItem task) async {
    final saved = await _repo.updateTask(task);
    state = AsyncData([
      for (final t in _current)
        if (t.id == saved.id) saved else t,
    ]);
  }

  Future<void> changeStatus(TaskItem task, TaskStatus status) {
    return saveTask(task.copyWith(status: status));
  }
}

final tasksProvider =
    AsyncNotifierProvider<TasksNotifier, List<TaskItem>>(TasksNotifier.new);

final taskFormOptionsProvider =
    FutureProvider.autoDispose<TaskFormOptions>((ref) {
  return ref.watch(taskRepositoryProvider).getFormOptions();
});

/// Employees only see their own tasks; managers see the whole team's.
final scopedTasksProvider =
    Provider.autoDispose<AsyncValue<List<TaskItem>>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final user = ref.watch(authProvider).user;

  return tasks.whenData((list) {
    if (user == null || user.role != UserRole.employee) return list;
    return list.where((t) => t.assignee == user.name).toList();
  });
});

TaskItem? findTask(List<TaskItem> tasks, String id) {
  for (final task in tasks) {
    if (task.id == id) return task;
  }
  return null;
}