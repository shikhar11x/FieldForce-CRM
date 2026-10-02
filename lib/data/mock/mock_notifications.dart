import '../models/notification_models.dart';
import '../models/user_role.dart';

class MockNotifications {
  const MockNotifications._();

  static NotificationItem _n(
    String id,
    NotificationCategory category,
    String title,
    String message,
    Duration ago, {
    bool read = false,
    String? path,
    String? pathLabel,
  }) {
    return NotificationItem(
      id: id,
      category: category,
      title: title,
      message: message,
      timestamp: DateTime.now().subtract(ago),
      isRead: read,
      actionPath: path,
      actionLabel: pathLabel,
    );
  }

  static List<NotificationItem> forRole(UserRole role) => switch (role) {
        UserRole.admin => _admin(),
        UserRole.manager => _manager(),
        UserRole.employee => _employee(),
      };

  static List<NotificationItem> _employee() {
    const c = NotificationCategory.values;
    return [
      _n(
        'n1',
        NotificationCategory.tasks,
        'New task assigned',
        'Priya Sharma assigned you "Deliver product samples" for Apex '
            'Pharma. Due tomorrow at 11:00 AM.',
        const Duration(minutes: 5),
        path: '/employee/tasks/t4',
        pathLabel: 'View task',
      ),
      _n(
        'n2',
        NotificationCategory.visits,
        'Visit scheduled for 4:00 PM',
        'Bright Electricals: deliver the Q4 display kit at 21, Model Town '
            'Chowk.',
        const Duration(minutes: 40),
        path: '/employee/visits/v5',
        pathLabel: 'View visit',
      ),
      _n(
        'n3',
        NotificationCategory.attendance,
        'Attendance reminder',
        "You haven't checked in today. Check in to start tracking your "
            'working hours.',
        const Duration(hours: 2),
        path: '/employee/attendance',
        pathLabel: 'Open attendance',
      ),
      _n(
        'n4',
        NotificationCategory.leads,
        'Lead status updated',
        'Metro Hardware moved to Negotiation. Expected close in 9 days.',
        const Duration(hours: 3),
        path: '/employee/leads/l5',
        pathLabel: 'View lead',
      ),
      _n(
        'n5',
        NotificationCategory.tasks,
        'Task overdue',
        '"Share revised price list" for Bright Electricals was due two '
            'days ago.',
        const Duration(hours: 22),
        path: '/employee/tasks/t5',
        pathLabel: 'View task',
      ),
      _n(
        'n6',
        NotificationCategory.tasks,
        'Task due today',
        'Payment follow-up for Metro Hardware is due at 5:00 PM.',
        const Duration(hours: 26),
        read: true,
        path: '/employee/tasks/t3',
        pathLabel: 'View task',
      ),
      _n(
        'n7',
        NotificationCategory.visits,
        'Visit completed',
        'Your visit to Sunrise Traders was marked completed.',
        const Duration(hours: 30),
        read: true,
        path: '/employee/visits/v2',
        pathLabel: 'View visit',
      ),
      _n(
        'n8',
        NotificationCategory.leads,
        'New lead assigned',
        'Horizon Retail (₹6L) was assigned to you.',
        const Duration(days: 2),
        read: true,
        path: '/employee/leads/l9',
        pathLabel: 'View lead',
      ),
      _n(
        'n9',
        c.last,
        'App update available',
        'Version 1.1 improves route planning. Update when convenient.',
        const Duration(days: 3),
        read: true,
      ),
    ];
  }

  static List<NotificationItem> _manager() {
    return [
      _n(
        'n1',
        NotificationCategory.tasks,
        'Task completed',
        'Sneha Reddy completed "Install demo display unit" for Apex Pharma.',
        const Duration(minutes: 12),
        path: '/manager/tasks/t12',
        pathLabel: 'View task',
      ),
      _n(
        'n2',
        NotificationCategory.attendance,
        'Late check-in',
        'Imran Khan checked in at 10:42 AM.',
        const Duration(minutes: 35),
        path: '/manager/attendance',
        pathLabel: 'Open attendance',
      ),
      _n(
        'n3',
        NotificationCategory.leads,
        'Lead status updated',
        'Ocean Logistics (₹24L) moved to Negotiation.',
        const Duration(hours: 1),
        path: '/manager/leads/l3',
        pathLabel: 'View lead',
      ),
      _n(
        'n4',
        NotificationCategory.visits,
        'Visit scheduled',
        'Neha Kapoor has a volume pricing visit at Ocean Logistics in 3 '
            'days.',
        const Duration(hours: 2),
        path: '/manager/visits/v8',
        pathLabel: 'View visit',
      ),
      _n(
        'n5',
        NotificationCategory.tasks,
        'Task overdue',
        '"Re-activation call" for Lotus Stationers (Kavya Iyer) is overdue.',
        const Duration(hours: 5),
        read: true,
        path: '/manager/tasks/t10',
        pathLabel: 'View task',
      ),
      _n(
        'n6',
        NotificationCategory.attendance,
        'Attendance summary',
        'Team attendance yesterday was 92%, with 1 absence.',
        const Duration(hours: 28),
        read: true,
        path: '/manager/attendance',
        pathLabel: 'Open attendance',
      ),
      _n(
        'n7',
        NotificationCategory.visits,
        'Visit cancelled',
        'The Silverline Textiles follow-up visit was cancelled.',
        const Duration(days: 2),
        read: true,
        path: '/manager/visits/v11',
        pathLabel: 'View visit',
      ),
      _n(
        'n8',
        NotificationCategory.system,
        'Weekly report ready',
        'Your weekly team performance report is ready to view.',
        const Duration(days: 3),
        read: true,
        path: '/manager/reports',
        pathLabel: 'Open reports',
      ),
    ];
  }

  static List<NotificationItem> _admin() {
    return [
      _n(
        'n1',
        NotificationCategory.system,
        'New employee added',
        'Neha Kapoor joined Field Sales.',
        const Duration(minutes: 5),
      ),
      _n(
        'n2',
        NotificationCategory.leads,
        'Lead won',
        'Greenfield Foods closed for ₹3.2L.',
        const Duration(minutes: 30),
        path: '/admin/leads/l1',
        pathLabel: 'View lead',
      ),
      _n(
        'n3',
        NotificationCategory.visits,
        'Visit completed',
        'Rohan Verma completed a visit at Metro Hardware.',
        const Duration(hours: 1),
        path: '/admin/visits/v1',
        pathLabel: 'View visit',
      ),
      _n(
        'n4',
        NotificationCategory.attendance,
        'Attendance alert',
        '3 employees were marked late today.',
        const Duration(hours: 2),
        path: '/admin/attendance',
        pathLabel: 'Open attendance',
      ),
      _n(
        'n5',
        NotificationCategory.tasks,
        'Overdue tasks',
        '2 tasks across the team are overdue.',
        const Duration(hours: 4),
        read: true,
      ),
      _n(
        'n6',
        NotificationCategory.system,
        'Monthly report ready',
        'The monthly sales and attendance reports are ready.',
        const Duration(hours: 27),
        read: true,
        path: '/admin/reports',
        pathLabel: 'Open reports',
      ),
      _n(
        'n7',
        NotificationCategory.system,
        'Security notice',
        'A new device signed in to your account.',
        const Duration(days: 2),
        read: true,
      ),
      _n(
        'n8',
        NotificationCategory.leads,
        'Large deal in negotiation',
        'Ocean Logistics (₹24L) is in the negotiation stage.',
        const Duration(days: 3),
        read: true,
        path: '/admin/leads/l3',
        pathLabel: 'View lead',
      ),
    ];
  }
}