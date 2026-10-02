import 'package:flutter/material.dart';

import '../../../core/extensions/task_style_extensions.dart';
import '../../../core/extensions/visit_style_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/icon_text.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/visit_models.dart';

class VisitCard extends StatelessWidget {
  const VisitCard({
    super.key,
    required this.visit,
    required this.onTap,
    this.showEmployee = true,
  });

  final VisitItem visit;
  final VoidCallback onTap;
  final bool showEmployee;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  visit.customer,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              StatusChip(label: visit.status.label, color: visit.status.color),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          IconText(icon: visit.type.icon, text: '${visit.type.label} visit'),
          const SizedBox(height: 4),
          IconText(icon: Icons.place_outlined, text: visit.location),
          if (showEmployee) ...[
            const SizedBox(height: 4),
            IconText(
              icon: Icons.person_outline_rounded,
              text: visit.employee,
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(),
          ),
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  visit.scheduleLabel(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge,
                ),
              ),
              if (visit.qrVerified) ...[
                const SizedBox(width: AppSpacing.sm),
                const StatusChip(
                  label: 'QR verified',
                  color: AppColors.success,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}