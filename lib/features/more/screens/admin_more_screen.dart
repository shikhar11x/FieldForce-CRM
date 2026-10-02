import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_navigation.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/settings_tile.dart';
import '../../../data/models/user_role.dart';

/// Admin's "More" tab: links to every module that isn't a bottom tab.
class AdminMoreScreen extends StatelessWidget {
  const AdminMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ResponsiveBody(
        maxWidth: 700,
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          children: [
            const SectionHeader(title: 'Sales and CRM'),
            SettingsGroup(
              children: [
                SettingsTile(
                  icon: Icons.filter_alt_rounded,
                  title: 'Leads pipeline',
                  subtitle: 'Track deals from new to won',
                  onTap: () => context.push('/admin/leads'),
                ),
              ],
            ),
            const SectionHeader(title: 'Operations'),
            SettingsGroup(
              children: [
                SettingsTile(
                  icon: Icons.event_available_rounded,
                  title: 'Attendance',
                  subtitle: 'Today and monthly team attendance',
                  onTap: () => context.push('/admin/attendance'),
                ),
                SettingsTile(
                  icon: Icons.map_rounded,
                  title: 'Live map',
                  subtitle: 'Team, customers and visit stops',
                  onTap: () => context.push('/admin/maps'),
                ),
              ],
            ),
            const SectionHeader(title: 'Insights'),
            SettingsGroup(
              children: [
                SettingsTile(
                  icon: Icons.insights_rounded,
                  title: 'Reports',
                  subtitle: 'Sales, employee, customer and attendance',
                  onTap: () => context.push('/admin/reports'),
                ),
              ],
            ),
            const SectionHeader(title: 'Account'),
            SettingsGroup(
              children: [
                SettingsTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  onTap: () => context.push('/admin/notifications'),
                ),
                SettingsTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Profile',
                  onTap: () => context.openProfile(UserRole.admin),
                ),
                SettingsTile(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () => context.openSettings(UserRole.admin),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}