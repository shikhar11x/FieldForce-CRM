import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../providers/user_filters_provider.dart';

/// Search field and filter chips (with counts).
class UserFilterBar extends ConsumerStatefulWidget {
  const UserFilterBar({super.key, required this.chips, this.resultCount});

  final List<UserFilter> chips;
  final int? resultCount;

  @override
  ConsumerState<UserFilterBar> createState() => _UserFilterBarState();
}

class _UserFilterBarState extends ConsumerState<UserFilterBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filters = ref.watch(userFiltersProvider);
    final notifier = ref.read(userFiltersProvider.notifier);
    final counts = ref.watch(userFilterCountsProvider);
    final count = widget.resultCount;

    // Keeps the text field in sync when filters are reset elsewhere.
    ref.listen(userFiltersProvider, (_, next) {
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
            hintText: 'Search name, email or team',
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
            itemCount: widget.chips.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, i) {
              final filter = widget.chips[i];
              return ChoiceChip(
                label: Text('${filter.label} ${counts[filter] ?? 0}'),
                selected: filters.filter == filter,
                showCheckmark: false,
                onSelected: (_) => notifier.setFilter(filter),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          count == null ? '' : '$count ${count == 1 ? 'person' : 'people'}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}