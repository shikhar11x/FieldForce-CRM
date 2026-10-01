import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/customer_models.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/repositories/mock_customer_repository.dart';

final customerRepositoryProvider = Provider<CustomerRepository>(
  (ref) => MockCustomerRepository(),
);

final customersProvider = FutureProvider.autoDispose<List<Customer>>((ref) {
  return ref.watch(customerRepositoryProvider).getCustomers();
});

final customerDetailProvider =
    FutureProvider.autoDispose.family<CustomerDetail, String>((ref, id) {
  return ref.watch(customerRepositoryProvider).getCustomerDetail(id);
});