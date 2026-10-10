enum TaskPriority {
  low('Low', 'LOW'),
  medium('Medium', 'MEDIUM'),
  high('High', 'HIGH'),
  urgent('Urgent', 'URGENT');

  const TaskPriority(this.label, this.apiValue);
  final String label;
  final String apiValue;

  static TaskPriority fromApi(String value) => TaskPriority.values.firstWhere(
        (p) => p.apiValue == value,
        orElse: () => TaskPriority.medium,
      );
}

enum TaskStatus {
  pending('Pending', 'PENDING'),
  inProgress('In Progress', 'IN_PROGRESS'),
  completed('Completed', 'COMPLETED'),
  cancelled('Cancelled', 'CANCELLED');

  const TaskStatus(this.label, this.apiValue);
  final String label;
  final String apiValue;

  static TaskStatus fromApi(String value) => TaskStatus.values.firstWhere(
        (s) => s.apiValue == value,
        orElse: () => TaskStatus.pending,
      );
}

enum VisitStatus {
  scheduled('Scheduled'),
  started('Started'),
  completed('Completed'),
  cancelled('Cancelled');

  const VisitStatus(this.label);
  final String label;
}