import '../mock/mock_customers.dart';
import '../models/customer_models.dart';
import 'customer_repository.dart';

class MockCustomerRepository implements CustomerRepository {
  @override
  Future<List<Customer>> getCustomers() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return MockCustomers.all();
  }

  @override
  Future<CustomerDetail> getCustomerDetail(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final match = MockCustomers.all().where((c) => c.id == id);
    if (match.isEmpty) throw Exception('Customer not found: $id');
    return MockCustomers.detail(match.first);
  }

  // Mock mode me writes sirf dikhawe ke liye hain: list dobara load hone
  // par mock data wapas aa jaata hai.
  @override
  Future<Customer> createCustomer(
    Customer customer, {
    bool includeManagedFields = true,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return customer;
  }

  @override
  Future<Customer> updateCustomer(
    Customer customer, {
    bool includeManagedFields = true,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return customer;
  }

  @override
  Future<CustomerNote> addNote(String customerId, String text) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return CustomerNote(
      id: 'n${DateTime.now().microsecondsSinceEpoch}',
      author: 'You',
      text: text,
      timestamp: DateTime.now(),
    );
  }
}