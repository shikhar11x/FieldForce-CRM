import 'user_role.dart';

/// Teams offered by the user form. Backend me bhi yahi teams seeded hain.
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
    this.managerId = '',
    this.isActive = true,
  });

  factory DirectoryUser.fromJson(Map<String, dynamic> json) {
    return DirectoryUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: UserRole.values.byName((json['role'] as String).toLowerCase()),
      designation: json['designation'] as String,
      department: json['department'] as String,
      team: json['team'] as String? ?? '',
      manager: json['manager'] as String? ?? '',
      managerId: json['managerId'] as String? ?? '',
      employeeId: json['employeeId'] as String,
      joiningDate: DateTime.parse(json['joiningDate'] as String),
      isActive: json['isActive'] as bool,
    );
  }

  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String designation;
  final String department;
  final String team;
  final String manager;

  /// Manager ka id (backend isi se link karta hai). Khaali = koi nahi.
  final String managerId;
  final String employeeId;
  final DateTime joiningDate;
  final bool isActive;

  /// Create / update request body.
  Map<String, dynamic> toRequestJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name.toUpperCase(),
      'designation': designation,
      'department': department,
      if (team.isNotEmpty) 'team': team,
      if (managerId.isNotEmpty) 'managerId': managerId,
      'isActive': isActive,
    };
  }

  DirectoryUser copyWith({
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? designation,
    String? department,
    String? team,
    String? manager,
    String? managerId,
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
      managerId: managerId ?? this.managerId,
      employeeId: employeeId,
      joiningDate: joiningDate,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Create ka result. [temporaryPassword] sirf ek baar milta hai.
class CreatedUser {
  const CreatedUser({required this.user, this.temporaryPassword});

  final DirectoryUser user;
  final String? temporaryPassword;
}