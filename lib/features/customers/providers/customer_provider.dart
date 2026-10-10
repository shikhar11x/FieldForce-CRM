import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/api_config.dart';
import '../../../core/network/api_providers.dart';
import '../../../data/models/customer_models.dart';
import '../../../data/repositories/api_customer_repository.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/repositories/mock_customer_repository.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  if (ApiConfig.useMockAuth) return MockCustomerRepository();
  return ApiCustomerRepository(ref.watch(apiClientProvider));
});

final customersProvider = FutureProvider.autoDispose<List<Customer>>((ref) {
  return ref.watch(customerRepositoryProvider).getCustomers();
});

final customerDetailProvider =
    FutureProvider.autoDispose.family<CustomerDetail, String>((ref, id) {
  return ref.watch(customerRepositoryProvider).getCustomerDetail(id);
});

Customer? findCustomer(List<Customer> customers, String id) {
  for (final customer in customers) {
    if (customer.id == id) return customer;
  }
  return null;
}