import 'package:flutter/material.dart';

import '../../../core/widgets/charts/app_donut_chart.dart';
import '../../../data/models/chart_point.dart';

/// Donut that shows a message instead of drawing when every segment is 0
/// (for example a one-day custom range with no leads).
class ReportDonut extends StatelessWidget {
  const ReportDonut({
    super.key,
    required this.segments,
    required this.colors,
    required this.centerLabel,
  });

  final List<ChartPoint> segments;
  final List<Color> colors;
  final String centerLabel;

  @override
  Widget build(BuildContext context) {
    final total = segments.fold<double>(0, (sum, s) => sum + s.value);

    if (total <= 0) {
      final theme = Theme.of(context);
      return Center(
        child: Text(
          'No data for this period',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return AppDonutChart(
      segments: segments,
      colors: colors,
      centerLabel: centerLabel,
    );
  }
}