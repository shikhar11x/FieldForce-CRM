import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/datetime_extensions.dart';
import '../../../core/extensions/lead_style_extensions.dart';
import '../../../core/extensions/task_style_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/detail_row.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/note_sheet.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/timeline_tile.dart';
import '../../../data/models/lead_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/lead_provider.dart';
import '../widgets/lead_stage_progress.dart';

class LeadDetailScreen extends ConsumerWidget {
  const LeadDetailScreen({super.key, required this.leadId});

  final String leadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final leads = ref.watch(leadsProvider);

    // Briefly null while the router redirects after logout.
    if (user == null) return const SizedBox.shrink();

    final list = leads.value;
    final lead = list == null ? null : findLead(list, leadId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lead details'),
        actions: [
          if (lead != null)
            IconButton(
              tooltip: 'Edit lead',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  context.push('${user.role.basePath}/leads/$leadId/edit'),
            ),
        ],
      ),
      body: ResponsiveBody(
        maxWidth: 700,
        child: AsyncValueView<List<LeadItem>>(
          value: leads,
          onRetry: () => ref.invalidate(leadsProvider),
          loading: const _DetailSkeleton(),
          data: (_) => lead == null
              ? const EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'Lead not found',
                  message: 'It may have been removed.',
                )
              : _LeadDetailContent(lead: lead),
        ),
      ),
    );
  }
}

class _LeadDetailContent extends ConsumerStatefulWidget {
  const _LeadDetailContent({required this.lead});

  final LeadItem lead;

  @override
  ConsumerState<_LeadDetailContent> createState() =>
      _LeadDetailContentState();
}

class _LeadDetailContentState extends ConsumerState<_LeadDetailContent> {
  bool _busy = false;

  LeadItem get _lead => widget.lead;

  Future<void> _run(Future<void> Function() action, String message) async {
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) context.showSnack(message);
    } catch (_) {
      if (mounted) {
        context.showSnack('Could not update the lead. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addNote() async {
    final text = await showNoteSheet(
      context,
      title: 'Add lead note',
      hint: 'Log a call, meeting or update',
    );
    if (text == null || !mounted) return;
    final author = ref.read(authProvider).user?.name ?? 'You';
    await _run(
      () => ref.read(leadsProvider.notifier).addNote(_lead, author, text),
      'Note added.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final lead = _lead;
    final description = lead.description.trim();

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InitialsAvatar(name: lead.customer, radius: 26),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lead.customer, style: theme.textTheme.titleLarge),
                        Text(
                          lead.contactName,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                formatInr(lead.value),
                style: theme.textTheme.headlineMedium,
              ),
              Text(
                'Deal value',
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  StatusChip(label: lead.stage.label, color: lead.stage.color),
                  StatusChip(
                    label: '${lead.priority.label} priority',
                    color: lead.priority.color,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              LeadStageProgress(stage: lead.stage),
            ],
          ),
        ),
        const SectionHeader(title: 'Update stage'),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final stage in LeadStage.values)
              ChoiceChip(
                label: Text(stage.label),
                selected: lead.stage == stage,
                showCheckmark: false,
                selectedColor: stage.color.withValues(alpha: 0.2),
                onSelected: _busy
                    ? null
                    : (_) {
                        if (lead.stage == stage) return;
                        _run(
                          () => ref
                              .read(leadsProvider.notifier)
                              .changeStage(lead, stage),
                          'Moved to ${stage.label}.',
                        );
                      },
              ),
          ],
        ),
        const SectionHeader(title: 'Details'),
        AppCard(
          child: Column(
            children: [
              DetailRow(
                icon: Icons.person_outline_rounded,
                label: 'Contact person',
                value: lead.contactName,
              ),
              DetailRow(
                icon: Icons.badge_outlined,
                label: 'Assigned to',
                value: lead.assignee,
              ),
              DetailRow(
                icon: Icons.campaign_outlined,
                label: 'Source',
                value: lead.source,
              ),
              DetailRow(
                icon: Icons.event_rounded,
                label: 'Expected close',
                value: lead.expectedClose.shortDate,
              ),
              DetailRow(
                icon: Icons.history_rounded,
                label: 'Created',
                value: lead.createdAt.shortDate,
              ),
            ],
          ),
        ),
        if (description.isNotEmpty) ...[
          const SectionHeader(title: 'About this lead'),
          AppCard(
            child: SizedBox(
              width: double.infinity,
              child: Text(description, style: theme.textTheme.bodyMedium),
            ),
          ),
        ],
        SectionHeader(
          title: 'Activity',
          actionLabel: 'Add note',
          onAction: _busy ? null : _addNote,
        ),
        AppCard(
          child: Column(
            children: [
              for (final (i, item) in lead.activities.indexed)
                TimelineTile(
                  icon: item.type.icon,
                  color: item.type.color,
                  title: item.title,
                  subtitle:
                      item.description.isEmpty ? null : item.description,
                  meta: item.timestamp.timeAgo,
                  isLast: i == lead.activities.length - 1,
                ),
            ],
          ),
        ),
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
        SkeletonBox(height: 190, radius: AppRadius.lg),
        SizedBox(height: AppSpacing.lg),
        SkeletonBox(height: 60, radius: AppRadius.lg),
        SizedBox(height: AppSpacing.lg),
        SkeletonBox(height: 200, radius: AppRadius.lg),
      ],
    );
  }
}