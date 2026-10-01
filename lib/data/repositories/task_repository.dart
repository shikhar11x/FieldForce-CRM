import '../models/task_models.dart';

/// Phase 2 swaps the mock implementation for an API-backed one.
abstract class TaskRepository {
  Future<List<TaskItem>> getTasks();
  Future<TaskFormOptions> getFormOptions();
  Future<TaskItem> createTask(TaskItem task);
  Future<TaskItem> updateTask(TaskItem task);
}