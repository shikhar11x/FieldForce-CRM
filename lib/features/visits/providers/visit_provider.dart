import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/task_enums.dart';
import '../../../data/models/user_role.dart';
import '../../../data/models/visit_models.dart';
import '../../../data/repositories/mock_visit_repository.dart';
import '../../../data/repositories/visit_repository.dart';
import '../../auth/providers/auth_provider.dart';

final visitRepositoryProvider = Provider<VisitRepository>(
  (ref) => MockVisitRepository(),
);

/// Holds the visit list for the session. Writes go through the repository,
/// so Phase 2 only has to replace the repository implementation.
class VisitsNotifier extends AsyncNotifier<List<VisitItem>> {
  VisitRepository get _repo => ref.read(visitRepositoryProvider);

  List<VisitItem> get _current => state.value ?? const <VisitItem>[];

  @override
  Future<List<VisitItem>> build() {
    return ref.watch(visitRepositoryProvider).getVisits();
  }

  Future<void> _persist(VisitItem visit) async {
    final saved = await _repo.updateVisit(visit);
    state = AsyncData([
      for (final v in _current)
        if (v.id == saved.id) saved else v,
    ]);
  }

  Future<void> startVisit(VisitItem visit) {
    final now = DateTime.now();
    return _persist(
      visit.copyWith(
        status: VisitStatus.started,
        startedAt: now,
        events: [
          ...visit.events,
          VisitEvent(
            type: VisitEventType.started,
            title: 'Visit started',
            timestamp: now,
          ),
        ],
      ),
    );
  }

  Future<void> completeVisit(VisitItem visit) {
    final now = DateTime.now();
    return _persist(
      visit.copyWith(
        status: VisitStatus.completed,
        completedAt: now,
        events: [
          ...visit.events,
          VisitEvent(
            type: VisitEventType.completed,
            title: 'Visit completed',
            timestamp: now,
          ),
        ],
      ),
    );
  }

  Future<void> addNote(VisitItem visit, String author, String text) {
    final now = DateTime.now();
    return _persist(
      visit.copyWith(
        notes: [
          VisitNote(
            id: 'n${now.microsecondsSinceEpoch}',
            author: author,
            text: text,
            timestamp: now,
          ),
          ...visit.notes,
        ],
        events: [
          ...visit.events,
          VisitEvent(
            type: VisitEventType.note,
            title: 'Note added',
            timestamp: now,
          ),
        ],
      ),
    );
  }

  /// Phase 1: attaches a placeholder photo. Phase 2 uploads a real file.
  Future<void> addPhoto(VisitItem visit) {
    final now = DateTime.now();
    final number = visit.attachments.length + 1;
    return _persist(
      visit.copyWith(
        attachments: [
          ...visit.attachments,
          VisitAttachment(
            id: 'a${now.microsecondsSinceEpoch}',
            name: 'Visit photo $number.jpg',
            kind: 'Photo',
            size: '1.9 MB',
            uploaded: now,
          ),
        ],
        events: [
          ...visit.events,
          VisitEvent(
            type: VisitEventType.photo,
            title: 'Photo uploaded',
            timestamp: now,
          ),
        ],
      ),
    );
  }
}

final visitsProvider =
    AsyncNotifierProvider<VisitsNotifier, List<VisitItem>>(
  VisitsNotifier.new,
);

/// Employees only see their own visits; admins and managers see all.
final scopedVisitsProvider =
    Provider.autoDispose<AsyncValue<List<VisitItem>>>((ref) {
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