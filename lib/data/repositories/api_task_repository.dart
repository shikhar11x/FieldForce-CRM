import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/task_models.dart';
import 'task_repository.dart';

class ApiTaskRepository implements TaskRepository {
  ApiTaskRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<TaskItem>> getTasks() async {
    final response = await _api.dio.get<List<dynamic>>('/tasks');
    return [
      for (final item in response.data!)
        TaskItem.fromJson(item as Map<String, dynamic>),
    ];
  }

  @override
  Future<TaskFormOptions> getFormOptions() async {
    final response =
        await _api.dio.get<Map<String, dynamic>>('/tasks/options');
    return TaskFormOptions.fromJson(response.data!);
  }

  @override
  Future<TaskItem> createTask(TaskItem task) async {
    try {
      final response = await _api.dio.post<Map<String, dynamic>>(
        '/tasks',
        data: task.toRequestJson(),
      );
      return TaskItem.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  @override
  Future<TaskItem> updateTask(TaskItem task) async {
    try {
      final response = await _api.dio.patch<Map<String, dynamic>>(
        '/tasks/${task.id}',
        data: task.toRequestJson(),
      );
      return TaskItem.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }
}