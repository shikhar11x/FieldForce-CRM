import 'package:flutter/material.dart';

import '../../data/models/user_role.dart';

class NavItem {
  const NavItem({
    required this.label,
    required this.path,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final String path;
  final IconData icon;
  final IconData selectedIcon;
}

/// Single source of truth for each role's bottom navigation / rail.
///
/// Material guidance caps NavigationBar at 5 destinations, so Admin's
/// "Reports" lives under "More" on phones. We can surface it as its own
/// rail item on tablets later.
const Map<UserRole, List<NavItem>> roleNavigation = {
  UserRole.admin: [
    NavItem(
      label: 'Dashboard',
      path: '/admin/dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
    ),
    NavItem(
      label: 'Users',
      path: '/admin/users',
      icon: Icons.group_outlined,
      selectedIcon: Icons.group_rounded,
    ),
    NavItem(
      label: 'Customers',
      path: '/admin/customers',
      icon: Icons.business_outlined,
      selectedIcon: Icons.business_rounded,
    ),
    NavItem(
      label: 'Visits',
      path: '/admin/visits',
      icon: Icons.place_outlined,
      selectedIcon: Icons.place_rounded,
    ),
    NavItem(
      label: 'More',
      path: '/admin/more',
      icon: Icons.apps_outlined,
      selectedIcon: Icons.apps_rounded,
    ),
  ],
  UserRole.manager: [
    NavItem(
      label: 'Dashboard',
      path: '/manager/dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
    ),
    NavItem(
      label: 'Team',
      path: '/manager/team',
      icon: Icons.groups_outlined,
      selectedIcon: Icons.groups_rounded,
    ),
    NavItem(
      label: 'Tasks',
      path: '/manager/tasks',
      icon: Icons.task_alt_outlined,
      selectedIcon: Icons.task_alt_rounded,
    ),
    NavItem(
      label: 'Visits',
      path: '/manager/visits',
      icon: Icons.place_outlined,
      selectedIcon: Icons.place_rounded,
    ),
    NavItem(
      label: 'Reports',
      path: '/manager/reports',
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart_rounded,
    ),
  ],
  UserRole.employee: [
    NavItem(
      label: 'Home',
      path: '/employee/home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    NavItem(
      label: 'Tasks',
      path: '/employee/tasks',
      icon: Icons.task_alt_outlined,
      selectedIcon: Icons.task_alt_rounded,
    ),
    NavItem(
      label: 'Customers',
      path: '/employee/customers',
      icon: Icons.business_outlined,
      selectedIcon: Icons.business_rounded,
    ),
    NavItem(
      label: 'Visits',
      path: '/employee/visits',
      icon: Icons.place_outlined,
      selectedIcon: Icons.place_rounded,
    ),
    NavItem(
      label: 'Profile',
      path: '/employee/profile',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
    ),
  ],
};