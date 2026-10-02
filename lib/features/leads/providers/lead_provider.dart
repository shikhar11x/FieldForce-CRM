import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/lead_models.dart';
import '../../../data/models/user_role.dart';
import '../../../data/repositories/lead_repository.dart';
import '../../../data/repositories/mock_lead_repository.dart';
import '../../auth/providers/auth_provider.dart';

final leadRepositoryProvider = Provider<LeadRepository>(
  (ref) => MockLeadRepository(),
);

/// Holds the lead list for the session. Writes go through the repository,
/// so Phase 2 only has to replace the repository implementation.
class LeadsNotifier extends AsyncNotifier<List<LeadItem>> {
  LeadRepository get _repo => ref.read(leadRepositoryProvider);

  List<LeadItem> get _current => state.value ?? const <LeadItem>[];

  @override
  Future<List<LeadItem>> build() {
    return ref.watch(leadRepositoryProvider).getLeads();
  }

  Future<void> addLead(LeadItem draft) async {
    final withHistory = draft.copyWith(
      activities: [
        LeadActivity(
          type: LeadActivityType.created,
          title: 'Lead created',
          description: 'Added and assigned to ${draft.assignee}.',
          timestamp: draft.createdAt,
        ),
      ],
    );
    final saved = await _repo.createLead(withHistory);
    state = AsyncData([saved, ..._current]);
  }

  /// Saves edits. A stage change is also logged on the timeline.
  Future<void> saveLead(LeadItem updated) async {
    final previous = findLead(_current, updated.id);
    var next = updated;

    if (previous != null && previous.stage != updated.stage) {
      next = updated.copyWith(
        activities: [
          LeadActivity(
            type: LeadActivityType.stageChange,
            title: 'Moved to ${updated.stage.label}',
            description:
                'Stage changed from ${previous.stage.label} to ${updated.stage.label}.',
            timestamp: DateTime.now(),
          ),
          ...updated.activities,
        ],
      );
    }

    final saved = await _repo.updateLead(next);
    state = AsyncData([
      for (final l in _current)
        if (l.id == saved.id) saved else l,
    ]);
  }

  Future<void> changeStage(LeadItem lead, LeadStage stage) {
    return saveLead(lead.copyWith(stage: stage));
  }

  Future<void> addNote(LeadItem lead, String author, String text) {
    return saveLead(
      lead.copyWith(
        activities: [
          LeadActivity(
            type: LeadActivityType.note,
            title: 'Note by $author',
            description: text,
            timestamp: DateTime.now(),
          ),
          ...lead.activities,
        ],
      ),
    );
  }
}

final leadsProvider =
    AsyncNotifierProvider<LeadsNotifier, List<LeadItem>>(LeadsNotifier.new);

final leadFormOptionsProvider =
    FutureProvider.autoDispose<LeadFormOptions>((ref) {
  return ref.watch(leadRepositoryProvider).getFormOptions();
});

/// Employees only see their own leads; admins and managers see all.
final scopedLeadsProvider =
    Provider.autoDispose<AsyncValue<List<LeadItem>>>((ref) {
  final leads = ref.watch(leadsProvider);
  final user = ref.watch(authProvider).user;

  return leads.whenData((list) {
    if (user == null || user.role != UserRole.employee) return list;
    return list.where((l) => l.assignee == user.name).toList();
  });
});

class LeadSummary {
  const LeadSummary({
    required this.openValue,
    required this.wonValue,
    required this.winRate,
  });

  final double openValue;
  final double wonValue;

  /// Won / (Won + Lost). Null until at least one lead is closed.
  final double? winRate;
}

final leadSummaryProvider = Provider.autoDispose<LeadSummary>((ref) {
  final leads = ref.watch(scopedLeadsProvider).value ?? const <LeadItem>[];

  var open = 0.0;
  var won = 0.0;
  var wonCount = 0;
  var lostCount = 0;

  for (final l in leads) {
    switch (l.stage) {
      case LeadStage.won:
        won += l.value;
        wonCount++;
      case LeadStage.lost:
        lostCount++;
      default:
        open += l.value;
    }
  }

  final closed = wonCount + lostCount;
  return LeadSummary(
    openValue: open,
    wonValue: won,
    winRate: closed == 0 ? null : wonCount / closed,
  );
});

LeadItem? findLead(List<LeadItem> leads, String id) {
  for (final lead in leads) {
    if (lead.id == id) return lead;
  }
  return null;
}