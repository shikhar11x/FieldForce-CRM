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

  /// Only the fields a user may edit themselves.
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