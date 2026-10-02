import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/directory_models.dart';
import '../../../data/models/user_role.dart';
import '../../auth/providers/auth_provider.dart';
import 'user_provider.dart';

enum UserFilter {
  all('All'),
  active('Active'),
  inactive('Inactive'),
  admin('Admins'),
  manager('Managers'),
  employee('Employees');

  const UserFilter(this.label);
  final String label;
}

class UserFilters {
  const UserFilters({this.query = '', this.filter = UserFilter.all});

  final String query;
  final UserFilter filter;

  bool get isActive => query.trim().isNotEmpty || filter != UserFilter.all;
}

class UserFiltersNotifier extends Notifier<UserFilters> {
  @override
  UserFilters build() {
    // Starts fresh whenever a different role signs in.
    ref.watch(authProvider.select((s) => s.user?.role));
    return const UserFilters();
  }

  void setQuery(String query) =>
      state = UserFilters(query: query, filter: state.filter);

  void setFilter(UserFilter filter) =>
      state = UserFilters(query: state.query, filter: filter);

  void reset() => state = const UserFilters();
}

final userFiltersProvider =
    NotifierProvider<UserFiltersNotifier, UserFilters>(
  UserFiltersNotifier.new,
);

bool _matchesFilter(DirectoryUser u, UserFilter f) => switch (f) {
      UserFilter.all => true,
      UserFilter.active => u.isActive,
      UserFilter.inactive => !u.isActive,
      UserFilter.admin => u.role == UserRole.admin,
      UserFilter.manager => u.role == UserRole.manager,
      UserFilter.employee => u.role == UserRole.employee,
    };

bool _matchesQuery(DirectoryUser u, String query) {
  if (query.isEmpty) return true;
  return [
    u.name,
    u.email,
    u.phone,
    u.designation,
    u.department,
    u.team,
    u.employeeId,
  ].any((value) => value.toLowerCase().contains(query));
}

final filteredUsersProvider =
    Provider.autoDispose<AsyncValue<List<DirectoryUser>>>((ref) {
  final users = ref.watch(scopedUsersProvider);
  final f = ref.watch(userFiltersProvider);
  final query = f.query.trim().toLowerCase();

  return users.whenData((list) {
    final result = list
        .where((u) => _matchesFilter(u, f.filter) && _matchesQuery(u, query))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return result;
  });
});

/// Count on each filter chip. Respects the search text.
final userFilterCountsProvider =
    Provider.autoDispose<Map<UserFilter, int>>((ref) {
  final users =
      ref.watch(scopedUsersProvider).value ?? const <DirectoryUser>[];
  final query = ref.watch(userFiltersProvider).query.trim().toLowerCase();
  final base = users.where((u) => _matchesQuery(u, query)).toList();

  return {
    for (final f in UserFilter.values)
      f: base.where((u) => _matchesFilter(u, f)).length,
  };
});