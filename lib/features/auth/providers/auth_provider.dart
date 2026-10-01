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