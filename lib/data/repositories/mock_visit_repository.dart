import '../mock/mock_visits.dart';
import '../models/task_enums.dart';
import '../models/visit_models.dart';
import 'visit_repository.dart';

/// Mock mode me actions yahin local state badalte hain (pehle ye logic
/// VisitsNotifier me tha).
class MockVisitRepository implements VisitRepository {
  Future<void> _latency() =>
      Future<void>.delayed(const Duration(milliseconds: 400));

  @override
  Future<List<VisitItem>> getVisits() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return MockVisits.all();
  }

  @override
  Future<VisitItem> startVisit(VisitItem visit) async {
    await _latency();
    final now = DateTime.now();
    return visit.copyWith(
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
    );
  }

  @override
  Future<VisitItem> completeVisit(VisitItem visit) async {
    await _latency();
    final now = DateTime.now();
    return visit.copyWith(
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
    );
  }

  @override
  Future<VisitItem> addNote(VisitItem visit, String author, String text) async {
    await _latency();
    final now = DateTime.now();
    return visit.copyWith(
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
    );
  }

  @override
  Future<VisitItem> addPhoto(VisitItem visit) async {
    await _latency();
    final now = DateTime.now();
    final number = visit.attachments.length + 1;
    return visit.copyWith(
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
    );
  }

  @override
  Future<VisitItem> markQrVerified(
    VisitItem visit, {
    required int distanceMeters,
  }) async {
    if (visit.qrVerified) return visit;
    await _latency();
    return visit.copyWith(
      qrVerified: true,
      events: [
        ...visit.events,
        VisitEvent(
          type: VisitEventType.qrVerified,
          title: 'QR code verified',
          timestamp: DateTime.now(),
        ),
      ],
    );
  }
}
