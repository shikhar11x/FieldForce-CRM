import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../dashboard/widgets/attendance_status_card.dart';
import '../providers/attendance_provider.dart';
import 'attendance_month_view.dart';
import 'worked_today_card.dart';

/// Employee view: check in / out, hours today, and monthly history.
class MyAttendanceView extends ConsumerWidget {
  const MyAttendanceView({super.key, required this.employee});

  final String employee;

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(attendanceMonthProvider);
    // The month provider reloads when watched; this just gives feedback.
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => _refresh(ref),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          ResponsiveBody(
            maxWidth: 900,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AttendanceStatusCard(),
                const SizedBox(height: AppSpacing.md),
                const WorkedTodayCard(),
                const SizedBox(height: AppSpacing.lg),
                AttendanceMonthView(employee: employee, isSelf: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}