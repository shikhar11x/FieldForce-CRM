import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/datetime_extensions.dart';
import '../../../core/extensions/user_role_style_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/detail_row.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/directory_models.dart';
import '../../../data/models/user_role.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/user_provider.dart';

class UserDetailScreen extends ConsumerWidget {
  const UserDetailScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(authProvider).user;
    final users = ref.watch(usersProvider);

    // Briefly null while the router redirects after logout.
    if (me == null) return const SizedBox.shrink();

    final isAdmin = me.role == UserRole.admin;
    final list = users.value;
    final user = list == null ? null : findUser(list, userId);

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'User details' : 'Team member'),
        actions: [
          if (user != null && isAdmin)
            IconButton(
              tooltip: 'Edit user',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.go('/admin/users/$userId/edit'),
            ),
        ],
      ),
      body: ResponsiveBody(
        maxWidth: 700,
        child: AsyncValueView<List<DirectoryUser>>(
          value: users,
          onRetry: () => ref.invalidate(usersProvider),
          loading: const _DetailSkeleton(),
          data: (_) => user == null
              ? const EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'User not found',
                  message: 'They may have been removed.',
                )
              : _DetailContent(user: user, isAdmin: isAdmin),
        ),
      ),
    );
  }
}

class _DetailContent extends ConsumerStatefulWidget {
  const _DetailContent({required this.user, required this.isAdmin});

  final DirectoryUser user;
  final bool isAdmin;

  @override
  ConsumerState<_DetailContent> createState() => _DetailContentState();
}

class _DetailContentState extends ConsumerState<_DetailContent> {
  bool _busy = false;

  Future<void> _toggleActive() async {
    final user = widget.user;
    final deactivating = user.isActive;

    if (deactivating) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Deactivate ${user.name}?'),
          content: const Text(
            'They will no longer be able to sign in. You can reactivate '
            'them at any time.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Deactivate'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }

    setState(() => _busy = true);
    try {
      await ref.read(usersProvider.notifier).setActive(user, !deactivating);
      if (mounted) {
        context.showSnack(
          deactivating ? '${user.name} deactivated.' : '${user.name} reactivated.',
        );
      }
    } catch (_) {
      if (mounted) {
        context.showSnack('Could not update the user. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = widget.user;

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        AppCard(
          child: Row(
            children: [
              InitialsAvatar(name: user.name, radius: 30),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: theme.textTheme.titleLarge),
                    Text(
                      user.designation,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        StatusChip(
                          label: user.role.label,
                          color: user.role.color,
                        ),
                        StatusChip(
                          label: user.isActive ? 'Active' : 'Inactive',
                          color: user.isActive
                              ? AppColors.success
                              : AppColors.lightTextSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SectionHeader(title: 'Contact'),
        AppCard(
          child: Column(
            children: [
              DetailRow(
                icon: Icons.mail_outline_rounded,
                label: 'Email',
                value: user.email,
              ),
              DetailRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: user.phone,
              ),
            ],
          ),
        ),
        const SectionHeader(title: 'Work'),
        AppCard(
          child: Column(
            children: [
              DetailRow(
                icon: Icons.badge_outlined,
                label: 'Employee ID',
                value: user.employeeId,
              ),
              DetailRow(
                icon: Icons.account_tree_outlined,
                label: 'Department',
                value: user.department,
              ),
              if (user.team.isNotEmpty)
                DetailRow(
                  icon: Icons.groups_rounded,
                  label: 'Team',
                  value: user.team,
                ),
              if (user.manager.isNotEmpty)
                DetailRow(
                  icon: Icons.supervisor_account_outlined,
                  label: 'Reports to',
                  value: user.manager,
                ),
              DetailRow(
                icon: Icons.event_rounded,
                label: 'Joining date',
                value: user.joiningDate.shortDate,
              ),
            ],
          ),
        ),
        const SectionHeader(title: 'Actions'),
        Row(
          children: [
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () => context.showSnack(
                  'Calling ${user.phone} is wired up in Phase 2.',
                ),
                icon: const Icon(Icons.call_rounded),
                label: const Text('Call'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () => context.showSnack(
                  'Emailing ${user.email} is wired up in Phase 2.',
                ),
                icon: const Icon(Icons.mail_rounded),
                label: const Text('Email'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (widget.isAdmin) ...[
          OutlinedButton.icon(
            onPressed: () => context.go('/admin/users/${user.id}/edit'),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit user'),
          ),
          const SizedBox(height: AppSpacing.sm),
          user.isActive
              ? OutlinedButton.icon(
                  onPressed: _busy ? null : _toggleActive,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                  icon: const Icon(Icons.person_off_outlined),
                  label: const Text('Deactivate user'),
                )
              : FilledButton.icon(
                  onPressed: _busy ? null : _toggleActive,
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: const Text('Reactivate user'),
                ),
        ] else if (user.isActive)
          FilledButton.icon(
            onPressed: () => context.go('/manager/tasks/new'),
            icon: const Icon(Icons.add_task_rounded),
            label: const Text('Assign a task'),
          ),
      ],
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SkeletonBox(height: 110, radius: AppRadius.lg),
        SizedBox(height: AppSpacing.lg),
        SkeletonBox(height: 100, radius: AppRadius.lg),
        SizedBox(height: AppSpacing.lg),
        SkeletonBox(height: 200, radius: AppRadius.lg),
      ],
    );
  }
}