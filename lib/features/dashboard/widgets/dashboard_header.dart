import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_navigation.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../data/models/app_user.dart';
import '../../auth/widgets/logout_dialog.dart';
import '../../notifications/providers/notification_provider.dart';

enum _MenuAction { profile, settings, theme, logout }

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key, required this.user});

  final AppUser user;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = theme.colorScheme.onSurfaceVariant;
    final unread = ref.watch(unreadNotificationCountProvider);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_greeting,',
                style: theme.textTheme.bodyMedium?.copyWith(color: muted),
              ),
              Text(
                user.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.business_rounded, size: 14, color: muted),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      user.organization,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Badge(
          isLabelVisible: unread > 0,
          label: Text(unread > 99 ? '99+' : '$unread'),
          child: IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () =>
                context.push('${user.role.basePath}/notifications'),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        PopupMenuButton<_MenuAction>(
          tooltip: 'Account',
          offset: const Offset(0, 48),
          onSelected: (action) {
            switch (action) {
              case _MenuAction.profile:
                context.openProfile(user.role);
              case _MenuAction.settings:
                context.openSettings(user.role);
              case _MenuAction.theme:
                ref.read(themeModeProvider.notifier).set(
                      isDark ? ThemeMode.light : ThemeMode.dark,
                    );
              case _MenuAction.logout:
                confirmAndLogout(context, ref);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: _MenuAction.profile,
              child: Row(
                children: [
                  Icon(Icons.person_outline_rounded),
                  SizedBox(width: AppSpacing.md),
                  Text('Profile'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: _MenuAction.settings,
              child: Row(
                children: [
                  Icon(Icons.settings_outlined),
                  SizedBox(width: AppSpacing.md),
                  Text('Settings'),
                ],
              ),
            ),
            PopupMenuItem(
              value: _MenuAction.theme,
              child: Row(
                children: [
                  Icon(
                    isDark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(isDark ? 'Light theme' : 'Dark theme'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: _MenuAction.logout,
              child: Row(
                children: [
                  Icon(Icons.logout_rounded),
                  SizedBox(width: AppSpacing.md),
                  Text('Log out'),
                ],
              ),
            ),
          ],
          child: CircleAvatar(
            radius: 20,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.14),
            child: Text(
              user.initials,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}