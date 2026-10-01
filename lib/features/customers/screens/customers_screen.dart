import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/animate_extensions.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../../data/models/customer_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/customer_filters_provider.dart';
import '../providers/customer_provider.dart';
import '../widgets/customer_card.dart';
import '../widgets/customer_filter_bar.dart';

class CustomersScreen extends ConsumerWidget {
  const CustomersScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(customersProvider);
    try {
      await ref.read(customersProvider.future);
    } catch (_) {
      // The error state is rendered by AsyncValueView.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final customers = ref.watch(filteredCustomersProvider);
    final filters = ref.watch(customerFiltersProvider);

    // Briefly null while the router redirects after logout.
    if (user == null) return const SizedBox.shrink();

    final Widget emptyView = filters.isActive
        ? EmptyState(
            icon: Icons.search_off_rounded,
            title: 'No customers found',
            message: 'Try a different search or clear your filters.',
            actionLabel: 'Clear filters',
            onAction: ref.read(customerFiltersProvider.notifier).reset,
          )
        : const EmptyState(
            icon: Icons.business_outlined,
            title: 'No customers found',
            message: 'Customers assigned to you will appear here.',
          );

    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.showSnack('Add Customer arrives in an upcoming step.'),
        icon: const Icon(Icons.add_business_rounded),
        label: const Text('Add customer'),
      ),
      body: ResponsiveBody(
        maxWidth: 900,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomerFilterBar(resultCount: customers.value?.length),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: AsyncValueView<List<Customer>>(
                value: customers,
                onRetry: () => ref.invalidate(customersProvider),
                loading: const _ListSkeleton(),
                isEmpty: (list) => list.isEmpty,
                empty: emptyView,
                data: (list) => RefreshIndicator(
                  onRefresh: () => _refresh(ref),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: list.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, i) {
                      final customer = list[i];
                      return CustomerCard(
                        customer: customer,
                        onTap: () => context.go(
                          '${user.role.basePath}/customers/${customer.id}',
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
          const SkeletonBox(height: 168, radius: AppRadius.lg),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}