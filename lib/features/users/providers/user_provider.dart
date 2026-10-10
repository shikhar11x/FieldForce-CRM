import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/api_config.dart';
import '../../../core/network/api_providers.dart';
import '../../../data/models/directory_models.dart';
import '../../../data/models/user_role.dart';
import '../../../data/repositories/api_user_repository.dart';
import '../../../data/repositories/mock_user_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../auth/providers/auth_provider.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  if (ApiConfig.useMockAuth) return MockUserRepository();
  return ApiUserRepository(ref.watch(apiClientProvider));
});

/// Holds the directory for the session. Writes go through the repository.
class UsersNotifier extends AsyncNotifier<List<DirectoryUser>> {
  UserRepository get _repo => ref.read(userRepositoryProvider);

  List<DirectoryUser> get _current =>
      state.value ?? const <DirectoryUser>[];

  @override
  Future<List<DirectoryUser>> build() {
    return ref.watch(userRepositoryProvider).getUsers();
  }

  Future<CreatedUser> addUser(DirectoryUser user) async {
    final created = await _repo.createUser(user);
    state = AsyncData([created.user, ..._current]);
    return created;
  }

  Future<void> saveUser(DirectoryUser user) async {
    final saved = await _repo.updateUser(user);
    state = AsyncData([
      for (final u in _current)
        if (u.id == saved.id) saved else u,
    ]);
  }

  Future<void> setActive(DirectoryUser user, bool active) {
    return saveUser(user.copyWith(isActive: active));
  }
}

final usersProvider =
    AsyncNotifierProvider<UsersNotifier, List<DirectoryUser>>(
  UsersNotifier.new,
);

/// Admin sees everyone. A manager sees only their direct reports (the
/// server already scopes this; the filter keeps mock mode consistent).
final scopedUsersProvider =
    Provider.autoDispose<AsyncValue<List<DirectoryUser>>>((ref) {
  final users = ref.watch(usersProvider);
  final me = ref.watch(authProvider).user;

  return users.whenData((list) {
    if (me == null || me.role == UserRole.admin) return list;
    return list
        .where((u) => u.role == UserRole.employee && u.manager == me.name)
        .toList();
  });
});

DirectoryUser? findUser(List<DirectoryUser> users, String id) {
  for (final user in users) {
    if (user.id == id) return user;
  }
  return null;
}