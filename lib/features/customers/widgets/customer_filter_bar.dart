import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../providers/customer_filters_provider.dart';

/// Search field, filter chips and sort control.
class CustomerFilterBar extends ConsumerStatefulWidget {
  const CustomerFilterBar({super.key, this.resultCount});

  final int? resultCount;

  @override
  ConsumerState<CustomerFilterBar> createState() => _CustomerFilterBarState();
}

class _CustomerFilterBarState extends ConsumerState<CustomerFilterBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filters = ref.watch(customerFiltersProvider);
    final notifier = ref.read(customerFiltersProvider.notifier);
    final count = widget.resultCount;

    // Keeps the text field in sync when filters are reset elsewhere
    // (for example the "Clear filters" button in the empty state).
    ref.listen(customerFiltersProvider, (_, next) {
      if (next.query.isEmpty && _controller.text.isNotEmpty) {
        _controller.clear();
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          textInputAction: TextInputAction.search,
          onChanged: notifier.setQuery,
          decoration: InputDecoration(
            hintText: 'Search company, contact or phone',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: filters.query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      _controller.clear();
                      notifier.setQuery('');
                    },
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: CustomerFilter.values.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, i) {
              final filter = CustomerFilter.values[i];
              return ChoiceChip(
                label: Text(filter.label),
                selected: filters.filter == filter,
                showCheckmark: false,
                onSelected: (_) => notifier.setFilter(filter),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: Text(
                count == null
                    ? ''
                    : '$count ${count == 1 ? 'customer' : 'customers'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            PopupMenuButton<CustomerSort>(
              tooltip: 'Sort',
              onSelected: notifier.setSort,
              itemBuilder: (context) => [
                for (final sort in CustomerSort.values)
                  CheckedPopupMenuItem<CustomerSort>(
                    value: sort,
                    checked: sort == filters.sort,
                    child: Text(sort.label),
                  ),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.sort_rounded,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      filters.sort.label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}