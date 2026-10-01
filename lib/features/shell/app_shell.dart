import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/role_navigation.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/app_logo.dart';
import '../../data/models/user_role.dart';

/// Adaptive scaffold: NavigationBar on phones, NavigationRail on tablets.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.role,
    required this.navigationShell,
  });

  final UserRole role;
  final StatefulNavigationShell navigationShell;

  void _onSelect(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = roleNavigation[role]!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= Breakpoints.tablet;

        if (!useRail) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onSelect,
              destinations: [
                for (final item in items)
                  NavigationDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selectedIcon),
                    label: item.label,
                  ),
              ],
            ),
          );
        }

        final extended = constraints.maxWidth >= Breakpoints.wide;
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                extended: extended,
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: _onSelect,
                labelType: extended ? null : NavigationRailLabelType.all,
                leading: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: AppLogo(size: 44),
                ),
                destinations: [
                  for (final item in items)
                    NavigationRailDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.selectedIcon),
                      label: Text(item.label),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: navigationShell),
            ],
          ),
        );
      },
    );
  }
}