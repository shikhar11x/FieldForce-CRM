import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/notification_models.dart';
import 'notification_provider.dart';

class NotificationFilters {
  const NotificationFilters({this.category, this.unreadOnly = false});

  /// Null means "All".
  final NotificationCategory? category;
  final bool unreadOnly;

  bool get isActive => category != null || unreadOnly;
}

class NotificationFiltersNotifier extends Notifier<NotificationFilters> {
  @override
  NotificationFilters build() => const NotificationFilters();

  void setCategory(NotificationCategory? category) => state =
      NotificationFilters(category: category, unreadOnly: state.unreadOnly);

  void setUnreadOnly(bool unreadOnly) => state =
      NotificationFilters(category: state.category, unreadOnly: unreadOnly);

  void reset() => state = const NotificationFilters();
}

final notificationFiltersProvider =
    NotifierProvider<NotificationFiltersNotifier, NotificationFilters>(
  NotificationFiltersNotifier.new,
);

/// Filtered and sorted newest first.
final filteredNotificationsProvider =
    Provider.autoDispose<AsyncValue<List<NotificationItem>>>((ref) {
  final all = ref.watch(notificationsProvider);
  final f = ref.watch(notificationFiltersProvider);

  return all.whenData((list) {
    final result = list
        .where(
          (n) =>
              (f.category == null || n.category == f.category) &&
              (!f.unreadOnly || !n.isRead),
        )
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return result;
  });
});

/// Count on each category chip. Respects "Unread only". The `null` key is
/// the "All" chip.
final notificationCategoryCountsProvider =
    Provider.autoDispose<Map<NotificationCategory?, int>>((ref) {
  final items =
      ref.watch(notificationsProvider).value ?? const <NotificationItem>[];
  final unreadOnly =
      ref.watch(notificationFiltersProvider.select((f) => f.unreadOnly));

  final base = unreadOnly ? items.where((n) => !n.isRead).toList() : items;

  return {
    null: base.length,
    for (final c in NotificationCategory.values)
      c: base.where((n) => n.category == c).length,
  };
});