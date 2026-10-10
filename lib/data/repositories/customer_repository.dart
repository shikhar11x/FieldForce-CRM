import '../models/customer_models.dart';

abstract class CustomerRepository {
  Future<List<Customer>> getCustomers();
  Future<CustomerDetail> getCustomerDetail(String id);

  /// Employee ke liye [includeManagedFields] false: server assignment,
  /// status aur priority ko khud sambhalta hai.
  Future<Customer> createCustomer(
    Customer customer, {
    bool includeManagedFields = true,
  });
  Future<Customer> updateCustomer(
    Customer customer, {
    bool includeManagedFields = true,
  });
  Future<CustomerNote> addNote(String customerId, String text);
}