import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/adaptive_wrap.dart';
import '../../../core/widgets/skeleton_box.dart';
import 'dashboard_layout.dart';

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.xl),
        AdaptiveWrap(
          columns: DashboardLayout.kpiColumns,
          children: List.generate(
            6,
            (_) => const SkeletonBox(height: 112, radius: AppRadius.lg),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AdaptiveWrap(
          columns: DashboardLayout.chartColumns,
          children: List.generate(
            2,
            (_) => const SkeletonBox(height: 270, radius: AppRadius.lg),
          ),
        ),
      ],
    );
  }
}