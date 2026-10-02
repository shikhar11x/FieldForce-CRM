import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/quick_actions.dart';
import '../../../core/extensions/animate_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/models/manager_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/activity_feed.dart';
import '../widgets/dashboard_page.dart';
import '../widgets/team_analytics_section.dart';
import '../widgets/team_kpi_grid.dart';
import '../widgets/team_performance_list.dart';

class ManagerDashboardScreen extends ConsumerWidget {
  const ManagerDashboardScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(managerDashboardProvider);
    try {
      await ref.read(managerDashboardProvider.future);
    } catch (_) {
      // The error state is rendered by AsyncValueView.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final dashboard = ref.watch(managerDashboardProvider);

    // Briefly null while the router redirects after logout.
    if (user == null) return const SizedBox.shrink();

    return DashboardPage<ManagerDashboardData>(
      user: user,
      value: dashboard,
      onRefresh: () => _refresh(ref),
      onRetry: () => ref.invalidate(managerDashboardProvider),
      builder: (data) => _ManagerContent(data: data),
    );
  }
}

class _ManagerContent extends StatelessWidget {
  const _ManagerContent({required this.data});

  final ManagerDashboardData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Team overview'),
        TeamKpiGrid(kpis: data.kpis).entrance(1),
        TeamKpiGrid(kpis: data.kpis).entrance(1),
        const SectionHeader(title: 'Quick actions'),
        QuickActions(
          actions: [
            QuickAction(
              label: 'Leads Pipeline',
              icon: Icons.filter_alt_rounded,
              onTap: () => context.push('/manager/leads'),
            ),
            QuickAction(
              label: 'Create Task',
              icon: Icons.add_task_rounded,
              onTap: () => context.go('/manager/tasks/new'),
            ),
            QuickAction(
              label: 'View Visits',
              icon: Icons.place_rounded,
              onTap: () => context.go('/manager/visits'),
            ),
          ],
        ).entrance(2),
        const SectionHeader(title: 'Team performance'),
        TeamAnalyticsSection(data: data).entrance(2),
        SectionHeader(
          title: 'Team members',
          actionLabel: 'View all',
          onAction: () => context.go('/manager/team'),
        ),
        TeamPerformanceList(members: data.teamMembers).entrance(3),
        const SectionHeader(title: 'Recent activity'),
        ActivityFeed(items: data.activities).entrance(4),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
