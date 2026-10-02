enum QrVerificationStatus {
  verified('Verified'),
  locationMismatch('Location mismatch'),
  noVisit('No active visit'),
  invalid('Invalid code');

  const QrVerificationStatus(this.label);
  final String label;
}

class QrScanResult {
  const QrScanResult({
    required this.status,
    required this.scannedAt,
    this.customerName,
    this.address,
    this.visitId,
    this.visitPurpose,
    this.visitScheduledAt,
    this.distanceMeters,
  });

  /// Maximum distance from the customer for a valid check.
  static const geofenceMeters = 100;

  final QrVerificationStatus status;
  final DateTime scannedAt;
  final String? customerName;
  final String? address;
  final String? visitId;
  final String? visitPurpose;
  final DateTime? visitScheduledAt;
  final int? distanceMeters;
}