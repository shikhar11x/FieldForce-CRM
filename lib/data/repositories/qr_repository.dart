import '../models/customer_models.dart';

/// Phase 2 swaps the mock implementation for an API-backed one.
abstract class QrRepository {
  /// Returns the customer a QR payload belongs to, or null if the code
  /// is not a valid FieldForce customer code.
  Future<Customer?> resolveCustomer(String payload);

  /// Distance between the device and the customer's location.
  Future<int> distanceToCustomerMeters(String payload);
}