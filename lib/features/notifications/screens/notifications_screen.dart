import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../../data/models/notification_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/notification_filters_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_filter_bar.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(notificationsProvider);
    try {
      await ref.read(notificationsProvider.future);
    } catch (_) {
      // The error state is rendered by AsyncValueView.
    }
  }

  Future<void> _clearAll(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear all notifications?'),
        content: const Text(
          'This removes every notification from your list. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep them'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await ref.read(notificationsProvider.notifier).clearAll();
    if (context.mounted) context.showSnack('All notifications cleared.');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final items = ref.watch(filteredNotificationsProvider);
    final filters = ref.watch(notificationFiltersProvider);
    final all =
        ref.watch(notificationsProvider).value ?? const <NotificationItem>[];
    final unread = ref.watch(unreadNotificationCountProvider);

    // Briefly null while the router redirects after logout.
    if (user == null) return const SizedBox.shrink();

    final Widget emptyView = filters.isActive
        ? EmptyState(
            icon: Icons.search_off_rounded,
            title: 'No notifications found',
            message: 'Try a different category or clear your filters.',
            actionLabel: 'Clear filters',
            onAction: ref.read(notificationFiltersProvider.notifier).reset,
          )
        : const EmptyState(
            icon: Icons.notifications_off_outlined,
            title: 'No notifications',
            message: "You're all caught up. New alerts will appear here.",
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            tooltip: 'Mark all as read',
            icon: const Icon(Icons.done_all_rounded),
            onPressed: unread == 0
                ? null
                : () {
                    ref.read(notificationsProvider.notifier).markAllRead();
                    context.showSnack('All notifications marked as read.');
                  },
          ),
          IconButton(
            tooltip: 'Clear all',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: all.isEmpty ? null : () => _clearAll(context, ref),
          ),
        ],
      ),
      body: ResponsiveBody(
        maxWidth: 700,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const NotificationFilterBar(),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: AsyncValueView<List<NotificationItem>>(
                value: items,
                onRetry: () => ref.invalidate(notificationsProvider),
                loading: const _ListSkeleton(),
                isEmpty: (list) => list.isEmpty,
                empty: emptyView,
                data: (list) => RefreshIndicator(
                  onRefresh: () => _refresh(ref),
                  child: _NotificationList(
                    items: list,
                    basePath: user.role.basePath,
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

String _groupOf(DateTime time) {
  final now = DateTime.now();
  final today = DateTime.utc(now.year, now.month, now.day);
  final day = DateTime.utc(time.year, time.month, time.day);
  final diff = today.difference(day).inDays;

  if (diff <= 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  return 'Earlier';
}

class _NotificationList extends ConsumerWidget {
  const _NotificationList({required this.items, required this.basePath});

  final List<NotificationItem> items;
  final String basePath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Group headers are interleaved with notifications.
    final entries = <Object>[];
    String? lastGroup;
    for (final item in items) {
      final group = _groupOf(item.timestamp);
      if (group != lastGroup) {
        entries.add(group);
        lastGroup = group;
      }
      entries.add(item);
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final entry = entries[i];

        if (entry is String) {
          return Padding(
            padding: EdgeInsets.only(
              top: i == 0 ? 0 : AppSpacing.lg,
              bottom: AppSpacing.sm,
            ),
            child: Text(
              entry,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        final n = entry as NotificationItem;
        return Padding(
          key: ValueKey(n.id),
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: ClipRRect(
            borderRadius: AppRadius.lgAll,
            child: Dismissible(
              key: ValueKey('dismiss-${n.id}'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: AppSpacing.xl),
                color: AppColors.error,
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white,
                ),
              ),
              onDismissed: (_) {
                final notifier = ref.read(notificationsProvider.notifier);
                notifier.delete(n.id);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: const Text('Notification deleted.'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () => notifier.restore(n),
                      ),
                    ),
                  );
              },
              child: NotificationTile(
                notification: n,
                onTap: () {
                  ref.read(notificationsProvider.notifier).markRead(n.id);
                  context.push('$basePath/notifications/${n.id}');
                },
              ),
            ),
          ),
        );
      },
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
        for (var i = 0; i < 5; i++) ...[
          const SkeletonBox(height: 96, radius: AppRadius.lg),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}