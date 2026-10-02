import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/task_enums.dart';
import '../../../data/models/visit_models.dart';
import 'visit_provider.dart';

enum VisitSort {
  latest('Latest first'),
  earliest('Earliest first'),
  customer('Customer (A-Z)');

  const VisitSort(this.label);
  final String label;
}

class VisitFilters {
  const VisitFilters({
    this.query = '',
    this.status,
    this.sort = VisitSort.latest,
  });

  final String query;

  /// Null means "All".
  final VisitStatus? status;
  final VisitSort sort;

  bool get isActive => query.trim().isNotEmpty || status != null;
}

class VisitFiltersNotifier extends Notifier<VisitFilters> {
  @override
  VisitFilters build() => const VisitFilters();

  void setQuery(String query) => state = VisitFilters(
        query: query,
        status: state.status,
        sort: state.sort,
      );

  void setStatus(VisitStatus? status) => state = VisitFilters(
        query: state.query,
        status: status,
        sort: state.sort,
      );

  void setSort(VisitSort sort) => state = VisitFilters(
        query: state.query,
        status: state.status,
        sort: sort,
      );

  /// Clears search and status; keeps the chosen sort order.
  void reset() => state = VisitFilters(sort: state.sort);
}

final visitFiltersProvider =
    NotifierProvider<VisitFiltersNotifier, VisitFilters>(
  VisitFiltersNotifier.new,
);

bool _matchesQuery(VisitItem v, String query) {
  if (query.isEmpty) return true;
  return [v.customer, v.employee, v.location, v.purpose, v.type.label]
      .any((value) => value.toLowerCase().contains(query));
}

List<VisitItem> applyVisitFilters(List<VisitItem> source, VisitFilters f) {
  final query = f.query.trim().toLowerCase();

  final result = source.where((v) {
    if (f.status != null && v.status != f.status) return false;
    return _matchesQuery(v, query);
  }).toList();

  switch (f.sort) {
    case VisitSort.latest:
      result.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
    case VisitSort.earliest:
      result.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    case VisitSort.customer:
      result.sort(
        (a, b) => a.customer.toLowerCase().compareTo(b.customer.toLowerCase()),
      );
  }
  return result;
}

final filteredVisitsProvider =
    Provider.autoDispose<AsyncValue<List<VisitItem>>>((ref) {
  final visits = ref.watch(scopedVisitsProvider);
  final filters = ref.watch(visitFiltersProvider);
  return visits.whenData((list) => applyVisitFilters(list, filters));
});

/// Count shown on each status tab. Respects search but not the selected
/// status. The `null` key is the "All" tab.
final visitStatusCountsProvider =
    Provider.autoDispose<Map<VisitStatus?, int>>((ref) {
  final visits = ref.watch(scopedVisitsProvider).value ?? const <VisitItem>[];
  final query = ref.watch(visitFiltersProvider).query.trim().toLowerCase();

  final base = visits.where((v) => _matchesQuery(v, query)).toList();

  return {
    null: base.length,
    for (final s in VisitStatus.values)
      s: base.where((v) => v.status == s).length,
  };
});