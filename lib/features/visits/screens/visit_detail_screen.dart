import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/task_style_extensions.dart';
import '../../../core/extensions/visit_style_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/detail_row.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/task_enums.dart';
import '../../../data/models/user_role.dart';
import '../../../data/models/visit_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/visit_provider.dart';
import '../widgets/visit_action_panel.dart';
import '../widgets/visit_detail_sections.dart';

class VisitDetailScreen extends ConsumerWidget {
  const VisitDetailScreen({super.key, required this.visitId});

  final String visitId;

  List<VisitItem> _historyFor(VisitItem visit, List<VisitItem> all) {
    return all
        .where(
          (v) =>
              v.id != visit.id &&
              v.customer == visit.customer &&
              v.status == VisitStatus.completed,
        )
        .toList()
      ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final visits = ref.watch(visitsProvider);

    // Briefly null while the router redirects after logout.
    if (user == null) return const SizedBox.shrink();

    final list = visits.value;
    final visit = list == null ? null : findVisit(list, visitId);

    return Scaffold(
      appBar: AppBar(title: const Text('Visit details')),
      body: ResponsiveBody(
        maxWidth: 700,
        child: AsyncValueView<List<VisitItem>>(
          value: visits,
          onRetry: () => ref.invalidate(visitsProvider),
          loading: const _DetailSkeleton(),
          data: (all) => visit == null
              ? const EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'Visit not found',
                  message: 'It may have been removed.',
                )
              : _VisitDetailContent(
                  visit: visit,
                  history: _historyFor(visit, all),
                  isEmployee: user.role == UserRole.employee,
                ),
        ),
      ),
    );
  }
}

class _VisitDetailContent extends StatelessWidget {
  const _VisitDetailContent({
    required this.visit,
    required this.history,
    required this.isEmployee,
  });

  final VisitItem visit;
  final List<VisitItem> history;
  final bool isEmployee;

  String _formatDuration(Duration d) =>
      '${d.inHours}h ${d.inMinutes.remainder(60)}m';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration = visit.duration;

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        AppCard(
          child: Row(
            children: [
              InitialsAvatar(name: visit.customer, radius: 26),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(visit.customer, style: theme.textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        StatusChip(
                          label: visit.status.label,
                          color: visit.status.color,
                        ),
                        StatusChip(
                          label: '${visit.type.label} visit',
                          color: theme.colorScheme.primary,
                        ),
                        if (visit.qrVerified)
                          const StatusChip(
                            label: 'QR verified',
                            color: AppColors.success,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (isEmployee) ...[
          const SectionHeader(title: 'Visit actions'),
          VisitActionPanel(visit: visit),
        ],
        const SectionHeader(title: 'Visit details'),
        AppCard(
          child: Column(
            children: [
              DetailRow(
                icon: Icons.business_rounded,
                label: 'Customer',
                value: visit.customer,
              ),
              DetailRow(
                icon: Icons.person_outline_rounded,
                label: 'Assigned employee',
                value: visit.employee,
              ),
              DetailRow(
                icon: Icons.place_outlined,
                label: 'Location',
                value: visit.location,
              ),
              DetailRow(
                icon: Icons.event_rounded,
                label: 'Scheduled',
                value: visit.scheduleLabel(context),
              ),
              DetailRow(
                icon: Icons.flag_outlined,
                label: 'Purpose',
                value: visit.purpose,
              ),
              if (duration != null)
                DetailRow(
                  icon: Icons.timer_outlined,
                  label: 'Duration',
                  value: _formatDuration(duration),
                ),
            ],
          ),
        ),
        const SectionHeader(title: 'Notes'),
        VisitNotesSection(notes: visit.notes),
        const SectionHeader(title: 'Attachments'),
        VisitAttachmentsSection(attachments: visit.attachments),
        const SectionHeader(title: 'Visit history'),
        VisitHistorySection(history: history),
        const SectionHeader(title: 'Timeline'),
        VisitTimelineSection(events: visit.events),
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
        SkeletonBox(height: 120, radius: AppRadius.lg),
        SizedBox(height: AppSpacing.lg),
        SkeletonBox(height: 220, radius: AppRadius.lg),
      ],
    );
  }
}