import 'package:flutter/material.dart';

import '../../../core/extensions/customer_style_extensions.dart';
import '../../../core/extensions/datetime_extensions.dart';
import '../../../core/extensions/task_style_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/customer_models.dart';
import '../../../data/models/task_enums.dart';

class CustomerCard extends StatelessWidget {
  const CustomerCard({super.key, required this.customer, required this.onTap});

  final Customer customer;
  final VoidCallback onTap;

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
            children: [
              InitialsAvatar(name: customer.company),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.company,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    Text(
                      customer.contactName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              StatusChip(
                label: customer.status.label,
                color: customer.status.color,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _IconText(icon: Icons.phone_outlined, text: customer.phone),
          const SizedBox(height: 4),
          _IconText(icon: Icons.place_outlined, text: customer.address),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _IconText(
                  icon: Icons.person_outline_rounded,
                  text: customer.assignedEmployee,
                ),
              ),
              if (customer.highPriority) ...[
                const SizedBox(width: AppSpacing.sm),
                StatusChip(
                  label: 'High priority',
                  color: TaskPriority.high.color,
                ),
              ],
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(),
          ),
          Row(
            children: [
              Expanded(
                child: _VisitInfo(
                  label: 'Last visit',
                  value: customer.lastVisit?.dayLabel ?? 'No visits yet',
                ),
              ),
              Expanded(
                child: _VisitInfo(
                  label: 'Next visit',
                  value: customer.nextVisit?.dayLabel ?? 'Not scheduled',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconText extends StatelessWidget {
  const _IconText({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Row(
      children: [
        Icon(icon, size: 16, color: muted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
        ),
      ],
    );
  }
}

class _VisitInfo extends StatelessWidget {
  const _VisitInfo({required this.label, required this.value});

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