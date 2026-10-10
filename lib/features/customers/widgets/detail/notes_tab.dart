import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../../../core/widgets/note_sheet.dart';
import '../../../../data/models/customer_models.dart';
import '../../providers/customer_provider.dart';

class NotesTab extends ConsumerWidget {
  const NotesTab({super.key, required this.customerId, required this.notes});

  final String customerId;
  final List<CustomerNote> notes;

  Future<void> _addNote(BuildContext context, WidgetRef ref) async {
    final text = await showNoteSheet(
      context,
      title: 'Add note',
      hint: 'Write a note about this customer',
    );
    if (text == null || !context.mounted) return;

    try {
      await ref.read(customerRepositoryProvider).addNote(customerId, text);
      ref.invalidate(customerDetailProvider(customerId));
      if (context.mounted) context.showSnack('Note saved.');
    } on ApiException catch (e) {
      if (context.mounted) context.showSnack(e.message);
    } catch (_) {
      if (context.mounted) {
        context.showSnack('Could not save the note. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (notes.isEmpty) {
      return EmptyState(
        icon: Icons.sticky_note_2_outlined,
        title: 'No notes yet',
        message: 'Capture details from calls and visits here.',
        actionLabel: 'Add note',
        onAction: () => _addNote(context, ref),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.tonalIcon(
            onPressed: () => _addNote(context, ref),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add note'),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final note in notes) ...[
          _NoteCard(note: note),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});

  final CustomerNote note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InitialsAvatar(name: note.author, radius: 14),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(note.author, style: theme.textTheme.labelLarge),
              ),
              Text(
                note.timestamp.timeAgo,
                style: theme.textTheme.labelSmall?.copyWith(color: muted),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(note.text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}