import '../mock/mock_visits.dart';
import '../models/visit_models.dart';
import 'visit_repository.dart';

class MockVisitRepository implements VisitRepository {
  @override
  Future<List<VisitItem>> getVisits() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return MockVisits.all();
  }

  @override
  Future<VisitItem> updateVisit(VisitItem visit) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return visit;
  }
}