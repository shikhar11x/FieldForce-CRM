import 'task_enums.dart';

enum VisitType {
  sales('Sales'),
  service('Service'),
  followUp('Follow-up'),
  delivery('Delivery'),
  demo('Demo');

  const VisitType(this.label);
  final String label;
}

enum VisitEventType {
  scheduled,
  started,
  qrVerified,
  note,
  photo,
  completed,
  cancelled,
}

class VisitEvent {
  const VisitEvent({
    required this.type,
    required this.title,
    required this.timestamp,
  });

  final VisitEventType type;
  final String title;
  final DateTime timestamp;
}

class VisitNote {
  const VisitNote({
    required this.id,
    required this.author,
    required this.text,
    required this.timestamp,
  });

  final String id;
  final String author;
  final String text;
  final DateTime timestamp;
}

class VisitAttachment {
  const VisitAttachment({
    required this.id,
    required this.name,
    required this.kind,
    required this.size,
    required this.uploaded,
  });

  final String id;
  final String name;
  final String kind;
  final String size;
  final DateTime uploaded;
}

class VisitItem {
  const VisitItem({
    required this.id,
    required this.customer,
    required this.employee,
    required this.scheduledAt,
    required this.location,
    required this.status,
    required this.type,
    required this.purpose,
    this.notes = const <VisitNote>[],
    this.attachments = const <VisitAttachment>[],
    this.events = const <VisitEvent>[],
    this.qrVerified = false,
    this.startedAt,
    this.completedAt,
  });

  final String id;
  final String customer;
  final String employee;
  final DateTime scheduledAt;
  final String location;
  final VisitStatus status;
  final VisitType type;
  final String purpose;

  /// Newest first.
  final List<VisitNote> notes;
  final List<VisitAttachment> attachments;

  /// Chronological, oldest first.
  final List<VisitEvent> events;
  final bool qrVerified;
  final DateTime? startedAt;
  final DateTime? completedAt;

  Duration? get duration {
    final start = startedAt;
    final end = completedAt;
    if (start == null || end == null) return null;
    return end.difference(start);
  }

  VisitItem copyWith({
    VisitStatus? status,
    List<VisitNote>? notes,
    List<VisitAttachment>? attachments,
    List<VisitEvent>? events,
    bool? qrVerified,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return VisitItem(
      id: id,
      customer: customer,
      employee: employee,
      scheduledAt: scheduledAt,
      location: location,
      status: status ?? this.status,
      type: type,
      purpose: purpose,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      events: events ?? this.events,
      qrVerified: qrVerified ?? this.qrVerified,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}