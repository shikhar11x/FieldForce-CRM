import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/visit_models.dart';
import 'visit_repository.dart';

class ApiVisitRepository implements VisitRepository {
  ApiVisitRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<VisitItem>> getVisits() async {
    final response = await _api.dio.get<List<dynamic>>('/visits');
    return [
      for (final item in response.data!)
        VisitItem.fromJson(item as Map<String, dynamic>),
    ];
  }

  @override
  Future<VisitItem> startVisit(VisitItem visit) => _post(visit, 'start');

  @override
  Future<VisitItem> completeVisit(VisitItem visit) => _post(visit, 'complete');

  @override
  Future<VisitItem> addNote(VisitItem visit, String author, String text) {
    // Author server khud logged-in user se lagata hai.
    return _post(visit, 'notes', data: {'text': text});
  }

  @override
  Future<VisitItem> addPhoto(VisitItem visit) => _post(visit, 'photos');

  @override
  Future<VisitItem> markQrVerified(
    VisitItem visit, {
    required int distanceMeters,
  }) {
    return _post(visit, 'verify-qr', data: {'distanceMeters': distanceMeters});
  }

  Future<VisitItem> _post(
    VisitItem visit,
    String action, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _api.dio.post<Map<String, dynamic>>(
        '/visits/${visit.id}/$action',
        data: data,
      );
      return VisitItem.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }
}
