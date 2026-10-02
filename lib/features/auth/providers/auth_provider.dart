import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/app_user.dart';
import '../../../data/models/user_role.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/mock_auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => MockAuthRepository(),
);

class AuthState {
  const AuthState({this.user, this.isLoading = false, this.error});

  final AppUser? user;
  final bool isLoading;
  final String? error;

  bool get isAuthenticated => user != null;
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> login({required String email, required String password}) {
    return _run(() => _repo.login(email: email, password: password));
  }

  Future<void> loginAsDemo(UserRole role) {
    return _run(() => _repo.loginAsDemo(role));
  }

  /// Saves editable profile fields. Doesn't go through `_run`, because
  /// that briefly clears the user and would bounce the app to Login.
  Future<void> updateProfile({
    required String email,
    required String phone,
  }) async {
    final current = state.user;
    if (current == null) return;

    final saved = await _repo.updateProfile(
      current.copyWith(email: email, phone: phone),
    );
    state = AuthState(user: saved);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _repo.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState();
  }

  Future<void> _run(Future<AppUser> Function() action) async {
    state = const AuthState(isLoading: true);
    try {
      final user = await action();
      state = AuthState(user: user);
    } on AuthException catch (e) {
      state = AuthState(error: e.message);
    }
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);