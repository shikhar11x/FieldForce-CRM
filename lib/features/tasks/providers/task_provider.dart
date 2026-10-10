import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/api_config.dart';
import '../../../core/network/api_providers.dart';
import '../../../data/models/task_enums.dart';
import '../../../data/models/task_models.dart';
import '../../../data/models/user_role.dart';
import '../../../data/repositories/api_task_repository.dart';
import '../../../data/repositories/mock_task_repository.dart';
import '../../../data/repositories/task_repository.dart';
import '../../auth/providers/auth_provider.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  if (ApiConfig.useMockAuth) return MockTaskRepository();
  return ApiTaskRepository(ref.watch(apiClientProvider));
});

/// Holds the task list for the session. Writes go through the repository,
/// so the UI never talks to the API directly.
class TasksNotifier extends AsyncNotifier<List<TaskItem>> {
  TaskRepository get _repo => ref.read(taskRepositoryProvider);

  List<TaskItem> get _current => state.value ?? const <TaskItem>[];

  @override
  Future<List<TaskItem>> build() async {
    // Account badalne par list dobara load ho; logout ke baad khaali.
    final userId = ref.watch(authProvider.select((s) => s.user?.id));
    if (userId == null) return const <TaskItem>[];
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
/// (Server already scopes this; the filter keeps mock mode consistent.)
final scopedTasksProvider =
    Provider.autoDispose<AsyncValue<List<TaskItem>>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final user = ref.watch(authProvider).user;

  return tasks.whenData((list) {
    if (user == null || user.role != UserRole.employee) return list;
    return list.where((t) => t.assignee == user.name).toList();
  });
});

/// Open tasks for the Employee Home list: soonest first, overdue included.
final upcomingTasksProvider =
    Provider.autoDispose<AsyncValue<List<TaskItem>>>((ref) {
  return ref.watch(scopedTasksProvider).whenData((list) {
    final open = list
        .where(
          (t) =>
              t.status == TaskStatus.pending ||
              t.status == TaskStatus.inProgress,
        )
        .toList()
      ..sort((a, b) => a.due.compareTo(b.due));
    return open.take(4).toList();
  });
});

/// Tasks due today that are not cancelled.
final tasksDueTodayCountProvider = Provider.autoDispose<int>((ref) {
  final list = ref.watch(scopedTasksProvider).value ?? const <TaskItem>[];
  final now = DateTime.now();
  return list
      .where(
        (t) =>
            t.status != TaskStatus.cancelled &&
            t.due.year == now.year &&
            t.due.month == now.month &&
            t.due.day == now.day,
      )
      .length;
});

/// Tasks linked to one customer (by company name), soonest first.
final customerTasksProvider = Provider.autoDispose
    .family<AsyncValue<List<TaskItem>>, String>((ref, customer) {
  return ref.watch(scopedTasksProvider).whenData((list) {
    final result = list.where((t) => t.customer == customer).toList()
      ..sort((a, b) => a.due.compareTo(b.due));
    return result;
  });
});

TaskItem? findTask(List<TaskItem> tasks, String id) {
  for (final task in tasks) {
    if (task.id == id) return task;
  }
  return null;
}