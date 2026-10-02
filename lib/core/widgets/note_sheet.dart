import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'app_button.dart';

/// Bottom sheet with a multi-line text field. Returns the trimmed text,
/// or null if dismissed.
Future<String?> showNoteSheet(
  BuildContext context, {
  String title = 'Add note',
  String hint = 'Write a note',
  String saveLabel = 'Save note',
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _NoteSheet(title: title, hint: hint, saveLabel: saveLabel),
  );
}

class _NoteSheet extends StatefulWidget {
  const _NoteSheet({
    required this.title,
    required this.hint,
    required this.saveLabel,
  });

  final String title;
  final String hint;
  final String saveLabel;

  @override
  State<_NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<_NoteSheet> {
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
          Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _controller,
            autofocus: true,
            minLines: 3,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(hintText: widget.hint),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(label: widget.saveLabel, onPressed: _save),
        ],
      ),
    );
  }
}