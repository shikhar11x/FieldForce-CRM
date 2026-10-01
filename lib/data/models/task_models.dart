import 'task_enums.dart';

class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.customer,
    required this.assignee,
    required this.due,
    required this.priority,
    required this.status,
    required this.location,
  });

  final String id;
  final String title;
  final String description;
  final String customer;
  final String assignee;

  /// Due date and time combined.
  final DateTime due;
  final TaskPriority priority;
  final TaskStatus status;
  final String location;

  bool get isOverdue =>
      (status == TaskStatus.pending || status == TaskStatus.inProgress) &&
      due.isBefore(DateTime.now());

  TaskItem copyWith({
    String? title,
    String? description,
    String? customer,
    String? assignee,
    DateTime? due,
    TaskPriority? priority,
    TaskStatus? status,
    String? location,
  }) {
    return TaskItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      customer: customer ?? this.customer,
      assignee: assignee ?? this.assignee,
      due: due ?? this.due,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      location: location ?? this.location,
    );
  }
}

/// Choices offered by the create / edit form.
class TaskFormOptions {
  const TaskFormOptions({required this.customers, required this.employees});

  final List<String> customers;
  final List<String> employees;
}