import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/customer_models.dart';
import 'customer_provider.dart';

enum CustomerFilter {
  all('All'),
  active('Active'),
  inactive('Inactive'),
  newCustomers('New'),
  highPriority('High priority');

  const CustomerFilter(this.label);
  final String label;
}

enum CustomerSort {
  name('Name (A-Z)'),
  recentVisit('Recently visited'),
  nextVisit('Next visit');

  const CustomerSort(this.label);
  final String label;
}

class CustomerFilters {
  const CustomerFilters({
    this.query = '',
    this.filter = CustomerFilter.all,
    this.sort = CustomerSort.name,
  });

  final String query;
  final CustomerFilter filter;
  final CustomerSort sort;

  /// True when search or a filter chip is narrowing the list.
  bool get isActive =>
      query.trim().isNotEmpty || filter != CustomerFilter.all;

  CustomerFilters copyWith({
    String? query,
    CustomerFilter? filter,
    CustomerSort? sort,
  }) {
    return CustomerFilters(
      query: query ?? this.query,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
    );
  }
}

class CustomerFiltersNotifier extends Notifier<CustomerFilters> {
  @override
  CustomerFilters build() => const CustomerFilters();

  void setQuery(String query) => state = state.copyWith(query: query);
  void setFilter(CustomerFilter filter) =>
      state = state.copyWith(filter: filter);
  void setSort(CustomerSort sort) => state = state.copyWith(sort: sort);

  /// Clears search and filter chip; keeps the chosen sort order.
  void reset() => state = CustomerFilters(sort: state.sort);
}

final customerFiltersProvider =
    NotifierProvider<CustomerFiltersNotifier, CustomerFilters>(
  CustomerFiltersNotifier.new,
);

int _compareDates(DateTime? a, DateTime? b, {bool descending = false}) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return descending ? b.compareTo(a) : a.compareTo(b);
}

List<Customer> applyCustomerFilters(
  List<Customer> source,
  CustomerFilters f,
) {
  final query = f.query.trim().toLowerCase();

  final result = source.where((c) {
    final matchesFilter = switch (f.filter) {
      CustomerFilter.all => true,
      CustomerFilter.active => c.status == CustomerStatus.active,
      CustomerFilter.inactive => c.status == CustomerStatus.inactive,
      CustomerFilter.newCustomers => c.status == CustomerStatus.newCustomer,
      CustomerFilter.highPriority => c.highPriority,
    };
    if (!matchesFilter) return false;
    if (query.isEmpty) return true;

    return [
      c.company,
      c.contactName,
      c.phone,
      c.email,
      c.address,
      c.assignedEmployee,
    ].any((value) => value.toLowerCase().contains(query));
  }).toList();

  switch (f.sort) {
    case CustomerSort.name:
      result.sort(
        (a, b) => a.company.toLowerCase().compareTo(b.company.toLowerCase()),
      );
    case CustomerSort.recentVisit:
      result.sort(
        (a, b) => _compareDates(a.lastVisit, b.lastVisit, descending: true),
      );
    case CustomerSort.nextVisit:
      result.sort((a, b) => _compareDates(a.nextVisit, b.nextVisit));
  }
  return result;
}

/// Customers after search, filter chip and sort are applied.
final filteredCustomersProvider =
    Provider.autoDispose<AsyncValue<List<Customer>>>((ref) {
  final customers = ref.watch(customersProvider);
  final filters = ref.watch(customerFiltersProvider);
  return customers.whenData((list) => applyCustomerFilters(list, filters));
});