import '../models/notification_models.dart';
import '../models/user_role.dart';

/// Phase 2 swaps the mock implementation for an API-backed one and adds
/// push delivery (FCM) behind the same interface.
abstract class NotificationRepository {
  Future<List<NotificationItem>> getNotifications(UserRole role);
  Future<void> markRead(String id);
  Future<void> markAllRead();
  Future<void> delete(String id);
  Future<void> restore(NotificationItem item);
  Future<void> clearAll();
}