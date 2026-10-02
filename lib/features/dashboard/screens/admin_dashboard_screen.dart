import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/extensions/animate_extensions.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/models/dashboard_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/activity_feed.dart';
import '../widgets/analytics_section.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_skeleton.dart';
import '../widgets/kpi_grid.dart';
import '../widgets/quick_actions.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(adminDashboardProvider);
    try {
      await ref.read(adminDashboardProvider.future);
    } catch (_) {
      // The error state is rendered by AsyncValueView.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final dashboard = ref.watch(adminDashboardProvider);

    // Briefly null while the router redirects after logout.
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              ResponsiveBody(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DashboardHeader(user: user).entrance(),
                    AsyncValueView<AdminDashboardData>(
                      value: dashboard,
                      onRetry: () => ref.invalidate(adminDashboardProvider),
                      loading: const DashboardSkeleton(),
                      data: (data) => _DashboardContent(data: data),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.data});

  final AdminDashboardData data;

  @override
  Widget build(BuildContext context) {
    void comingSoon(String feature) =>
        context.showSnack('$feature arrives in an upcoming step.');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Overview'),
        KpiGrid(kpis: data.kpis).entrance(1),
        const SectionHeader(title: 'Quick actions'),
        QuickActions(
          actions: [
            QuickAction(
              label: 'Add Employee',
              icon: Icons.person_add_alt_1_rounded,
              onTap: () => comingSoon('Add Employee'),
            ),
            QuickAction(
              label: 'Add Customer',
              icon: Icons.add_business_rounded,
              onTap: () => comingSoon('Add Customer'),
            ),
            QuickAction(
              label: 'Create Task',
              icon: Icons.add_task_rounded,
              onTap: () => comingSoon('Create Task'),
            ),
                        QuickAction(
              label: 'View Reports',
              icon: Icons.insights_rounded,
              onTap: () => comingSoon('Reports'),
            ),
                        QuickAction(
              label: 'Leads Pipeline',
              icon: Icons.filter_alt_rounded,
              onTap: () => context.push('/admin/leads'),
            ),
            QuickAction(
              label: 'Attendance',
              icon: Icons.event_available_rounded,
              onTap: () => context.push('/admin/attendance'),
            ),
          ],
        ).entrance(2),
        const SectionHeader(title: 'Analytics'),
        AnalyticsSection(data: data).entrance(3),
        const SectionHeader(title: 'Recent activity'),
        ActivityFeed(items: data.activities).entrance(4),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}