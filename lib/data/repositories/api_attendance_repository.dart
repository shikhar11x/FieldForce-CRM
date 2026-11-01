import 'package:dio/dio.dart';

import '../../core/location/device_location.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/attendance_models.dart';
import 'attendance_repository.dart';

class ApiAttendanceRepository implements AttendanceRepository {
  ApiAttendanceRepository(this._api);

  final ApiClient _api;

  @override
  Future<TodayAttendance> getToday() async {
    final response =
        await _api.dio.get<Map<String, dynamic>>('/attendance/today');
    return TodayAttendance.fromJson(response.data!);
  }

  @override
  Future<TodayAttendance> checkIn(DeviceFix fix) => _check('check-in', fix);

  @override
  Future<TodayAttendance> checkOut(DeviceFix fix) => _check('check-out', fix);

  Future<TodayAttendance> _check(String action, DeviceFix fix) async {
    try {
      final response = await _api.dio.post<Map<String, dynamic>>(
        '/attendance/$action',
        data: {
          'latitude': fix.latitude,
          'longitude': fix.longitude,
          'accuracyMeters': fix.accuracyMeters,
        },
      );
      return TodayAttendance.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  @override
  Future<List<AttendanceRecord>> getMonth({
    required String employee,
    String? employeeId,
    required int year,
    required int month,
  }) async {
    final response = await _api.dio.get<List<dynamic>>(
      '/attendance/month',
      queryParameters: {
        'year': year,
        'month': month,
        if (employeeId != null) 'employeeId': employeeId,
      },
    );
    return [
      for (final item in response.data!)
        AttendanceRecord.fromJson(item as Map<String, dynamic>),
    ];
  }

  @override
  Future<List<TeamAttendanceEntry>> getTeamAttendance() async {
    final response = await _api.dio.get<List<dynamic>>('/attendance/team');
    return [
      for (final item in response.data!)
        TeamAttendanceEntry.fromJson(item as Map<String, dynamic>),
    ];
  }
}