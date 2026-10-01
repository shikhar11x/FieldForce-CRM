enum UserRole {
  admin('Admin', '/admin/dashboard'),
  manager('Manager', '/manager/dashboard'),
  employee('Employee', '/employee/home');

  const UserRole(this.label, this.homePath);

  final String label;
  final String homePath;

  /// Route prefix shared by every screen belonging to this role.
  String get basePath => '/$name';
}