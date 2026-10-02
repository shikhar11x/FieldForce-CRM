import 'package:flutter/material.dart';

import '../../../core/extensions/user_role_style_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/icon_text.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/directory_models.dart';

class UserCard extends StatelessWidget {
  const UserCard({super.key, required this.user, required this.onTap});

  final DirectoryUser user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              InitialsAvatar(name: user.name),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    Text(
                      user.designation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              StatusChip(
                label: user.isActive ? 'Active' : 'Inactive',
                color: user.isActive
                    ? AppColors.success
                    : AppColors.lightTextSecondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              StatusChip(label: user.role.label, color: user.role.color),
              if (user.team.isNotEmpty)
                StatusChip(label: user.team, color: theme.colorScheme.primary),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          IconText(icon: Icons.mail_outline_rounded, text: user.email),
          const SizedBox(height: 4),
          IconText(icon: Icons.phone_outlined, text: user.phone),
        ],
      ),
    );
  }
}