import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/extensions/lead_style_extensions.dart';
import '../../../core/extensions/task_style_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/icon_text.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/lead_models.dart';

/// Kanban board: one column per stage. Stage changes use each card's
/// "Move to" menu, which avoids drag conflicts with horizontal scrolling.
class LeadPipelineBoard extends StatelessWidget {
  const LeadPipelineBoard({
    super.key,
    required this.leads,
    required this.onOpen,
    required this.onMove,
    this.showAssignee = true,
  });

  final List<LeadItem> leads;
  final void Function(LeadItem lead) onOpen;
  final void Function(LeadItem lead, LeadStage stage) onMove;
  final bool showAssignee;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnWidth = constraints.maxWidth >= 900
            ? 300.0
            : math.min(300.0, constraints.maxWidth * 0.82);

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: LeadStage.values.length,
          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
          itemBuilder: (context, i) {
            final stage = LeadStage.values[i];
            return SizedBox(
              width: columnWidth,
              child: _StageColumn(
                stage: stage,
                leads: leads.where((l) => l.stage == stage).toList(),
                onOpen: onOpen,
                onMove: onMove,
                showAssignee: showAssignee,
              ),
            );
          },
        );
      },
    );
  }
}

class _StageColumn extends StatelessWidget {
  const _StageColumn({
    required this.stage,
    required this.leads,
    required this.onOpen,
    required this.onMove,
    required this.showAssignee,
  });

  final LeadStage stage;
  final List<LeadItem> leads;
  final void Function(LeadItem lead) onOpen;
  final void Function(LeadItem lead, LeadStage stage) onMove;
  final bool showAssignee;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final total = leads.fold<double>(0, (sum, l) => sum + l.value);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: AppRadius.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: stage.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(stage.label, style: theme.textTheme.titleSmall),
              ),
              StatusChip(label: '${leads.length}', color: stage.color),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            formatInr(total),
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: leads.isEmpty
                ? Center(
                    child: Text(
                      'No leads',
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  )
                : ListView.separated(
                    itemCount: leads.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, i) => _CompactCard(
                      lead: leads[i],
                      showAssignee: showAssignee,
                      onTap: () => onOpen(leads[i]),
                      onMove: (target) => onMove(leads[i], target),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CompactCard extends StatelessWidget {
  const _CompactCard({
    required this.lead,
    required this.showAssignee,
    required this.onTap,
    required this.onMove,
  });

  final LeadItem lead;
  final bool showAssignee;
  final VoidCallback onTap;
  final void Function(LeadStage stage) onMove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lead.customer,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    Text(
                      lead.contactName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<LeadStage>(
                tooltip: 'Move to stage',
                padding: EdgeInsets.zero,
                iconSize: 20,
                onSelected: onMove,
                itemBuilder: (context) => [
                  const PopupMenuItem<LeadStage>(
                    enabled: false,
                    child: Text('Move to'),
                  ),
                  for (final stage in LeadStage.values)
                    if (stage != lead.stage)
                      PopupMenuItem<LeadStage>(
                        value: stage,
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: stage.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Text(stage.label),
                          ],
                        ),
                      ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Text(formatInr(lead.value), style: theme.textTheme.titleMedium),
              const Spacer(),
              StatusChip(
                label: lead.priority.label,
                color: lead.priority.color,
              ),
            ],
          ),
          if (showAssignee) ...[
            const SizedBox(height: AppSpacing.sm),
            IconText(
              icon: Icons.person_outline_rounded,
              text: lead.assignee,
            ),
          ],
        ],
      ),
    );
  }
}