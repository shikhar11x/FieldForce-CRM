import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/app_card.dart';
import '../providers/lead_provider.dart';

class LeadSummaryBar extends StatelessWidget {
  const LeadSummaryBar({super.key, required this.summary});

  final LeadSummary summary;

  @override
  Widget build(BuildContext context) {
    final rate = summary.winRate;

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _Metric(
                value: formatInr(summary.openValue),
                label: 'Open pipeline',
              ),
            ),
            const VerticalDivider(width: AppSpacing.xl),
            Expanded(
              child: _Metric(
                value: formatInr(summary.wonValue),
                label: 'Won',
              ),
            ),
            const VerticalDivider(width: AppSpacing.xl),
            Expanded(
              child: _Metric(
                value: rate == null ? '-' : '${(rate * 100).round()}%',
                label: 'Win rate',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, style: theme.textTheme.titleLarge),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}