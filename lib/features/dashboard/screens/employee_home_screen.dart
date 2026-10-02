import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/animate_extensions.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stat_grid.dart';
import '../../../data/models/employee_models.dart';
import '../../attendance/providers/today_attendance_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/attendance_status_card.dart';
import '../widgets/dashboard_layout.dart';
import '../widgets/dashboard_page.dart';
import '../widgets/quick_actions.dart';
import '../widgets/route_section.dart';
import '../widgets/upcoming_tasks.dart';

class EmployeeHomeScreen extends ConsumerWidget {
  const EmployeeHomeScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(employeeHomeProvider);
    try {
      await ref.read(employeeHomeProvider.future);
    } catch (_) {
      // The error state is rendered by AsyncValueView.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final home = ref.watch(employeeHomeProvider);

    // Briefly null while the router redirects after logout.
    if (user == null) return const SizedBox.shrink();

    return DashboardPage<EmployeeHomeData>(
      user: user,
      value: home,
      onRefresh: () => _refresh(ref),
      onRetry: () => ref.invalidate(employeeHomeProvider),
      builder: (data) => _EmployeeContent(data: data),
    );
  }
}

class _EmployeeContent extends ConsumerWidget {
  const _EmployeeContent({required this.data});

  final EmployeeHomeData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void comingSoon(String feature) =>
        context.showSnack('$feature arrives in an upcoming step.');

    void checkIn() {
      final status = ref.read(todayAttendanceProvider).status;
      if (status == AttendanceStatus.notCheckedIn) {
        ref.read(todayAttendanceProvider.notifier).checkIn();
        context.showSnack('Checked in. Have a productive day!');
      } else {
        context.showSnack('You have already checked in today.');
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: "Today's overview"),
        const AttendanceStatusCard().entrance(1),
        const SizedBox(height: AppSpacing.md),
        StatGrid(
          columns: DashboardLayout.overviewColumns,
          items: [
            StatGridItem(
              label: "Today's tasks",
              value: '${data.tasksToday}',
              icon: Icons.task_alt_rounded,
              color: AppColors.primary,
            ),
            StatGridItem(
              label: "Today's visits",
              value: '${data.visitsToday}',
              icon: Icons.place_rounded,
              color: AppColors.info,
            ),
            StatGridItem(
              label: 'Completed visits',
              value: '${data.completedVisits}',
              icon: Icons.check_circle_rounded,
              color: AppColors.success,
            ),
            StatGridItem(
              label: 'Pending visits',
              value: '${data.pendingVisits}',
              icon: Icons.pending_actions_rounded,
              color: AppColors.warning,
            ),
          ],
        ).entrance(2),
        const SectionHeader(title: 'Quick actions'),
        QuickActions(
          actions: [
            QuickAction(
              label: 'Check In',
              icon: Icons.login_rounded,
              onTap: checkIn,
            ),
            QuickAction(
              label: 'Start Visit',
              icon: Icons.play_circle_outline_rounded,
              onTap: () => context.go('/employee/visits'),
            ),
            QuickAction(
              label: 'Scan QR',
              icon: Icons.qr_code_scanner_rounded,
              onTap: () => comingSoon('Scan QR'),
            ),
            QuickAction(
              label: 'Add Customer',
              icon: Icons.add_business_rounded,
              onTap: () => comingSoon('Add Customer'),
            ),
            QuickAction(
              label: 'View Tasks',
              icon: Icons.checklist_rounded,
              onTap: () => context.go('/employee/tasks'),
            ),
                        QuickAction(
              label: 'My Leads',
              icon: Icons.filter_alt_rounded,
              onTap: () => context.push('/employee/leads'),
            ),
            QuickAction(
              label: 'My Attendance',
              icon: Icons.event_available_rounded,
              onTap: () => context.push('/employee/attendance'),
            ),
          ],
        ).entrance(3),
        SectionHeader(
          title: "Today's route",
          actionLabel: 'Open map',
          onAction: () => comingSoon('Map'),
        ),
        RouteSection(stops: data.route).entrance(4),
        SectionHeader(
          title: 'Upcoming tasks',
          actionLabel: 'View all',
          onAction: () => context.go('/employee/tasks'),
        ),
        UpcomingTasks(tasks: data.upcomingTasks).entrance(5),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
