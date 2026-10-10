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
    this.customerId = '',
    this.assigneeId = '',
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      customer: json['customer'] as String,
      customerId: json['customerId'] as String,
      assignee: json['assignee'] as String,
      assigneeId: json['assigneeId'] as String,
      due: DateTime.parse(json['due'] as String).toLocal(),
      priority: TaskPriority.fromApi(json['priority'] as String),
      status: TaskStatus.fromApi(json['status'] as String),
      location: json['location'] as String? ?? '',
    );
  }

  final String id;
  final String title;
  final String description;
  final String customer;
  final String assignee;

  /// Backend ke ids. Mock mode me khaali hote hain.
  final String customerId;
  final String assigneeId;

  /// Due date and time combined.
  final DateTime due;
  final TaskPriority priority;
  final TaskStatus status;
  final String location;

  bool get isOverdue =>
      (status == TaskStatus.pending || status == TaskStatus.inProgress) &&
      due.isBefore(DateTime.now());

  /// Create / update request body.
  Map<String, dynamic> toRequestJson() {
    return {
      'title': title,
      'description': description,
      'customerId': customerId,
      'assigneeId': assigneeId,
      'due': due.toUtc().toIso8601String(),
      'priority': priority.apiValue,
      'status': status.apiValue,
      'location': location,
    };
  }

  TaskItem copyWith({
    String? title,
    String? description,
    String? customer,
    String? customerId,
    String? assignee,
    String? assigneeId,
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
      customerId: customerId ?? this.customerId,
      assignee: assignee ?? this.assignee,
      assigneeId: assigneeId ?? this.assigneeId,
      due: due ?? this.due,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      location: location ?? this.location,
    );
  }
}

/// Dropdown ka ek choice: [id] server ko jaata hai, [name] dikhta hai.
class FormOption {
  const FormOption({required this.id, required this.name});

  factory FormOption.fromJson(Map<String, dynamic> json) =>
      FormOption(id: json['id'] as String, name: json['name'] as String);

  final String id;
  final String name;
}

/// Choices offered by the create / edit form.
class TaskFormOptions {
  const TaskFormOptions({required this.customers, required this.assignees});

  factory TaskFormOptions.fromJson(Map<String, dynamic> json) {
    List<FormOption> parse(Object? raw) => [
          for (final item in raw as List<dynamic>)
            FormOption.fromJson(item as Map<String, dynamic>),
        ];

    return TaskFormOptions(
      customers: parse(json['customers']),
      assignees: parse(json['assignees']),
    );
  }

  final List<FormOption> customers;
  final List<FormOption> assignees;
}