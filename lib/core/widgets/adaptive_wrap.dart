import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/app_spacing.dart';

/// Lays children out in equal-width columns. [columns] receives the
/// available width, so each screen decides its own breakpoints.
class AdaptiveWrap extends StatelessWidget {
  const AdaptiveWrap({
    super.key,
    required this.children,
    required this.columns,
    this.spacing = AppSpacing.md,
  });

  final List<Widget> children;
  final int Function(double maxWidth) columns;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = math.max(1, columns(constraints.maxWidth));
        final itemWidth =
            (constraints.maxWidth - spacing * (count - 1)) / count;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}