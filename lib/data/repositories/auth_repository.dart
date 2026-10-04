import '../models/app_user.dart';
import '../models/user_role.dart';

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

abstract class AuthRepository {
  Future<AppUser> login({required String email, required String password});
  Future<AppUser> loginAsDemo(UserRole role);

  /// Stored tokens se user wapas laata hai. Null = login chahiye.
  Future<AppUser?> restoreSession();
  Future<AppUser> updateProfile(AppUser user);
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<void> logout();
}