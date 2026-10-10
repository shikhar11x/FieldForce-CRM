import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/directory_models.dart';
import 'user_repository.dart';

class ApiUserRepository implements UserRepository {
  ApiUserRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<DirectoryUser>> getUsers() async {
    final response = await _api.dio.get<List<dynamic>>('/users');
    return [
      for (final item in response.data!)
        DirectoryUser.fromJson(item as Map<String, dynamic>),
    ];
  }

  @override
  Future<CreatedUser> createUser(DirectoryUser user) async {
    try {
      final response = await _api.dio.post<Map<String, dynamic>>(
        '/users',
        data: user.toRequestJson(),
      );
      final data = response.data!;
      return CreatedUser(
        user: DirectoryUser.fromJson(data['user'] as Map<String, dynamic>),
        temporaryPassword: data['temporaryPassword'] as String?,
      );
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  @override
  Future<DirectoryUser> updateUser(DirectoryUser user) async {
    try {
      final response = await _api.dio.patch<Map<String, dynamic>>(
        '/users/${user.id}',
        data: user.toRequestJson(),
      );
      return DirectoryUser.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }
}