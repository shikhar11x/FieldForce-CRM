import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/api_config.dart';
import '../../../core/location/device_location.dart';
import '../../../core/network/api_providers.dart';
import '../../../data/models/qr_models.dart';
import '../../../data/repositories/api_qr_repository.dart';
import '../../../data/repositories/mock_qr_repository.dart';
import '../../../data/repositories/qr_repository.dart';
import '../../auth/providers/auth_provider.dart';
import '../../visits/providers/visit_provider.dart';

final qrRepositoryProvider = Provider<QrRepository>((ref) {
  if (ApiConfig.useMockAuth) return MockQrRepository();
  return ApiQrRepository(ref.watch(apiClientProvider));
});

/// Holds the latest scan result so the result screen can display it.
class QrScanNotifier extends Notifier<QrScanResult?> {
  @override
  QrScanResult? build() => null;

  Future<QrScanResult> scan(String payload, DeviceFix fix) async {
    final result =
        await ref.read(qrRepositoryProvider).scan(payload: payload, fix: fix);
    state = result;

    // Server ne visit ko verified mark kiya ho to visit list taaza karo.
    if (result.status == QrVerificationStatus.verified) {
      ref.invalidate(visitsProvider);
    }
    return result;
  }
}

final qrScanProvider =
    NotifierProvider<QrScanNotifier, QrScanResult?>(QrScanNotifier.new);

/// Customer ka QR payload (admin / manager ke QR screen ke liye).
final customerQrPayloadProvider =
    FutureProvider.autoDispose.family<String, String>((ref, customerId) {
  ref.watch(authProvider.select((s) => s.user?.id));
  return ref.watch(qrRepositoryProvider).customerPayload(customerId);
});