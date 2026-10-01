import '../mock/mock_tasks.dart';
import '../models/task_models.dart';
import 'task_repository.dart';

class MockTaskRepository implements TaskRepository {
  @override
  Future<List<TaskItem>> getTasks() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return MockTasks.all();
  }

  @override
  Future<TaskFormOptions> getFormOptions() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return MockTasks.formOptions();
  }

  @override
  Future<TaskItem> createTask(TaskItem task) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return task;
  }

  @override
  Future<TaskItem> updateTask(TaskItem task) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return task;
  }
}