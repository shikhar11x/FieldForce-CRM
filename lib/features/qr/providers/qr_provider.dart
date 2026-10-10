import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/qr_models.dart';
import '../../../data/models/task_enums.dart';
import '../../../data/models/visit_models.dart';
import '../../../data/repositories/mock_qr_repository.dart';
import '../../../data/repositories/qr_repository.dart';
import '../../visits/providers/visit_provider.dart';

final qrRepositoryProvider = Provider<QrRepository>(
  (ref) => MockQrRepository(),
);

/// Holds the latest scan result so the result screen can display it.
class QrScanNotifier extends Notifier<QrScanResult?> {
  @override
  QrScanResult? build() => null;

  /// Verifies a scanned [payload] for [employee]:
  /// valid code, an active visit for that customer, and within range.
  Future<QrScanResult> scan(String payload, String employee) async {
    final repo = ref.read(qrRepositoryProvider);
    final now = DateTime.now();

    final customer = await repo.resolveCustomer(payload);
    if (customer == null) {
      return state = QrScanResult(
        status: QrVerificationStatus.invalid,
        scannedAt: now,
      );
    }

    final visits = await ref.read(visitsProvider.future);
    VisitItem? visit;
    for (final v in visits) {
      final active =
          v.status == VisitStatus.scheduled || v.status == VisitStatus.started;
      if (active && v.employee == employee && v.customer == customer.company) {
        visit = v;
        break;
      }
    }

    if (visit == null) {
      return state = QrScanResult(
        status: QrVerificationStatus.noVisit,
        scannedAt: now,
        customerName: customer.company,
        address: customer.address,
      );
    }

    final distance = await repo.distanceToCustomerMeters(payload);
    final withinRange = distance <= QrScanResult.geofenceMeters;

    if (withinRange) {
      await ref
          .read(visitsProvider.notifier)
          .markQrVerified(visit, distanceMeters: distance);
    }

    return state = QrScanResult(
      status: withinRange
          ? QrVerificationStatus.verified
          : QrVerificationStatus.locationMismatch,
      scannedAt: now,
      customerName: customer.company,
      address: visit.location,
      visitId: visit.id,
      visitPurpose: visit.purpose,
      visitScheduledAt: visit.scheduledAt,
      distanceMeters: distance,
    );
  }
}

final qrScanProvider = NotifierProvider<QrScanNotifier, QrScanResult?>(
  QrScanNotifier.new,
);
