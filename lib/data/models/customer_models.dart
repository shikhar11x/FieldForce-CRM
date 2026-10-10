import 'task_enums.dart';

enum CustomerStatus {
  active('Active', 'ACTIVE'),
  inactive('Inactive', 'INACTIVE'),
  newCustomer('New', 'NEW');

  const CustomerStatus(this.label, this.apiValue);
  final String label;
  final String apiValue;

  static CustomerStatus fromApi(String value) {
    return CustomerStatus.values.firstWhere(
      (s) => s.apiValue == value,
      orElse: () => CustomerStatus.newCustomer,
    );
  }
}

DateTime? _parseDate(Object? value) =>
    value is String ? DateTime.parse(value).toLocal() : null;

class Customer {
  const Customer({
    required this.id,
    required this.company,
    required this.contactName,
    required this.phone,
    required this.email,
    required this.address,
    required this.status,
    required this.assignedEmployee,
    this.assignedEmployeeId = '',
    this.lastVisit,
    this.nextVisit,
    this.highPriority = false,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      company: json['company'] as String,
      contactName: json['contactName'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      address: json['address'] as String,
      status: CustomerStatus.fromApi(json['status'] as String),
      assignedEmployee: json['assignedEmployee'] as String? ?? 'Unassigned',
      assignedEmployeeId: json['assignedEmployeeId'] as String? ?? '',
      lastVisit: _parseDate(json['lastVisit']),
      nextVisit: _parseDate(json['nextVisit']),
      highPriority: json['highPriority'] as bool,
    );
  }

  final String id;
  final String company;
  final String contactName;
  final String phone;
  final String email;
  final String address;
  final CustomerStatus status;
  final String assignedEmployee;
  final String assignedEmployeeId;
  final DateTime? lastVisit;
  final DateTime? nextVisit;
  final bool highPriority;

  /// Create / update request body. Employee ke liye [includeManaged] false
  /// rakho: assignment, status aur priority sirf admin / manager badalte hain.
  Map<String, dynamic> toRequestJson({bool includeManaged = true}) {
    return {
      'company': company,
      'contactName': contactName,
      'phone': phone,
      'email': email,
      'address': address,
      if (includeManaged) ...{
        'status': status.apiValue,
        'highPriority': highPriority,
        if (assignedEmployeeId.isNotEmpty) 'assignedToId': assignedEmployeeId,
      },
    };
  }
}

enum CustomerActivityType { call, visit, task, note, statusUpdate }

class CustomerActivity {
  const CustomerActivity({
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
  });

  final CustomerActivityType type;
  final String title;
  final String description;
  final DateTime timestamp;
}

class CustomerVisit {
  const CustomerVisit({
    required this.id,
    required this.date,
    required this.employee,
    required this.purpose,
    required this.status,
  });

  final String id;
  final DateTime date;
  final String employee;
  final String purpose;
  final VisitStatus status;
}

class CustomerNote {
  const CustomerNote({
    required this.id,
    required this.author,
    required this.text,
    required this.timestamp,
  });

  factory CustomerNote.fromJson(Map<String, dynamic> json) {
    return CustomerNote(
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

class CustomerDocument {
  const CustomerDocument({
    required this.id,
    required this.name,
    required this.kind,
    required this.size,
    required this.uploaded,
  });

  final String id;
  final String name;

  /// File kind label, e.g. PDF, XLS.
  final String kind;
  final String size;
  final DateTime uploaded;
}

class CustomerDetail {
  const CustomerDetail({
    required this.customer,
    required this.activities,
    required this.visits,
    required this.notes,
    required this.documents,
  });

  final Customer customer;
  final List<CustomerActivity> activities;
  final List<CustomerVisit> visits;
  final List<CustomerNote> notes;
  final List<CustomerDocument> documents;
}