import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/api_config.dart';
import '../../../core/network/api_providers.dart';
import '../../../data/models/user_role.dart';
import '../../../data/models/visit_models.dart';
import '../../../data/repositories/api_visit_repository.dart';
import '../../../data/repositories/mock_visit_repository.dart';
import '../../../data/repositories/visit_repository.dart';
import '../../auth/providers/auth_provider.dart';

final visitRepositoryProvider = Provider<VisitRepository>((ref) {
  if (ApiConfig.useMockAuth) return MockVisitRepository();
  return ApiVisitRepository(ref.watch(apiClientProvider));
});

/// Holds the visit list for the session. Har action repository se hoke
/// aata hai, aur server ka diya updated visit list me replace hota hai.
class VisitsNotifier extends AsyncNotifier<List<VisitItem>> {
  VisitRepository get _repo => ref.read(visitRepositoryProvider);

  List<VisitItem> get _current => state.value ?? const <VisitItem>[];

  @override
  Future<List<VisitItem>> build() async {
    // Account badalne par list dobara load ho; logout ke baad khaali.
    final userId = ref.watch(authProvider.select((s) => s.user?.id));
    if (userId == null) return const <VisitItem>[];
    return ref.watch(visitRepositoryProvider).getVisits();
  }

  void _replace(VisitItem saved) {
    state = AsyncData([
      for (final v in _current)
        if (v.id == saved.id) saved else v,
    ]);
  }

  Future<void> startVisit(VisitItem visit) async =>
      _replace(await _repo.startVisit(visit));

  Future<void> completeVisit(VisitItem visit) async =>
      _replace(await _repo.completeVisit(visit));

  Future<void> addNote(VisitItem visit, String author, String text) async =>
      _replace(await _repo.addNote(visit, author, text));

  /// Phase 1/2: placeholder photo. Asli upload baad ke step me.
  Future<void> addPhoto(VisitItem visit) async =>
      _replace(await _repo.addPhoto(visit));

  /// Marks the visit as QR verified (idempotent).
  Future<void> markQrVerified(
    VisitItem visit, {
    required int distanceMeters,
  }) async {
    if (visit.qrVerified) return;
    _replace(await _repo.markQrVerified(visit, distanceMeters: distanceMeters));
  }
}

final visitsProvider = AsyncNotifierProvider<VisitsNotifier, List<VisitItem>>(
  VisitsNotifier.new,
);

/// Employees only see their own visits; admins and managers see all.
/// (Server already scopes this; the filter keeps mock mode consistent.)
final scopedVisitsProvider = Provider.autoDispose<AsyncValue<List<VisitItem>>>((
  ref,
) {
  final visits = ref.watch(visitsProvider);
  final user = ref.watch(authProvider).user;

  return visits.whenData((list) {
    if (user == null || user.role != UserRole.employee) return list;
    return list.where((v) => v.employee == user.name).toList();
  });
});

VisitItem? findVisit(List<VisitItem> visits, String id) {
  for (final visit in visits) {
    if (visit.id == id) return visit;
  }
  return null;
}
