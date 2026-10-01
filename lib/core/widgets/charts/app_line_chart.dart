import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../data/models/chart_point.dart';
import '../../utils/chart_utils.dart';

class AppLineChart extends StatelessWidget {
  const AppLineChart({
    super.key,
    required this.points,
    this.color,
    this.minY,
    this.maxY,
  });

  final List<ChartPoint> points;
  final Color? color;

  /// Provide both to fix the axis range (e.g. a percentage band).
  final double? minY;
  final double? maxY;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lineColor = color ?? theme.colorScheme.primary;
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    final bottom = minY ?? 0;
    final fixedMax = maxY;
    final double top;
    final double interval;
    if (fixedMax != null) {
      top = fixedMax;
      interval = (fixedMax - bottom) / 4;
    } else {
      final dataMax = points.fold<double>(0, (a, p) => math.max(a, p.value));
      final scale = niceScale(dataMax);
      top = scale.max;
      interval = scale.interval;
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (points.length - 1).toDouble(),
        minY: bottom,
        maxY: top,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (_) => FlLine(
            color: theme.colorScheme.outlineVariant,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 38,
              interval: interval,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                child: Text(formatAxisValue(value), style: labelStyle),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final i = value.round();
                final onTick = (value - i).abs() < 0.01;
                if (!onTick || i < 0 || i >= points.length) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(points[i].label, style: labelStyle),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (final (i, p) in points.indexed)
                FlSpot(i.toDouble(), p.value),
            ],
            isCurved: true,
            color: lineColor,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  lineColor.withValues(alpha: 0.25),
                  lineColor.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}