import 'task_enums.dart';

enum CustomerStatus {
  active('Active'),
  inactive('Inactive'),
  newCustomer('New');

  const CustomerStatus(this.label);
  final String label;
}

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
    this.lastVisit,
    this.nextVisit,
    this.highPriority = false,
  });

  final String id;
  final String company;
  final String contactName;
  final String phone;
  final String email;
  final String address;
  final CustomerStatus status;
  final String assignedEmployee;
  final DateTime? lastVisit;
  final DateTime? nextVisit;
  final bool highPriority;
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

class CustomerTask {
  const CustomerTask({
    required this.id,
    required this.title,
    required this.due,
    required this.priority,
    required this.status,
  });

  final String id;
  final String title;
  final DateTime due;
  final TaskPriority priority;
  final TaskStatus status;
}

class CustomerNote {
  const CustomerNote({
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
    required this.tasks,
    required this.notes,
    required this.documents,
  });

  final Customer customer;
  final List<CustomerActivity> activities;
  final List<CustomerVisit> visits;
  final List<CustomerTask> tasks;
  final List<CustomerNote> notes;
  final List<CustomerDocument> documents;
}