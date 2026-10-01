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
}