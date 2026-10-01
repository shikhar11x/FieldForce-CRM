import 'package:flutter/material.dart';

import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../core/extensions/task_style_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../data/models/customer_models.dart';

class VisitsTab extends StatelessWidget {
  const VisitsTab({super.key, required this.visits});

  final List<CustomerVisit> visits;

  @override
  Widget build(BuildContext context) {
    if (visits.isEmpty) {
      return const EmptyState(
        icon: Icons.place_outlined,
        title: 'No visits scheduled',
        message: 'Visits with this customer will appear here.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      itemCount: visits.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, i) => _VisitCard(visit: visits[i]),
    );
  }
}

class _VisitCard extends StatelessWidget {
  const _VisitCard({required this.visit});

  final CustomerVisit visit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final time = TimeOfDay.fromDateTime(visit.date).format(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_rounded, size: 16, color: muted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${visit.date.dayLabel} · $time',
                  style: theme.textTheme.labelLarge,
                ),
              ),
              StatusChip(label: visit.status.label, color: visit.status.color),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(visit.purpose, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.person_outline_rounded, size: 16, color: muted),
              const SizedBox(width: 6),
              Text(
                visit.employee,
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}