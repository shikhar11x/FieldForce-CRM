import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/adaptive_wrap.dart';
import '../../../core/widgets/skeleton_box.dart';
import 'report_layout.dart';

/// Invalidates a report and waits for the reload so the pull-to-refresh
/// spinner stays visible. Errors are shown by the report's error state.
Future<void> refreshReport(
  void Function() invalidate,
  Future<Object?> Function() reload,
) async {
  invalidate();
  try {
    await reload();
  } catch (_) {
    // Rendered by AsyncValueView.
  }
}

/// Pull-to-refresh scroll container used by every report tab.
class ReportScrollView extends StatelessWidget {
  const ReportScrollView({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [child],
      ),
    );
  }
}

class ReportSkeleton extends StatelessWidget {
  const ReportSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.xl),
        AdaptiveWrap(
          columns: reportFourColumns,
          children: List.generate(
            4,
            (_) => const SkeletonBox(height: 112, radius: AppRadius.lg),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AdaptiveWrap(
          columns: reportChartColumns,
          children: List.generate(
            2,
            (_) => const SkeletonBox(height: 270, radius: AppRadius.lg),
          ),
        ),
      ],
    );
  }
}