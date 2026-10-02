import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/animate_extensions.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../../data/models/lead_models.dart';
import '../../../data/models/user_role.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/lead_filters_provider.dart';
import '../providers/lead_provider.dart';
import '../widgets/lead_card.dart';
import '../widgets/lead_filter_bar.dart';
import '../widgets/lead_pipeline_board.dart';
import '../widgets/lead_summary_bar.dart';

class LeadsScreen extends ConsumerWidget {
  const LeadsScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(leadsProvider);
    try {
      await ref.read(leadsProvider.future);
    } catch (_) {
      // The error state is rendered by AsyncValueView.
    }
  }

  Future<void> _move(
    BuildContext context,
    WidgetRef ref,
    LeadItem lead,
    LeadStage stage,
  ) async {
    try {
      await ref.read(leadsProvider.notifier).changeStage(lead, stage);
      if (context.mounted) {
        context.showSnack('${lead.customer} moved to ${stage.label}.');
      }
    } catch (_) {
      if (context.mounted) {
        context.showSnack('Could not move the lead. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final view = ref.watch(leadViewProvider);
    final filters = ref.watch(leadFiltersProvider);
    final scoped = ref.watch(scopedLeadsProvider);
    final listLeads = ref.watch(filteredLeadsProvider);
    final summary = ref.watch(leadSummaryProvider);

    // Briefly null while the router redirects after logout.
    if (user == null) return const SizedBox.shrink();

    final isPipeline = view == LeadView.pipeline;
    final showAssignee = user.role != UserRole.employee;

    // The board ignores the stage tab: it already shows every stage.
    final pipelineLeads = scoped.whenData(
      (list) => applyLeadFilters(list, LeadFilters(query: filters.query)),
    );
    final leads = isPipeline ? pipelineLeads : listLeads;

    void open(LeadItem lead) =>
        context.push('${user.role.basePath}/leads/${lead.id}');

    final Widget emptyView = filters.isActive
        ? EmptyState(
            icon: Icons.search_off_rounded,
            title: 'No leads found',
            message: 'Try a different search or clear your filters.',
            actionLabel: 'Clear filters',
            onAction: ref.read(leadFiltersProvider.notifier).reset,
          )
        : EmptyState(
            icon: Icons.filter_alt_outlined,
            title: 'No leads yet',
            message: 'Create your first lead to start building a pipeline.',
            actionLabel: 'New lead',
            onAction: () => context.push('${user.role.basePath}/leads/new'),
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leads'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: SegmentedButton<LeadView>(
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
              segments: const [
                ButtonSegment<LeadView>(
                  value: LeadView.list,
                  icon: Icon(Icons.view_agenda_outlined),
                  tooltip: 'List view',
                ),
                ButtonSegment<LeadView>(
                  value: LeadView.pipeline,
                  icon: Icon(Icons.view_column_outlined),
                  tooltip: 'Pipeline view',
                ),
              ],
              selected: {view},
              onSelectionChanged: (s) =>
                  ref.read(leadViewProvider.notifier).set(s.first),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('${user.role.basePath}/leads/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New lead'),
      ),
      body: ResponsiveBody(
        maxWidth: isPipeline ? 1400 : 900,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LeadSummaryBar(summary: summary),
            const SizedBox(height: AppSpacing.md),
            LeadFilterBar(
              resultCount: leads.value?.length,
              showListControls: !isPipeline,
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: AsyncValueView<List<LeadItem>>(
                value: leads,
                onRetry: () => ref.invalidate(leadsProvider),
                loading: const _ListSkeleton(),
                isEmpty: (list) => list.isEmpty,
                empty: emptyView,
                data: (list) {
                  if (isPipeline) {
                    return LeadPipelineBoard(
                      leads: list,
                      showAssignee: showAssignee,
                      onOpen: open,
                      onMove: (lead, stage) => _move(context, ref, lead, stage),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => _refresh(ref),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 88),
                      itemCount: list.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, i) {
                        final lead = list[i];
                        return LeadCard(
                          lead: lead,
                          showAssignee: showAssignee,
                          onTap: () => open(lead),
                        ).entrance(math.min(i, 5));
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (var i = 0; i < 4; i++) ...[
          const SkeletonBox(height: 160, radius: AppRadius.lg),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}