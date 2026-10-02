import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/datetime_extensions.dart';
import '../../../core/routing/app_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/detail_row.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/settings_tile.dart';
import '../../../core/widgets/status_chip.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/widgets/logout_dialog.dart';

/// Employee: the Profile tab. Admin and Manager: a full-screen page
/// from the avatar menu.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    // Briefly null while the router redirects after logout.
    if (user == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final base = user.role.basePath;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ResponsiveBody(
        maxWidth: 700,
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          children: [
            AppCard(
              child: Column(
                children: [
                  Stack(
                    children: [
                      InitialsAvatar(name: user.name, radius: 44),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Material(
                          color: scheme.primary,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => context.showSnack(
                              'Profile photo upload arrives in Phase 2.',
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.photo_camera_rounded,
                                size: 16,
                                color: scheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(user.name, style: theme.textTheme.titleLarge),
                  Text(
                    user.email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  StatusChip(label: user.role.label, color: scheme.primary),
                ],
              ),
            ),
            const SectionHeader(title: 'Personal information'),
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
                  DetailRow(
                    icon: Icons.badge_outlined,
                    label: 'Employee ID',
                    value: user.employeeId,
                  ),
                  DetailRow(
                    icon: Icons.verified_user_outlined,
                    label: 'Role',
                    value: user.role.label,
                  ),
                  DetailRow(
                    icon: Icons.account_tree_outlined,
                    label: 'Department',
                    value: user.department,
                  ),
                  DetailRow(
                    icon: Icons.business_rounded,
                    label: 'Organization',
                    value: user.organization,
                  ),
                  DetailRow(
                    icon: Icons.event_rounded,
                    label: 'Joining date',
                    value: user.joiningDate.shortDate,
                  ),
                ],
              ),
            ),
            const SectionHeader(title: 'Account'),
            SettingsGroup(
              children: [
                SettingsTile(
                  icon: Icons.edit_outlined,
                  title: 'Edit profile',
                  subtitle: 'Update your email and phone',
                  onTap: () => context.push('$base/profile/edit'),
                ),
                SettingsTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Change password',
                  onTap: () => context.push('$base/profile/password'),
                ),
                SettingsTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notification settings',
                  onTap: () => context.push('$base/settings/notifications'),
                ),
                SettingsTile(
                  icon: Icons.settings_outlined,
                  title: 'App settings',
                  onTap: () => context.openSettings(user.role),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton.icon(
              onPressed: () => confirmAndLogout(context, ref),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }
}