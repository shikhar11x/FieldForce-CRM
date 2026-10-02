enum NotificationCategory {
  tasks('Tasks'),
  visits('Visits'),
  attendance('Attendance'),
  leads('Leads'),
  system('System');

  const NotificationCategory(this.label);
  final String label;
}

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.category,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    this.actionPath,
    this.actionLabel,
  });

  final String id;
  final NotificationCategory category;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  /// App route of the related screen (e.g. `/employee/tasks/t4`).
  final String? actionPath;
  final String? actionLabel;

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      category: category,
      title: title,
      message: message,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      actionPath: actionPath,
      actionLabel: actionLabel,
    );
  }
}