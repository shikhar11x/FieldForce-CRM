import 'package:flutter/material.dart';

import '../../../core/extensions/task_style_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/route_preview.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/employee_models.dart';
import '../../../data/models/task_enums.dart';

class RouteSection extends StatelessWidget {
  const RouteSection({super.key, required this.stops});

  final List<RouteStop> stops;

  @override
  Widget build(BuildContext context) {
    if (stops.isEmpty) {
      return const AppCard(
        child: EmptyState(
          icon: Icons.route_rounded,
          title: 'No visits scheduled',
          message: 'Your route for today will show up here.',
        ),
      );
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          RoutePreview(
            points: [
              for (final s in stops)
                RoutePoint(
                  x: s.x,
                  y: s.y,
                  completed: s.status == VisitStatus.completed,
                ),
            ],
          ),
          for (final (i, stop) in stops.indexed) ...[
            const Divider(),
            _StopRow(index: i + 1, stop: stop),
          ],
        ],
      ),
    );
  }
}

class _StopRow extends StatelessWidget {
  const _StopRow({required this.index, required this.stop});

  final int index;
  final RouteStop stop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final color = stop.status.color;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: color,
            child: Text(
              '$index',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop.customer,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  stop.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(stop.time, style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              StatusChip(label: stop.status.label, color: color),
            ],
          ),
        ],
      ),
    );
  }
}