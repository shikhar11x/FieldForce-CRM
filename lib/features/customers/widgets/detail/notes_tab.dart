import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../../../data/models/customer_models.dart';

Future<void> _addNote(BuildContext context) async {
  final text = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _AddNoteSheet(),
  );
  if (text != null && context.mounted) {
    context.showSnack('Note saved. Persistence arrives in Phase 2.');
  }
}

class NotesTab extends StatelessWidget {
  const NotesTab({super.key, required this.notes});

  final List<CustomerNote> notes;

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return EmptyState(
        icon: Icons.sticky_note_2_outlined,
        title: 'No notes yet',
        message: 'Capture details from calls and visits here.',
        actionLabel: 'Add note',
        onAction: () => _addNote(context),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.tonalIcon(
            onPressed: () => _addNote(context),
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

class _AddNoteSheet extends StatefulWidget {
  const _AddNoteSheet();

  @override
  State<_AddNoteSheet> createState() => _AddNoteSheetState();
}

class _AddNoteSheetState extends State<_AddNoteSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Add note', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _controller,
            autofocus: true,
            minLines: 3,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Write a note about this customer',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(label: 'Save note', onPressed: _save),
        ],
      ),
    );
  }
}