import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/animate_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../../data/models/directory_models.dart';
import '../../../data/models/user_role.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/user_filters_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/user_card.dart';
import '../widgets/user_filter_bar.dart';

/// Admin: the Users tab (everyone). Manager: the Team tab (direct reports).
class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  static const _adminChips = [
    UserFilter.all,
    UserFilter.admin,
    UserFilter.manager,
    UserFilter.employee,
    UserFilter.inactive,
  ];

  static const _managerChips = [
    UserFilter.all,
    UserFilter.active,
    UserFilter.inactive,
  ];

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(usersProvider);
    try {
      await ref.read(usersProvider.future);
    } catch (_) {
      // The error state is rendered by AsyncValueView.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(authProvider).user;
    final users = ref.watch(filteredUsersProvider);
    final filters = ref.watch(userFiltersProvider);

    // Briefly null while the router redirects after logout.
    if (me == null) return const SizedBox.shrink();

    final isAdmin = me.role == UserRole.admin;
    final section = isAdmin ? 'users' : 'team';

    final Widget emptyView = filters.isActive
        ? EmptyState(
            icon: Icons.search_off_rounded,
            title: 'No people found',
            message: 'Try a different search or clear your filters.',
            actionLabel: 'Clear filters',
            onAction: ref.read(userFiltersProvider.notifier).reset,
          )
        : EmptyState(
            icon: Icons.groups_outlined,
            title: isAdmin ? 'No users yet' : 'No team members yet',
            message: isAdmin
                ? 'Add your first user to get started.'
                : 'Employees assigned to you will appear here.',
          );

    return Scaffold(
      appBar: AppBar(title: Text(isAdmin ? 'Users' : 'My team')),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => context.go('/admin/users/new'),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Add user'),
            )
          : null,
      body: ResponsiveBody(
        maxWidth: 900,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UserFilterBar(
              chips: isAdmin ? _adminChips : _managerChips,
              resultCount: users.value?.length,
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: AsyncValueView<List<DirectoryUser>>(
                value: users,
                onRetry: () => ref.invalidate(usersProvider),
                loading: const _ListSkeleton(),
                isEmpty: (list) => list.isEmpty,
                empty: emptyView,
                data: (list) => RefreshIndicator(
                  onRefresh: () => _refresh(ref),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(bottom: isAdmin ? 88 : 24),
                    itemCount: list.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, i) {
                      final user = list[i];
                      return UserCard(
                        user: user,
                        onTap: () => context.go(
                          '${me.role.basePath}/$section/${user.id}',
                        ),
                      ).entrance(math.min(i, 5));
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (var i = 0; i < 4; i++) ...[
          const SkeletonBox(height: 150, radius: AppRadius.lg),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}