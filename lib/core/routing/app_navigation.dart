import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/user_role.dart';

extension AppNavigation on BuildContext {
  /// Employees have a Profile tab; admins and managers open it full screen.
  void openProfile(UserRole role) {
    final router = GoRouter.of(this);
    final path = '${role.basePath}/profile';
    if (role == UserRole.employee) {
      router.go(path);
    } else {
      router.push(path);
    }
  }

  void openSettings(UserRole role) {
    GoRouter.of(this).push('${role.basePath}/settings');
  }
}