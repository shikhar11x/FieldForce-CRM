import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/attendance_style_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/attendance_models.dart';
import '../providers/attendance_provider.dart';
import '../widgets/attendance_month_view.dart';

/// One team member's monthly attendance (manager / admin).
class AttendanceDetailScreen extends ConsumerWidget {
  const AttendanceDetailScreen({super.key, required this.employeeId});

  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(teamAttendanceProvider);
    final list = team.value;
    final entry = list == null ? null : findTeamEntry(list, employeeId);

    return Scaffold(
      appBar: AppBar(title: Text(entry?.name ?? 'Attendance')),
      body: ResponsiveBody(
        maxWidth: 900,
        child: AsyncValueView<List<TeamAttendanceEntry>>(
          value: team,
          onRetry: () => ref.invalidate(teamAttendanceProvider),
          loading: const _DetailSkeleton(),
          data: (_) => entry == null
              ? const EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'Employee not found',
                  message: 'They may have been removed.',
                )
              : _DetailContent(entry: entry),
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.entry});

  final TeamAttendanceEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = entry.today?.status;

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        AppCard(
          child: Row(
            children: [
              InitialsAvatar(name: entry.name, radius: 26),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.name, style: theme.textTheme.titleLarge),
                    Text(
                      entry.designation,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (status != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      StatusChip(
                        label: 'Today: ${status.label}',
                        color: status.color,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AttendanceMonthView(employee: entry.name),
      ],
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SkeletonBox(height: 100, radius: AppRadius.lg),
        SizedBox(height: AppSpacing.lg),
        SkeletonBox(height: 112, radius: AppRadius.lg),
        SizedBox(height: AppSpacing.lg),
        SkeletonBox(height: 300, radius: AppRadius.lg),
      ],
    );
  }
}