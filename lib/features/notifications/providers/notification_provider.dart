import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/notification_models.dart';
import '../../../data/repositories/mock_notification_repository.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../auth/providers/auth_provider.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => MockNotificationRepository(),
);

/// Holds the user's notifications for the session. State updates first so
/// the UI feels instant, then the repository call follows. Reloads when
/// the signed-in role changes.
class NotificationsNotifier extends AsyncNotifier<List<NotificationItem>> {
  NotificationRepository get _repo => ref.read(notificationRepositoryProvider);

  List<NotificationItem> get _current =>
      state.value ?? const <NotificationItem>[];

  @override
  Future<List<NotificationItem>> build() async {
    final role = ref.watch(authProvider.select((s) => s.user?.role));
    if (role == null) return const <NotificationItem>[];
    return ref.watch(notificationRepositoryProvider).getNotifications(role);
  }

  Future<void> markRead(String id) async {
    final item = findNotification(_current, id);
    if (item == null || item.isRead) return;

    state = AsyncData([
      for (final n in _current)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ]);
    await _repo.markRead(id);
  }

  Future<void> markAllRead() async {
    if (!_current.any((n) => !n.isRead)) return;

    state = AsyncData([for (final n in _current) n.copyWith(isRead: true)]);
    await _repo.markAllRead();
  }

  Future<void> delete(String id) async {
    state = AsyncData([
      for (final n in _current)
        if (n.id != id) n,
    ]);
    await _repo.delete(id);
  }

  /// Puts a deleted notification back (used by the Undo action).
  Future<void> restore(NotificationItem item) async {
    if (_current.any((n) => n.id == item.id)) return;

    state = AsyncData([..._current, item]);
    await _repo.restore(item);
  }

  Future<void> clearAll() async {
    state = AsyncData(const <NotificationItem>[]);
    await _repo.clearAll();
  }
}

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<NotificationItem>>(
  NotificationsNotifier.new,
);

/// Drives the badge on the dashboard bell.
final unreadNotificationCountProvider = Provider<int>((ref) {
  final items = ref.watch(notificationsProvider).value;
  if (items == null) return 0;
  return items.where((n) => !n.isRead).length;
});

NotificationItem? findNotification(List<NotificationItem> items, String id) {
  for (final item in items) {
    if (item.id == id) return item;
  }
  return null;
}