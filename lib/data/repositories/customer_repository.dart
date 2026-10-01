import '../models/customer_models.dart';

/// Phase 2 swaps the mock implementation for an API-backed one.
abstract class CustomerRepository {
  Future<List<Customer>> getCustomers();
  Future<CustomerDetail> getCustomerDetail(String id);
}