import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/animate_extensions.dart';
import '../../../core/extensions/attendance_style_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/icon_text.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../../core/widgets/stat_grid.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/attendance_models.dart';
import '../providers/attendance_provider.dart';
import 'attendance_layout.dart';

/// Manager / admin view: today's counts and the team list.
class TeamAttendanceView extends ConsumerStatefulWidget {
  const TeamAttendanceView({super.key, required this.basePath});

  /// Role route prefix, e.g. `/manager`.
  final String basePath;

  @override
  ConsumerState<TeamAttendanceView> createState() =>
      _TeamAttendanceViewState();
}

class _TeamAttendanceViewState extends ConsumerState<TeamAttendanceView> {
  final _controller = TextEditingController();
  String _query = '';
  AttendanceDayStatus? _filter;

  static const _tabs = <AttendanceDayStatus?>[
    null,
    AttendanceDayStatus.present,
    AttendanceDayStatus.lateIn,
    AttendanceDayStatus.halfDay,
    AttendanceDayStatus.absent,
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(teamAttendanceProvider);
    try {
      await ref.read(teamAttendanceProvider.future);
    } catch (_) {
      // The error state is rendered by AsyncValueView.
    }
  }

  void _clearFilters() {
    _controller.clear();
    setState(() {
      _query = '';
      _filter = null;
    });
  }

  Widget _buildContent(List<TeamAttendanceEntry> entries) {
    int count(AttendanceDayStatus? s) => s == null
        ? entries.length
        : entries.where((e) => e.today?.status == s).length;

    final average = entries.isEmpty
        ? 0.0
        : entries.fold<double>(0, (sum, e) => sum + e.summary.percent) /
            entries.length;

    final q = _query.trim().toLowerCase();
    final filtered = entries.where((e) {
      if (_filter != null && e.today?.status != _filter) return false;
      if (q.isEmpty) return true;
      return e.name.toLowerCase().contains(q) ||
          e.designation.toLowerCase().contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: "Today's attendance"),
        StatGrid(
          columns: attendanceStatColumns,
          items: [
            StatGridItem(
              label: 'Team size',
              value: '${entries.length}',
              icon: Icons.groups_rounded,
              color: AppColors.primary,
            ),
            StatGridItem(
              label: 'Present',
              value: '${count(AttendanceDayStatus.present)}',
              icon: Icons.check_circle_rounded,
              color: AppColors.success,
            ),
            StatGridItem(
              label: 'Late',
              value: '${count(AttendanceDayStatus.lateIn)}',
              icon: Icons.schedule_rounded,
              color: AppColors.warning,
            ),
            StatGridItem(
              label: 'Half day',
              value: '${count(AttendanceDayStatus.halfDay)}',
              icon: Icons.timelapse_rounded,
              color: AppColors.info,
            ),
            StatGridItem(
              label: 'Absent',
              value: '${count(AttendanceDayStatus.absent)}',
              icon: Icons.event_busy_rounded,
              color: AppColors.error,
            ),
            StatGridItem(
              label: 'Month attendance',
              value: '${average.round()}%',
              icon: Icons.event_available_rounded,
              color: AppColors.accent,
            ),
          ],
        ).entrance(1),
        const SectionHeader(title: 'Team members'),
        TextField(
          controller: _controller,
          textInputAction: TextInputAction.search,
          onChanged: (v) => setState(() => _query = v),
          decoration: InputDecoration(
            hintText: 'Search by name or role',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _query = '');
                    },
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _tabs.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, i) {
              final status = _tabs[i];
              final label = status?.label ?? 'All';
              return ChoiceChip(
                label: Text('$label ${count(status)}'),
                selected: _filter == status,
                showCheckmark: false,
                onSelected: (_) => setState(() => _filter = status),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (filtered.isEmpty)
          EmptyState(
            icon: Icons.search_off_rounded,
            title: 'No employees found',
            message: 'Try a different search or clear your filters.',
            actionLabel: 'Clear filters',
            onAction: _clearFilters,
          )
        else
          for (final (i, entry) in filtered.indexed) ...[
            _TeamCard(
              entry: entry,
              onTap: () =>
                  context.push('${widget.basePath}/attendance/${entry.id}'),
            ).entrance(i < 5 ? i : 5),
            const SizedBox(height: AppSpacing.md),
          ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final team = ref.watch(teamAttendanceProvider);

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          ResponsiveBody(
            maxWidth: 900,
            child: AsyncValueView<List<TeamAttendanceEntry>>(
              value: team,
              onRetry: () => ref.invalidate(teamAttendanceProvider),
              loading: const _TeamSkeleton(),
              data: _buildContent,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({required this.entry, required this.onTap});

  final TeamAttendanceEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final status = entry.today?.status;
    final percent = entry.summary.percent;
    final levelColor = percent >= 90
        ? AppColors.success
        : (percent >= 75 ? AppColors.info : AppColors.warning);

    String time(DateTime? t) =>
        t == null ? '--' : TimeOfDay.fromDateTime(t).format(context);

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              InitialsAvatar(name: entry.name),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    Text(
                      entry.designation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              StatusChip(
                label: status?.label ?? 'Not marked',
                color: status?.color ?? muted,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: IconText(
                  icon: Icons.login_rounded,
                  text: 'In: ${time(entry.today?.checkIn)}',
                ),
              ),
              Expanded(
                child: IconText(
                  icon: Icons.logout_rounded,
                  text: 'Out: ${time(entry.today?.checkOut)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent / 100,
                    minHeight: 6,
                    color: levelColor,
                    backgroundColor: levelColor.withValues(alpha: 0.15),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('${percent.round()}%', style: theme.textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'This month',
            style: theme.textTheme.labelSmall?.copyWith(color: muted),
          ),
        ],
      ),
    );
  }
}

class _TeamSkeleton extends StatelessWidget {
  const _TeamSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: AppSpacing.xl),
        SkeletonBox(height: 112, radius: AppRadius.lg),
        SizedBox(height: AppSpacing.lg),
        SkeletonBox(height: 112, radius: AppRadius.lg),
        SizedBox(height: AppSpacing.lg),
        SkeletonBox(height: 130, radius: AppRadius.lg),
        SizedBox(height: AppSpacing.md),
        SkeletonBox(height: 130, radius: AppRadius.lg),
      ],
    );
  }
}