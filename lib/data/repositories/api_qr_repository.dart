import 'package:dio/dio.dart';

import '../../core/location/device_location.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/qr_models.dart';
import 'qr_repository.dart';

class ApiQrRepository implements QrRepository {
  ApiQrRepository(this._api);

  final ApiClient _api;

  @override
  Future<QrScanResult> scan({
    required String payload,
    required DeviceFix fix,
  }) async {
    try {
      final response = await _api.dio.post<Map<String, dynamic>>(
        '/visits/scan-qr',
        data: {
          'qrPayload': payload,
          'latitude': fix.latitude,
          'longitude': fix.longitude,
          'accuracyMeters': fix.accuracyMeters,
        },
      );
      return QrScanResult.fromJson(response.data!, scannedAt: DateTime.now());
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  @override
  Future<String> customerPayload(String customerId) async {
    try {
      final response = await _api.dio.get<Map<String, dynamic>>(
        '/customers/$customerId/qr',
      );
      return response.data!['payload'] as String;
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }
}