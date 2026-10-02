import '../models/app_user.dart';
import '../models/user_role.dart';

class MockUsers {
  const MockUsers._();

  static final admin = AppUser(
    id: 'u_admin',
    name: 'Aarav Mehta',
    email: 'admin@fieldforce.com',
    phone: '+91 98765 43210',
    role: UserRole.admin,
    organization: 'Northwind Logistics',
    employeeId: 'FF-0001',
    department: 'Administration',
    joiningDate: DateTime(2019, 4, 1),
  );

  static final manager = AppUser(
    id: 'u_manager',
    name: 'Priya Sharma',
    email: 'manager@fieldforce.com',
    phone: '+91 98765 43211',
    role: UserRole.manager,
    organization: 'Northwind Logistics',
    employeeId: 'FF-0102',
    department: 'Regional Sales',
    joiningDate: DateTime(2021, 6, 14),
  );

  static final employee = AppUser(
    id: 'u_employee',
    name: 'Rohan Verma',
    email: 'employee@fieldforce.com',
    phone: '+91 98765 43212',
    role: UserRole.employee,
    organization: 'Northwind Logistics',
    employeeId: 'FF-0457',
    department: 'Field Sales',
    joiningDate: DateTime(2023, 2, 6),
  );

  static final all = [admin, manager, employee];

  static AppUser byRole(UserRole role) =>
      all.firstWhere((u) => u.role == role);
}