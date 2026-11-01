import '../../core/location/device_location.dart';
import '../models/qr_models.dart';
import 'qr_repository.dart';

/// Mock mode: asli verification nahi hoti, sirf format check.
class MockQrRepository implements QrRepository {
  @override
  Future<QrScanResult> scan({
    required String payload,
    required DeviceFix fix,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final valid = payload.startsWith('fieldforce://customer/');
    return QrScanResult(
      status:
          valid ? QrVerificationStatus.verified : QrVerificationStatus.invalid,
      scannedAt: DateTime.now(),
      geofenceMeters: 100,
      customerName: valid ? 'Mock customer' : null,
      distanceMeters: valid ? 35 : null,
      accuracyMeters: fix.accuracyMeters.round(),
    );
  }

  @override
  Future<String> customerPayload(String customerId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return 'fieldforce://customer/$customerId.mock-signature';
  }
}