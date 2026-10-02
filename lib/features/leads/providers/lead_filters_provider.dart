import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/lead_models.dart';
import 'lead_provider.dart';

enum LeadView { list, pipeline }

class LeadViewNotifier extends Notifier<LeadView> {
  @override
  LeadView build() => LeadView.list;

  void set(LeadView view) => state = view;
}

final leadViewProvider =
    NotifierProvider<LeadViewNotifier, LeadView>(LeadViewNotifier.new);

enum LeadSort {
  recentActivity('Recent activity'),
  valueHigh('Value (high to low)'),
  closeDate('Expected close');

  const LeadSort(this.label);
  final String label;
}

class LeadFilters {
  const LeadFilters({
    this.query = '',
    this.stage,
    this.sort = LeadSort.recentActivity,
  });

  final String query;

  /// Null means "All".
  final LeadStage? stage;
  final LeadSort sort;

  bool get isActive => query.trim().isNotEmpty || stage != null;
}

class LeadFiltersNotifier extends Notifier<LeadFilters> {
  @override
  LeadFilters build() => const LeadFilters();

  void setQuery(String query) => state = LeadFilters(
        query: query,
        stage: state.stage,
        sort: state.sort,
      );

  void setStage(LeadStage? stage) => state = LeadFilters(
        query: state.query,
        stage: stage,
        sort: state.sort,
      );

  void setSort(LeadSort sort) => state = LeadFilters(
        query: state.query,
        stage: state.stage,
        sort: sort,
      );

  /// Clears search and stage; keeps the chosen sort order.
  void reset() => state = LeadFilters(sort: state.sort);
}

final leadFiltersProvider =
    NotifierProvider<LeadFiltersNotifier, LeadFilters>(
  LeadFiltersNotifier.new,
);

bool _matchesQuery(LeadItem l, String query) {
  if (query.isEmpty) return true;
  return [l.customer, l.contactName, l.assignee, l.source, l.description]
      .any((value) => value.toLowerCase().contains(query));
}

List<LeadItem> applyLeadFilters(List<LeadItem> source, LeadFilters f) {
  final query = f.query.trim().toLowerCase();

  final result = source.where((l) {
    if (f.stage != null && l.stage != f.stage) return false;
    return _matchesQuery(l, query);
  }).toList();

  switch (f.sort) {
    case LeadSort.recentActivity:
      result.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
    case LeadSort.valueHigh:
      result.sort((a, b) => b.value.compareTo(a.value));
    case LeadSort.closeDate:
      result.sort((a, b) => a.expectedClose.compareTo(b.expectedClose));
  }
  return result;
}

final filteredLeadsProvider =
    Provider.autoDispose<AsyncValue<List<LeadItem>>>((ref) {
  final leads = ref.watch(scopedLeadsProvider);
  final filters = ref.watch(leadFiltersProvider);
  return leads.whenData((list) => applyLeadFilters(list, filters));
});

/// Count shown on each stage tab. Respects search but not the selected
/// stage. The `null` key is the "All" tab.
final leadStageCountsProvider =
    Provider.autoDispose<Map<LeadStage?, int>>((ref) {
  final leads = ref.watch(scopedLeadsProvider).value ?? const <LeadItem>[];
  final query = ref.watch(leadFiltersProvider).query.trim().toLowerCase();

  final base = leads.where((l) => _matchesQuery(l, query)).toList();

  return {
    null: base.length,
    for (final s in LeadStage.values)
      s: base.where((l) => l.stage == s).length,
  };
});