import '../../core/location/device_location.dart';
import '../models/qr_models.dart';

abstract class QrRepository {
  /// Server code check karta hai, visit dhundta hai aur doori nikalta hai.
  Future<QrScanResult> scan({required String payload, required DeviceFix fix});

  /// Customer ka signed QR payload (sirf admin / manager).
  Future<String> customerPayload(String customerId);
}