import '../models/visit_models.dart';

/// Phase 2 swaps the mock implementation for an API-backed one.
abstract class VisitRepository {
  Future<List<VisitItem>> getVisits();
  Future<VisitItem> updateVisit(VisitItem visit);
}