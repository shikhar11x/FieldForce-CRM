import '../models/visit_models.dart';

/// Har action server pe chalta hai aur update hua visit wapas deta hai.
abstract class VisitRepository {
  Future<List<VisitItem>> getVisits();
  Future<VisitItem> startVisit(VisitItem visit);
  Future<VisitItem> completeVisit(VisitItem visit);
  Future<VisitItem> addNote(VisitItem visit, String author, String text);
  Future<VisitItem> addPhoto(VisitItem visit);
  Future<VisitItem> markQrVerified(
    VisitItem visit, {
    required int distanceMeters,
  });
}
