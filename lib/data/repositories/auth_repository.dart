import '../models/app_user.dart';
import '../models/user_role.dart';

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Phase 2 swaps the mock implementation for an API-backed one.
abstract class AuthRepository {
  Future<AppUser> login({required String email, required String password});
  Future<AppUser> loginAsDemo(UserRole role);
  Future<void> logout();
}