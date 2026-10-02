import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/models/notification_models.dart';
import '../providers/notification_filters_provider.dart';
import '../providers/notification_provider.dart';

/// Category chips (with counts) and an "Unread only" toggle.
class NotificationFilterBar extends ConsumerWidget {
  const NotificationFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filters = ref.watch(notificationFiltersProvider);
    final notifier = ref.read(notificationFiltersProvider.notifier);
    final counts = ref.watch(notificationCategoryCountsProvider);
    final unread = ref.watch(unreadNotificationCountProvider);
    final tabs = <NotificationCategory?>[null, ...NotificationCategory.values];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: tabs.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, i) {
              final category = tabs[i];
              final label = category?.label ?? 'All';
              return ChoiceChip(
                label: Text('$label ${counts[category] ?? 0}'),
                selected: filters.category == category,
                showCheckmark: false,
                onSelected: (_) => notifier.setCategory(category),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: Text(
                unread == 0 ? 'All caught up' : '$unread unread',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            FilterChip(
              label: const Text('Unread only'),
              selected: filters.unreadOnly,
              onSelected: notifier.setUnreadOnly,
            ),
          ],
        ),
      ],
    );
  }
}