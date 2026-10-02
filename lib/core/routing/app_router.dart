// import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/widgets.dart';

import '../../features/profile/screens/change_password_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/settings/screens/notification_settings_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../../features/maps/screens/map_screen.dart';
import '../../features/qr/screens/qr_result_screen.dart';
import '../../features/qr/screens/scan_qr_screen.dart';
import '../../features/notifications/screens/notification_detail_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';

import '../../features/attendance/screens/attendance_detail_screen.dart';
import '../../features/attendance/screens/attendance_screen.dart';
import '../../features/visits/screens/visit_detail_screen.dart';
import '../../features/visits/screens/visits_screen.dart';
import '../../features/customers/screens/customer_detail_screen.dart';
import '../../features/customers/screens/customers_screen.dart';
import '../../features/tasks/screens/task_detail_screen.dart';
import '../../features/leads/screens/lead_detail_screen.dart';
import '../../features/leads/screens/lead_form_screen.dart';
import '../../features/leads/screens/leads_screen.dart';
import '../../features/tasks/screens/task_form_screen.dart';
import '../../features/tasks/screens/tasks_screen.dart';
import '../../data/models/user_role.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/dashboard/screens/admin_dashboard_screen.dart';
import '../widgets/placeholder_screen.dart';
import 'role_navigation.dart';
import '../../features/dashboard/screens/employee_home_screen.dart';
import '../../features/dashboard/screens/manager_dashboard_screen.dart';

abstract final class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
}

final routerProvider = Provider<GoRouter>((ref) {
  // Re-run redirects whenever auth state changes.
  final refresh = ValueNotifier<int>(0);
  ref.listen(authProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final location = state.matchedLocation;
      if (location == AppRoutes.splash) return null;

      final user = ref.read(authProvider).user;

      if (user == null) {
        return location == AppRoutes.login ? null : AppRoutes.login;
      }
      // Signed in: keep users inside their own role's section.
      if (location == AppRoutes.login ||
          !location.startsWith(user.role.basePath)) {
        return user.role.homePath;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      for (final role in UserRole.values) _shellFor(role),
      for (final role in UserRole.values) _leadRoutesFor(role),
      for (final role in UserRole.values) _attendanceRoutesFor(role),
      for (final role in UserRole.values) _mapRoutesFor(role),
      _qrRoutes(),
      _adminReportsRoute(),
      for (final role in UserRole.values) _notificationRoutesFor(role),
      for (final role in const [UserRole.admin, UserRole.manager])
        _profileRoutesFor(role),
      for (final role in UserRole.values) _settingsRoutesFor(role),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
StatefulShellRoute _shellFor(UserRole role) {
  final items = roleNavigation[role]!;
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) =>
        AppShell(role: role, navigationShell: navigationShell),
    branches: [
      for (final item in items)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: item.path,
              builder: (context, state) => _screenFor(item),
              routes: _subRoutesFor(item),
            ),
          ],
        ),
    ],
  );
}

/// Real screens replace placeholders here as each step lands.
Widget _screenFor(NavItem item) => switch (item.path) {
  '/admin/dashboard' => const AdminDashboardScreen(),
  '/manager/dashboard' => const ManagerDashboardScreen(),
  '/employee/home' => const EmployeeHomeScreen(),
  '/admin/customers' || '/employee/customers' => const CustomersScreen(),
  '/manager/tasks' || '/employee/tasks' => const TasksScreen(),
  '/manager/reports' => const ReportsScreen(),
  '/employee/profile' => const ProfileScreen(),
  '/admin/visits' ||
  '/manager/visits' ||
  '/employee/visits' => const VisitsScreen(),
  _ => PlaceholderScreen(title: item.label, icon: item.selectedIcon),
};

/// Detail routes nested under a tab, so the navigation bar stays visible
/// and tapping the tab again returns to the list.
List<RouteBase> _subRoutesFor(NavItem item) => switch (item.path) {
  '/admin/customers' || '/employee/customers' => <RouteBase>[
    GoRoute(
      path: ':id',
      builder: (context, state) =>
          CustomerDetailScreen(customerId: state.pathParameters['id']!),
    ),
  ],
  // 'new' must be declared before ':id' so it isn't read as an id.
  '/manager/tasks' || '/employee/tasks' => <RouteBase>[
    GoRoute(path: 'new', builder: (context, state) => const TaskFormScreen()),
    GoRoute(
      path: ':id',
      builder: (context, state) =>
          TaskDetailScreen(taskId: state.pathParameters['id']!),
      routes: [
        GoRoute(
          path: 'edit',
          builder: (context, state) =>
              TaskFormScreen(taskId: state.pathParameters['id']),
        ),
      ],
    ),
  ],
  '/admin/visits' || '/manager/visits' || '/employee/visits' => <RouteBase>[
    GoRoute(
      path: ':id',
      builder: (context, state) =>
          VisitDetailScreen(visitId: state.pathParameters['id']!),
    ),
  ],
  '/employee/profile' => _profileSubRoutes(),
  _ => const <RouteBase>[],
};

/// Leads isn't a bottom-nav tab in the spec, so it opens as full-screen
/// pages above the shell (reached from the dashboard quick actions).
GoRoute _leadRoutesFor(UserRole role) {
  return GoRoute(
    path: '${role.basePath}/leads',
    builder: (context, state) => const LeadsScreen(),
    routes: [
      // 'new' must be declared before ':id' so it isn't read as an id.
      GoRoute(path: 'new', builder: (context, state) => const LeadFormScreen()),
      GoRoute(
        path: ':id',
        builder: (context, state) =>
            LeadDetailScreen(leadId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) =>
                LeadFormScreen(leadId: state.pathParameters['id']),
          ),
        ],
      ),
    ],
  );
}

/// Attendance isn't a bottom-nav tab in the spec, so it opens as
/// full-screen pages above the shell (reached from dashboard quick actions).
GoRoute _attendanceRoutesFor(UserRole role) {
  return GoRoute(
    path: '${role.basePath}/attendance',
    builder: (context, state) => const AttendanceScreen(),
    routes: [
      GoRoute(
        path: ':id',
        builder: (context, state) =>
            AttendanceDetailScreen(employeeId: state.pathParameters['id']!),
      ),
    ],
  );
}

/// Map opens as a full-screen page above the shell for every role.
GoRoute _mapRoutesFor(UserRole role) {
  return GoRoute(
    path: '${role.basePath}/maps',
    builder: (context, state) => const MapScreen(),
  );
}

/// QR scanning is an employee-only flow: scan, then the result.
GoRoute _qrRoutes() {
  return GoRoute(
    path: '/employee/qr',
    builder: (context, state) => const ScanQrScreen(),
    routes: [
      GoRoute(
        path: 'result',
        builder: (context, state) => const QrResultScreen(),
      ),
    ],
  );
}

/// Admin has no Reports tab (it will live under "More"), so it opens as a
/// full-screen page from the dashboard. Managers use their Reports tab.
GoRoute _adminReportsRoute() {
  return GoRoute(
    path: '/admin/reports',
    builder: (context, state) => const ReportsScreen(),
  );
}

/// Notifications open from the dashboard bell as full-screen pages.
GoRoute _notificationRoutesFor(UserRole role) {
  return GoRoute(
    path: '${role.basePath}/notifications',
    builder: (context, state) => const NotificationsScreen(),
    routes: [
      GoRoute(
        path: ':id',
        builder: (context, state) => NotificationDetailScreen(
          notificationId: state.pathParameters['id']!,
        ),
      ),
    ],
  );
}
List<RouteBase> _profileSubRoutes() => <RouteBase>[
      GoRoute(
        path: 'edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: 'password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
    ];

/// Employees have a Profile tab. Admin and Manager open Profile as a
/// full-screen page from the avatar menu.
GoRoute _profileRoutesFor(UserRole role) {
  return GoRoute(
    path: '${role.basePath}/profile',
    builder: (context, state) => const ProfileScreen(),
    routes: _profileSubRoutes(),
  );
}

/// Settings opens full screen for every role.
GoRoute _settingsRoutesFor(UserRole role) {
  return GoRoute(
    path: '${role.basePath}/settings',
    builder: (context, state) => const SettingsScreen(),
    routes: [
      GoRoute(
        path: 'notifications',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
    ],
  );
}