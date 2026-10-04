import 'package:dio/dio.dart';

import '../../core/constants/app_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/token_storage.dart';
import '../models/app_user.dart';
import '../models/user_role.dart';
import 'auth_repository.dart';

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._api, this._tokens);

  final ApiClient _api;
  final TokenStorage _tokens;

  // Dev: demo buttons seeded accounts se asli login karte hain.
  static const _demoEmails = {
    UserRole.admin: 'admin@fieldforce.com',
    UserRole.manager: 'manager@fieldforce.com',
    UserRole.employee: 'employee@fieldforce.com',
  };

  @override
  Future<AppUser> login({required String email, required String password}) {
    return _authenticate(email.trim(), password);
  }

  @override
  Future<AppUser> loginAsDemo(UserRole role) {
    return _authenticate(_demoEmails[role]!, AppConstants.demoPassword);
  }

  @override
  Future<AppUser?> restoreSession() async {
    if (await _tokens.refreshToken == null) return null;

    try {
      final response =
          await _api.dio.get<Map<String, dynamic>>('/auth/me');
      return AppUser.fromJson(response.data!);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) await _tokens.clear();
      // Network down ho to tokens rehne do, agli baar dobara try hoga.
      return null;
    }
  }

  @override
  Future<AppUser> updateProfile(AppUser user) async {
    try {
      final response = await _api.dio.patch<Map<String, dynamic>>(
        '/auth/me',
        data: {'email': user.email, 'phone': user.phone},
      );
      return AppUser.fromJson(response.data!);
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _api.dio.post<Map<String, dynamic>>(
        '/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
      // Baaki sessions band ho gaye, is device ke liye naye tokens aate hain.
      await _saveTokens(response.data!);
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      final refreshToken = await _tokens.refreshToken;
      if (refreshToken != null) {
        await _api.dio.post<void>(
          '/auth/logout',
          data: {'refreshToken': refreshToken},
          options: ApiClient.skipAuth,
        );
      }
    } on DioException {
      // Server tak na pahunche to bhi local logout hona chahiye.
    } finally {
      await _tokens.clear();
    }
  }

  Future<AppUser> _authenticate(String email, String password) async {
    try {
      final response = await _api.dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password},
        options: ApiClient.skipAuth,
      );
      final data = response.data!;
      await _saveTokens(data);
      return AppUser.fromJson(data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  Future<void> _saveTokens(Map<String, dynamic> data) {
    return _tokens.save(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
  }

  AuthException _toException(DioException e) {
    final status = e.response?.statusCode;
    if (status == null) {
      return const AuthException(
        'Cannot reach the server. Check your connection and try again.',
      );
    }

    final message = _serverMessage(e.response?.data);
    return switch (status) {
      429 => const AuthException(
          'Too many attempts. Please wait a minute and try again.',
        ),
      >= 500 => const AuthException(
          'The server had a problem. Please try again.',
        ),
      _ => AuthException(message ?? 'Something went wrong. Please try again.'),
    };
  }

  String? _serverMessage(Object? data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String) return message;
      if (message is List) return message.join('\n');
    }
    return null;
  }
}