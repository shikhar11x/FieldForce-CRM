import '../../core/constants/app_constants.dart';
import '../mock/mock_users.dart';
import '../models/app_user.dart';
import '../models/user_role.dart';
import 'auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  // Edits and the changed password live for the session only.
  final Map<String, AppUser> _saved = {};
  String _password = AppConstants.demoPassword;

  AppUser _resolve(AppUser user) => _saved[user.id] ?? user;

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    final normalized = email.trim().toLowerCase();
    final match = [
      for (final u in MockUsers.all) _resolve(u),
    ].where((u) => u.email.toLowerCase() == normalized);

    if (match.isEmpty || password != _password) {
      throw const AuthException('Invalid email or password.');
    }
    return match.first;
  }

  @override
  Future<AppUser> loginAsDemo(UserRole role) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _resolve(MockUsers.byRole(role));
  }

  @override
  Future<AppUser> updateProfile(AppUser user) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _saved[user.id] = user;
    return user;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (currentPassword != _password) {
      throw const AuthException('Your current password is incorrect.');
    }
    _password = newPassword;
  }

  @override
  Future<void> logout() async {}
}