import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/models/task_enums.dart';
import '../providers/visit_filters_provider.dart';

/// Search field, status tabs (with counts) and sort.
class VisitFilterBar extends ConsumerStatefulWidget {
  const VisitFilterBar({super.key, this.resultCount});

  final int? resultCount;

  @override
  ConsumerState<VisitFilterBar> createState() => _VisitFilterBarState();
}

class _VisitFilterBarState extends ConsumerState<VisitFilterBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filters = ref.watch(visitFiltersProvider);
    final notifier = ref.read(visitFiltersProvider.notifier);
    final counts = ref.watch(visitStatusCountsProvider);
    final count = widget.resultCount;
    final tabs = <VisitStatus?>[null, ...VisitStatus.values];

    // Keeps the text field in sync when filters are reset elsewhere.
    ref.listen(visitFiltersProvider, (_, next) {
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
            hintText: 'Search customer, employee or location',
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
            itemCount: tabs.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, i) {
              final status = tabs[i];
              final label = status?.label ?? 'All';
              return ChoiceChip(
                label: Text('$label ${counts[status] ?? 0}'),
                selected: filters.status == status,
                showCheckmark: false,
                onSelected: (_) => notifier.setStatus(status),
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
                    : '$count ${count == 1 ? 'visit' : 'visits'}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            PopupMenuButton<VisitSort>(
              tooltip: 'Sort',
              onSelected: notifier.setSort,
              itemBuilder: (context) => [
                for (final sort in VisitSort.values)
                  CheckedPopupMenuItem<VisitSort>(
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
                    const SizedBox(width: 4),
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