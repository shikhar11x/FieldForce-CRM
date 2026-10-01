import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../data/models/chart_point.dart';
import '../../theme/app_spacing.dart';

class AppDonutChart extends StatelessWidget {
  const AppDonutChart({
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
    final theme = Theme.of(context);
    final total = segments.fold<double>(0, (sum, s) => sum + s.value);

    return Row(
      children: [
        SizedBox.square(
          dimension: 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 46,
                  sections: [
                    for (final (i, s) in segments.indexed)
                      PieChartSectionData(
                        value: s.value,
                        color: colors[i % colors.length],
                        radius: 22,
                        showTitle: false,
                      ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    total.toInt().toString(),
                    style: theme.textTheme.titleLarge,
                  ),
                  Text(
                    centerLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final (i, s) in segments.indexed)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colors[i % colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          s.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      Text(
                        s.value.toInt().toString(),
                        style: theme.textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}