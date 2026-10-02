import '../mock/mock_customers.dart';
import '../models/customer_models.dart';
import 'qr_repository.dart';

/// Payload format: `fieldforce://customer/<id>`. Adding `?sim=far`
/// simulates scanning from too far away.
class MockQrRepository implements QrRepository {
  Uri _parse(String payload) => Uri.parse(payload.trim());

  @override
  Future<Customer?> resolveCustomer(String payload) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    final uri = _parse(payload);
    if (uri.scheme != 'fieldforce' ||
        uri.host != 'customer' ||
        uri.pathSegments.isEmpty) {
      return null;
    }

    final id = uri.pathSegments.first;
    for (final customer in MockCustomers.all()) {
      if (customer.id == id) return customer;
    }
    return null;
  }

  @override
  Future<int> distanceToCustomerMeters(String payload) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _parse(payload).queryParameters['sim'] == 'far' ? 480 : 35;
  }
}