enum QrVerificationStatus {
  verified('Verified', 'VERIFIED'),
  locationMismatch('Too far from customer', 'LOCATION_MISMATCH'),
  lowAccuracy('GPS signal too weak', 'LOW_ACCURACY'),
  customerNotLocated('Customer location not set', 'CUSTOMER_NOT_LOCATED'),
  noVisit('No active visit', 'NO_VISIT'),
  invalid('Invalid code', 'INVALID_CODE');

  const QrVerificationStatus(this.label, this.apiValue);
  final String label;
  final String apiValue;

  static QrVerificationStatus fromApi(String value) =>
      QrVerificationStatus.values.firstWhere(
        (s) => s.apiValue == value,
        orElse: () => QrVerificationStatus.invalid,
      );
}

class QrScanResult {
  const QrScanResult({
    required this.status,
    required this.scannedAt,
    required this.geofenceMeters,
    this.customerName,
    this.address,
    this.visitId,
    this.visitPurpose,
    this.visitScheduledAt,
    this.distanceMeters,
    this.accuracyMeters,
  });

  factory QrScanResult.fromJson(
    Map<String, dynamic> json, {
    required DateTime scannedAt,
  }) {
    final scheduled = json['visitScheduledAt'];
    return QrScanResult(
      status: QrVerificationStatus.fromApi(json['status'] as String),
      scannedAt: scannedAt,
      geofenceMeters: (json['geofenceMeters'] as num?)?.toInt() ?? 100,
      customerName: json['customerName'] as String?,
      address: json['address'] as String?,
      visitId: json['visitId'] as String?,
      visitPurpose: json['visitPurpose'] as String?,
      visitScheduledAt:
          scheduled is String ? DateTime.parse(scheduled).toLocal() : null,
      distanceMeters: (json['distanceMeters'] as num?)?.toInt(),
      accuracyMeters: (json['accuracyMeters'] as num?)?.toInt(),
    );
  }

  final QrVerificationStatus status;
  final DateTime scannedAt;

  /// Server ki tay ki hui limit.
  final int geofenceMeters;
  final String? customerName;
  final String? address;
  final String? visitId;
  final String? visitPurpose;
  final DateTime? visitScheduledAt;
  final int? distanceMeters;
  final int? accuracyMeters;
}