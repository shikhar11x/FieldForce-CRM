import 'package:flutter/material.dart';

import '../../../core/extensions/datetime_extensions.dart';
import '../../../core/extensions/notification_style_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/models/notification_models.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final NotificationItem notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final n = notification;
    final color = n.category.color;

    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadius.mdAll,
            ),
            child: Icon(n.category.icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  n.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  n.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${n.category.label} · ${n.timestamp.timeAgo}',
                  style: theme.textTheme.labelSmall?.copyWith(color: muted),
                ),
              ],
            ),
          ),
          if (!n.isRead)
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm, top: 4),
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}