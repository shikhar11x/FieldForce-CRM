import 'package:flutter/material.dart';

import 'adaptive_wrap.dart';
import 'stat_card.dart';

class StatGridItem {
  const StatGridItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.changePercent,
    this.lowerIsBetter = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final double? changePercent;
  final bool lowerIsBetter;
}

/// Responsive grid of [StatCard]s. Screens map their own models to items.
class StatGrid extends StatelessWidget {
  const StatGrid({super.key, required this.items, required this.columns});

  final List<StatGridItem> items;
  final int Function(double maxWidth) columns;

  @override
  Widget build(BuildContext context) {
    return AdaptiveWrap(
      columns: columns,
      children: [
        for (final item in items)
          StatCard(
            label: item.label,
            value: item.value,
            icon: item.icon,
            color: item.color,
            changePercent: item.changePercent,
            lowerIsBetter: item.lowerIsBetter,
          ),
      ],
    );
  }
}