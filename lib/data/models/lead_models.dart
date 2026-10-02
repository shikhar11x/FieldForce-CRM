import 'task_enums.dart';

enum LeadStage {
  newLead('New'),
  contacted('Contacted'),
  qualified('Qualified'),
  proposal('Proposal'),
  negotiation('Negotiation'),
  won('Won'),
  lost('Lost');

  const LeadStage(this.label);
  final String label;

  bool get isOpen => this != won && this != lost;
}

enum LeadActivityType { created, call, meeting, email, note, stageChange }

class LeadActivity {
  const LeadActivity({
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
  });

  final LeadActivityType type;
  final String title;
  final String description;
  final DateTime timestamp;
}

class LeadItem {
  const LeadItem({
    required this.id,
    required this.customer,
    required this.contactName,
    required this.value,
    required this.assignee,
    required this.priority,
    required this.stage,
    required this.source,
    required this.expectedClose,
    required this.description,
    required this.createdAt,
    this.activities = const <LeadActivity>[],
  });

  final String id;
  final String customer;
  final String contactName;

  /// Deal value in rupees.
  final double value;
  final String assignee;
  final TaskPriority priority;
  final LeadStage stage;
  final String source;
  final DateTime expectedClose;
  final String description;
  final DateTime createdAt;

  /// Newest first.
  final List<LeadActivity> activities;

  DateTime get lastActivity =>
      activities.isEmpty ? createdAt : activities.first.timestamp;

  LeadItem copyWith({
    String? customer,
    String? contactName,
    double? value,
    String? assignee,
    TaskPriority? priority,
    LeadStage? stage,
    String? source,
    DateTime? expectedClose,
    String? description,
    List<LeadActivity>? activities,
  }) {
    return LeadItem(
      id: id,
      customer: customer ?? this.customer,
      contactName: contactName ?? this.contactName,
      value: value ?? this.value,
      assignee: assignee ?? this.assignee,
      priority: priority ?? this.priority,
      stage: stage ?? this.stage,
      source: source ?? this.source,
      expectedClose: expectedClose ?? this.expectedClose,
      description: description ?? this.description,
      createdAt: createdAt,
      activities: activities ?? this.activities,
    );
  }
}

/// Choices offered by the create / edit form.
class LeadFormOptions {
  const LeadFormOptions({required this.employees, required this.sources});

  final List<String> employees;
  final List<String> sources;
}