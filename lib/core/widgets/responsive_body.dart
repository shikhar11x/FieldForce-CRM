import 'package:flutter/widgets.dart';

import '../theme/app_spacing.dart';
import '../utils/responsive.dart';

/// Centers content with a max width and breakpoint-aware padding.
class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({super.key, required this.child, this.maxWidth = 1200});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.isPhone ? AppSpacing.lg : AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          child: child,
        ),
      ),
    );
  }
}