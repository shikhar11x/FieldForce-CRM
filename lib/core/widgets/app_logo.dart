import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 72,
    this.showWordmark = false,
    this.onDark = false,
  });

  final double size;
  final bool showWordmark;

  /// Use a white badge when placed on the brand gradient.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: onDark ? null : AppColors.brandGradient,
        color: onDark ? Colors.white : null,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: size * 0.3,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: Icon(
        Icons.explore_rounded,
        size: size * 0.56,
        color: onDark ? AppColors.primary : Colors.white,
      ),
    );

    if (!showWordmark) return badge;

    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        badge,
        const SizedBox(height: 16),
        Text(
          AppConstants.appName,
          style: textTheme.headlineSmall?.copyWith(
            color: onDark ? Colors.white : null,
          ),
        ),
      ],
    );
  }
}