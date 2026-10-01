enum TaskPriority {
  low('Low'),
  medium('Medium'),
  high('High'),
  urgent('Urgent');

  const TaskPriority(this.label);
  final String label;
}

enum TaskStatus {
  pending('Pending'),
  inProgress('In Progress'),
  completed('Completed'),
  cancelled('Cancelled');

  const TaskStatus(this.label);
  final String label;
}

enum VisitStatus {
  scheduled('Scheduled'),
  started('Started'),
  completed('Completed'),
  cancelled('Cancelled');

  const VisitStatus(this.label);
  final String label;
}