import 'package:flutter/material.dart';

import '../../../core/extensions/datetime_extensions.dart';
import '../../../core/extensions/task_style_extensions.dart';
import '../../../core/extensions/visit_style_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/timeline_tile.dart';
import '../../../data/models/visit_models.dart';

const _rowDivider = Padding(
  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
  child: Divider(),
);

class _EmptyCard extends StatelessWidget {
  const _EmptyCard(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class VisitNotesSection extends StatelessWidget {
  const VisitNotesSection({super.key, required this.notes});

  final List<VisitNote> notes;

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) return const _EmptyCard('No notes added yet.');

    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return AppCard(
      child: Column(
        children: [
          for (final (i, note) in notes.indexed) ...[
            if (i > 0) _rowDivider,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InitialsAvatar(name: note.author, radius: 14),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        note.author,
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                    Text(
                      note.timestamp.timeAgo,
                      style: theme.textTheme.labelSmall?.copyWith(color: muted),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(note.text, style: theme.textTheme.bodyMedium),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class VisitAttachmentsSection extends StatelessWidget {
  const VisitAttachmentsSection({super.key, required this.attachments});

  final List<VisitAttachment> attachments;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) {
      return const _EmptyCard('No photos or files attached.');
    }

    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        children: [
          for (final (i, item) in attachments.indexed) ...[
            if (i > 0) _rowDivider,
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.12),
                    borderRadius: AppRadius.mdAll,
                  ),
                  child: const Icon(Icons.image_rounded, color: AppColors.info),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        '${item.size} · ${item.uploaded.shortDate}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class VisitHistorySection extends StatelessWidget {
  const VisitHistorySection({super.key, required this.history});

  final List<VisitItem> history;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const _EmptyCard('No previous visits to this customer.');
    }

    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        children: [
          for (final (i, visit) in history.indexed) ...[
            if (i > 0) _rowDivider,
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(visit.purpose, style: theme.textTheme.titleSmall),
                      const SizedBox(height: 2),
                      Text(
                        '${visit.scheduledAt.shortDate} · ${visit.employee}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                StatusChip(
                  label: visit.status.label,
                  color: visit.status.color,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class VisitTimelineSection extends StatelessWidget {
  const VisitTimelineSection({super.key, required this.events});

  final List<VisitEvent> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const _EmptyCard('No activity recorded yet.');

    return AppCard(
      child: Column(
        children: [
          for (final (i, event) in events.indexed)
            TimelineTile(
              icon: event.type.icon,
              color: event.type.color,
              title: event.title,
              meta: '${event.timestamp.dayLabel}, '
                  '${TimeOfDay.fromDateTime(event.timestamp).format(context)}',
              isLast: i == events.length - 1,
            ),
        ],
      ),
    );
  }
}