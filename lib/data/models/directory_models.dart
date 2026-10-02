import 'user_role.dart';

/// Teams offered by the user form.
const userTeams = ['Sales North', 'Sales South', 'Service'];

/// A person in the organisation directory. [team] and [manager] are empty
/// strings when not applicable.
class DirectoryUser {
  const DirectoryUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.designation,
    required this.department,
    required this.team,
    required this.manager,
    required this.employeeId,
    required this.joiningDate,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String designation;
  final String department;
  final String team;
  final String manager;
  final String employeeId;
  final DateTime joiningDate;
  final bool isActive;

  DirectoryUser copyWith({
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? designation,
    String? department,
    String? team,
    String? manager,
    bool? isActive,
  }) {
    return DirectoryUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      team: team ?? this.team,
      manager: manager ?? this.manager,
      employeeId: employeeId,
      joiningDate: joiningDate,
      isActive: isActive ?? this.isActive,
    );
  }
}