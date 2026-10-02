import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/animate_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../../data/models/user_role.dart';
import '../../../data/models/visit_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/visit_filters_provider.dart';
import '../providers/visit_provider.dart';
import '../widgets/visit_card.dart';
import '../widgets/visit_filter_bar.dart';

class VisitsScreen extends ConsumerWidget {
  const VisitsScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(visitsProvider);
    try {
      await ref.read(visitsProvider.future);
    } catch (_) {
      // The error state is rendered by AsyncValueView.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final visits = ref.watch(filteredVisitsProvider);
    final filters = ref.watch(visitFiltersProvider);

    // Briefly null while the router redirects after logout.
    if (user == null) return const SizedBox.shrink();

    final Widget emptyView = filters.isActive
        ? EmptyState(
            icon: Icons.search_off_rounded,
            title: 'No visits found',
            message: 'Try a different search or clear your filters.',
            actionLabel: 'Clear filters',
            onAction: ref.read(visitFiltersProvider.notifier).reset,
          )
        : const EmptyState(
            icon: Icons.place_outlined,
            title: 'No visits scheduled',
            message: 'Scheduled customer visits will appear here.',
          );

    return Scaffold(
      appBar: AppBar(title: const Text('Visits')),
      body: ResponsiveBody(
        maxWidth: 900,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VisitFilterBar(resultCount: visits.value?.length),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: AsyncValueView<List<VisitItem>>(
                value: visits,
                onRetry: () => ref.invalidate(visitsProvider),
                loading: const _ListSkeleton(),
                isEmpty: (list) => list.isEmpty,
                empty: emptyView,
                data: (list) => RefreshIndicator(
                  onRefresh: () => _refresh(ref),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                    itemCount: list.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, i) {
                      final visit = list[i];
                      return VisitCard(
                        visit: visit,
                        showEmployee: user.role != UserRole.employee,
                        onTap: () => context.go(
                          '${user.role.basePath}/visits/${visit.id}',
                        ),
                      ).entrance(math.min(i, 5));
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (var i = 0; i < 4; i++) ...[
          const SkeletonBox(height: 150, radius: AppRadius.lg),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}