import '../mock/mock_notifications.dart';
import '../models/notification_models.dart';
import '../models/user_role.dart';
import 'notification_repository.dart';

class MockNotificationRepository implements NotificationRepository {
  Future<void> _latency() =>
      Future<void>.delayed(const Duration(milliseconds: 150));

  @override
  Future<List<NotificationItem>> getNotifications(UserRole role) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return MockNotifications.forRole(role);
  }

  @override
  Future<void> markRead(String id) => _latency();

  @override
  Future<void> markAllRead() => _latency();

  @override
  Future<void> delete(String id) => _latency();

  @override
  Future<void> restore(NotificationItem item) => _latency();

  @override
  Future<void> clearAll() => _latency();
}