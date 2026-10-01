import 'package:flutter/material.dart';

import '../../../core/extensions/datetime_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/dashboard_models.dart';

class ActivityFeed extends StatelessWidget {
  const ActivityFeed({super.key, required this.items});

  final List<ActivityItem> items;

  (IconData, Color) _styleFor(ActivityType type) => switch (type) {
        ActivityType.employeeAdded =>
          (Icons.person_add_alt_1_rounded, AppColors.primary),
        ActivityType.customerCreated =>
          (Icons.business_center_rounded, AppColors.secondary),
        ActivityType.visitCompleted =>
          (Icons.check_circle_rounded, AppColors.success),
        ActivityType.taskAssigned =>
          (Icons.assignment_ind_rounded, AppColors.warning),
        ActivityType.leadConverted =>
          (Icons.trending_up_rounded, AppColors.accent),
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (items.isEmpty) {
      return const AppCard(
        child: EmptyState(
          icon: Icons.history_rounded,
          title: 'No recent activity',
          message: 'Updates from your team will show up here.',
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        children: [
          for (final (i, item) in items.indexed) ...[
            if (i > 0) const Divider(indent: 72),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _styleFor(item.type).$2.withValues(alpha: 0.12),
                  borderRadius: AppRadius.mdAll,
                ),
                child: Icon(
                  _styleFor(item.type).$1,
                  color: _styleFor(item.type).$2,
                  size: 20,
                ),
              ),
              title: Text(item.title, style: theme.textTheme.titleSmall),
              subtitle: Text(
                item.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                item.timestamp.timeAgo,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}