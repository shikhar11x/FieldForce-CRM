import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/datetime_extensions.dart';
import '../../../core/extensions/notification_style_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/detail_row.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/notification_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/notification_provider.dart';

class NotificationDetailScreen extends ConsumerStatefulWidget {
  const NotificationDetailScreen({super.key, required this.notificationId});

  final String notificationId;

  @override
  ConsumerState<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState
    extends ConsumerState<NotificationDetailScreen> {
  // Kept so the page doesn't flash "not found" while it closes after a delete.
  NotificationItem? _last;

  void _delete(NotificationItem item) {
    final messenger = ScaffoldMessenger.of(context);
    ref.read(notificationsProvider.notifier).delete(item.id);
    context.pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Notification deleted.')));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final notifications = ref.watch(notificationsProvider);

    // Briefly null while the router redirects after logout.
    if (user == null) return const SizedBox.shrink();

    final list = notifications.value;
    final found =
        list == null ? null : findNotification(list, widget.notificationId);
    if (found != null) _last = found;
    final item = found ?? _last;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification'),
        actions: [
          if (item != null)
            IconButton(
              tooltip: 'Delete notification',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => _delete(item),
            ),
        ],
      ),
      body: ResponsiveBody(
        maxWidth: 600,
        child: AsyncValueView<List<NotificationItem>>(
          value: notifications,
          onRetry: () => ref.invalidate(notificationsProvider),
          loading: const _DetailSkeleton(),
          data: (_) => item == null
              ? const EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'Notification not found',
                  message: 'It may have been deleted.',
                )
              : _DetailContent(item: item, onDelete: () => _delete(item)),
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.item, required this.onDelete});

  final NotificationItem item;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = item.category.color;
    final path = item.actionPath;
    final received = '${item.timestamp.dayLabel}, '
        '${TimeOfDay.fromDateTime(item.timestamp).format(context)}';

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: AppRadius.mdAll,
                    ),
                    child: Icon(item.category.icon, color: color),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  StatusChip(label: item.category.label, color: color),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(item.title, style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(item.message, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
        const SectionHeader(title: 'Details'),
        AppCard(
          child: Column(
            children: [
              DetailRow(
                icon: item.category.icon,
                label: 'Category',
                value: item.category.label,
              ),
              DetailRow(
                icon: Icons.schedule_rounded,
                label: 'Received',
                value: received,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        if (path != null) ...[
          FilledButton.icon(
            onPressed: () => context.go(path),
            icon: const Icon(Icons.open_in_new_rounded),
            label: Text(item.actionLabel ?? 'Open'),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        OutlinedButton.icon(
          onPressed: onDelete,
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
          icon: const Icon(Icons.delete_outline_rounded),
          label: const Text('Delete notification'),
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
        SkeletonBox(height: 170, radius: AppRadius.lg),
        SizedBox(height: AppSpacing.lg),
        SkeletonBox(height: 100, radius: AppRadius.lg),
      ],
    );
  }
}