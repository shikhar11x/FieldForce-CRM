import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/models/lead_models.dart';
import '../providers/lead_filters_provider.dart';

/// Search field plus, in list view, stage tabs (with counts) and sort.
class LeadFilterBar extends ConsumerStatefulWidget {
  const LeadFilterBar({
    super.key,
    this.resultCount,
    this.showListControls = true,
  });

  final int? resultCount;
  final bool showListControls;

  @override
  ConsumerState<LeadFilterBar> createState() => _LeadFilterBarState();
}

class _LeadFilterBarState extends ConsumerState<LeadFilterBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filters = ref.watch(leadFiltersProvider);
    final notifier = ref.read(leadFiltersProvider.notifier);
    final counts = ref.watch(leadStageCountsProvider);
    final count = widget.resultCount;
    final tabs = <LeadStage?>[null, ...LeadStage.values];

    // Keeps the text field in sync when filters are reset elsewhere.
    ref.listen(leadFiltersProvider, (_, next) {
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
            hintText: 'Search customer, contact or employee',
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
        if (widget.showListControls) ...[
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, i) {
                final stage = tabs[i];
                final label = stage?.label ?? 'All';
                return ChoiceChip(
                  label: Text('$label ${counts[stage] ?? 0}'),
                  selected: filters.stage == stage,
                  showCheckmark: false,
                  onSelected: (_) => notifier.setStage(stage),
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
                      : '$count ${count == 1 ? 'lead' : 'leads'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              PopupMenuButton<LeadSort>(
                tooltip: 'Sort',
                onSelected: notifier.setSort,
                itemBuilder: (context) => [
                  for (final sort in LeadSort.values)
                    CheckedPopupMenuItem<LeadSort>(
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
      ],
    );
  }
}