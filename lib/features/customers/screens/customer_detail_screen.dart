import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../../data/models/customer_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/customer_provider.dart';
import '../widgets/detail/activity_tab.dart';
import '../widgets/detail/documents_tab.dart';
import '../widgets/detail/notes_tab.dart';
import '../widgets/detail/overview_tab.dart';
import '../widgets/detail/tasks_tab.dart';
import '../widgets/detail/visits_tab.dart';

class CustomerDetailScreen extends ConsumerWidget {
  const CustomerDetailScreen({super.key, required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(customerDetailProvider(customerId));
    final role = ref.watch(authProvider.select((s) => s.user?.role));

    // Briefly null while the router redirects after logout.
    if (role == null) return const SizedBox.shrink();

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: Text(detail.value?.customer.company ?? 'Customer'),
          actions: [
            if (detail.hasValue)
              IconButton(
                tooltip: 'Edit customer',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () =>
                    context.go('${role.basePath}/customers/$customerId/edit'),
              ),
          ],
          bottom: detail.hasValue
              ? const TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: [
                    Tab(text: 'Overview'),
                    Tab(text: 'Activity'),
                    Tab(text: 'Visits'),
                    Tab(text: 'Tasks'),
                    Tab(text: 'Notes'),
                    Tab(text: 'Documents'),
                  ],
                )
              : null,
        ),
        body: ResponsiveBody(
          maxWidth: 900,
          child: AsyncValueView<CustomerDetail>(
            value: detail,
            onRetry: () => ref.invalidate(customerDetailProvider(customerId)),
            loading: const _DetailSkeleton(),
            data: (d) => TabBarView(
              children: [
                OverviewTab(customer: d.customer, role: role),
                ActivityTab(items: d.activities),
                VisitsTab(visits: d.visits),
                TasksTab(customerName: d.customer.company, role: role),
                NotesTab(customerId: d.customer.id, notes: d.notes),
                DocumentsTab(documents: d.documents),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SkeletonBox(height: 110, radius: AppRadius.lg),
        SizedBox(height: AppSpacing.lg),
        SkeletonBox(height: 140, radius: AppRadius.lg),
        SizedBox(height: AppSpacing.lg),
        SkeletonBox(height: 100, radius: AppRadius.lg),
      ],
    );
  }
}