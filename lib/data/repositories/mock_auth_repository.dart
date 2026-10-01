import '../../core/constants/app_constants.dart';
import '../mock/mock_users.dart';
import '../models/app_user.dart';
import '../models/user_role.dart';
import 'auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    final normalized = email.trim().toLowerCase();
    final match =
        MockUsers.all.where((u) => u.email.toLowerCase() == normalized);

    if (match.isEmpty || password != AppConstants.demoPassword) {
      throw const AuthException('Invalid email or password.');
    }
    return match.first;
  }

  @override
  Future<AppUser> loginAsDemo(UserRole role) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return MockUsers.byRole(role);
  }

  @override
  Future<void> logout() async {}
}