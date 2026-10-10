import 'task_enums.dart';

enum VisitType {
  sales('Sales', 'SALES'),
  service('Service', 'SERVICE'),
  followUp('Follow-up', 'FOLLOW_UP'),
  delivery('Delivery', 'DELIVERY'),
  demo('Demo', 'DEMO');

  const VisitType(this.label, this.apiValue);
  final String label;
  final String apiValue;

  static VisitType fromApi(String value) => VisitType.values.firstWhere(
    (t) => t.apiValue == value,
    orElse: () => VisitType.sales,
  );
}

enum VisitEventType {
  scheduled('SCHEDULED'),
  started('STARTED'),
  qrVerified('QR_VERIFIED'),
  note('NOTE'),
  photo('PHOTO'),
  completed('COMPLETED'),
  cancelled('CANCELLED');

  const VisitEventType(this.apiValue);
  final String apiValue;

  static VisitEventType fromApi(String value) =>
      VisitEventType.values.firstWhere(
        (t) => t.apiValue == value,
        orElse: () => VisitEventType.note,
      );
}

DateTime? _parseDate(Object? value) =>
    value is String ? DateTime.parse(value).toLocal() : null;

class VisitEvent {
  const VisitEvent({
    required this.type,
    required this.title,
    required this.timestamp,
  });

  factory VisitEvent.fromJson(Map<String, dynamic> json) {
    return VisitEvent(
      type: VisitEventType.fromApi(json['type'] as String),
      title: json['title'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String).toLocal(),
    );
  }

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

  factory VisitNote.fromJson(Map<String, dynamic> json) {
    return VisitNote(
      id: json['id'] as String,
      author: json['author'] as String,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String).toLocal(),
    );
  }

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

  factory VisitAttachment.fromJson(Map<String, dynamic> json) {
    return VisitAttachment(
      id: json['id'] as String,
      name: json['name'] as String,
      kind: json['kind'] as String,
      size: json['size'] as String,
      uploaded: DateTime.parse(json['uploaded'] as String).toLocal(),
    );
  }

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
    this.customerId = '',
    this.employeeId = '',
    this.notes = const <VisitNote>[],
    this.attachments = const <VisitAttachment>[],
    this.events = const <VisitEvent>[],
    this.qrVerified = false,
    this.startedAt,
    this.completedAt,
  });

  factory VisitItem.fromJson(Map<String, dynamic> json) {
    List<T> list<T>(Object? raw, T Function(Map<String, dynamic>) parse) => [
      for (final item in raw as List<dynamic>)
        parse(item as Map<String, dynamic>),
    ];

    return VisitItem(
      id: json['id'] as String,
      customer: json['customer'] as String,
      customerId: json['customerId'] as String,
      employee: json['employee'] as String,
      employeeId: json['employeeId'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String).toLocal(),
      location: json['location'] as String? ?? '',
      status: VisitStatus.fromApi(json['status'] as String),
      type: VisitType.fromApi(json['type'] as String),
      purpose: json['purpose'] as String,
      qrVerified: json['qrVerified'] as bool,
      startedAt: _parseDate(json['startedAt']),
      completedAt: _parseDate(json['completedAt']),
      notes: list(json['notes'], VisitNote.fromJson),
      attachments: list(json['attachments'], VisitAttachment.fromJson),
      events: list(json['events'], VisitEvent.fromJson),
    );
  }

  final String id;
  final String customer;
  final String employee;

  /// Backend ke ids. Mock mode me khaali hote hain.
  final String customerId;
  final String employeeId;
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
      customerId: customerId,
      employee: employee,
      employeeId: employeeId,
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
