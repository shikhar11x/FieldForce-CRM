import 'user_role.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.organization,
    required this.employeeId,
    required this.department,
    required this.joiningDate,
  });

  /// Backend ka `/auth/*` profile response.
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: UserRole.values.byName((json['role'] as String).toLowerCase()),
      organization: json['organization'] as String,
      employeeId: json['employeeId'] as String,
      department: json['department'] as String,
      joiningDate: DateTime.parse(json['joiningDate'] as String),
    );
  }

  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String organization;
  final String employeeId;
  final String department;
  final DateTime joiningDate;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  /// Sirf wo fields jo user khud edit kar sakta hai.
  AppUser copyWith({String? email, String? phone}) {
    return AppUser(
      id: id,
      name: name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role,
      organization: organization,
      employeeId: employeeId,
      department: department,
      joiningDate: joiningDate,
    );
  }
}