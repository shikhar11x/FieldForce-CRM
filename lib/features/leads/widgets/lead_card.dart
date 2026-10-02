import 'package:flutter/material.dart';

import '../../../core/extensions/datetime_extensions.dart';
import '../../../core/extensions/lead_style_extensions.dart';
import '../../../core/extensions/task_style_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/icon_text.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/lead_models.dart';

class LeadCard extends StatelessWidget {
  const LeadCard({
    super.key,
    required this.lead,
    required this.onTap,
    this.showAssignee = true,
  });

  final LeadItem lead;
  final VoidCallback onTap;
  final bool showAssignee;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return AppCard(
      onTap: onTap,
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
              const SizedBox(width: AppSpacing.sm),
              StatusChip(label: lead.stage.label, color: lead.stage.color),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(formatInr(lead.value), style: theme.textTheme.titleLarge),
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
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(),
          ),
          Row(
            children: [
              Expanded(
                child: _Info(
                  label: 'Last activity',
                  value: lead.lastActivity.timeAgo,
                ),
              ),
              Expanded(
                child: _Info(
                  label: 'Expected close',
                  value: lead.expectedClose.shortDate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelLarge,
        ),
      ],
    );
  }
}