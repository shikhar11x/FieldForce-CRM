import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/note_sheet.dart';
import '../../../data/models/task_enums.dart';
import '../../../data/models/visit_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/visit_provider.dart';

/// Start / Complete plus Add Note, Upload Photo and Scan QR.
/// State changes are local in Phase 1; camera and QR arrive later.
class VisitActionPanel extends ConsumerStatefulWidget {
  const VisitActionPanel({super.key, required this.visit});

  final VisitItem visit;

  @override
  ConsumerState<VisitActionPanel> createState() => _VisitActionPanelState();
}

class _VisitActionPanelState extends ConsumerState<VisitActionPanel> {
  bool _busy = false;

  VisitItem get _visit => widget.visit;
  VisitsNotifier get _notifier => ref.read(visitsProvider.notifier);
  bool get _inProgress => _visit.status == VisitStatus.started;

  String get _blockedMessage => _visit.status == VisitStatus.scheduled
      ? 'Start the visit first.'
      : 'This visit is ${_visit.status.label.toLowerCase()}.';

  Future<void> _run(Future<void> Function() action, String message) async {
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) context.showSnack(message);
    } on ApiException catch (e) {
      if (mounted) context.showSnack(e.message);
    } catch (_) {
      if (mounted) {
        context.showSnack('Could not update the visit. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addNote() async {
    if (_visit.status == VisitStatus.cancelled) {
      context.showSnack(_blockedMessage);
      return;
    }
    final text = await showNoteSheet(
      context,
      title: 'Add visit note',
      hint: 'What happened during this visit?',
    );
    if (text == null || !mounted) return;
    final author = ref.read(authProvider).user?.name ?? 'You';
    await _run(() => _notifier.addNote(_visit, author, text), 'Note added.');
  }

  void _uploadPhoto() {
    if (!_inProgress) {
      context.showSnack(_blockedMessage);
      return;
    }
    _run(
      () => _notifier.addPhoto(_visit),
      'Photo attached. Real camera capture arrives in Phase 2.',
    );
  }

  void _scanQr() {
    final status = _visit.status;
    if (status == VisitStatus.completed || status == VisitStatus.cancelled) {
      context.showSnack('This visit is ${status.label.toLowerCase()}.');
      return;
    }
    context.push('/employee/qr');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Widget? primary = switch (_visit.status) {
      VisitStatus.scheduled => FilledButton.icon(
        onPressed: _busy
            ? null
            : () => _run(() => _notifier.startVisit(_visit), 'Visit started.'),
        icon: const Icon(Icons.play_arrow_rounded),
        label: const Text('Start Visit'),
      ),
      VisitStatus.started => FilledButton.icon(
        onPressed: _busy
            ? null
            : () => _run(
                () => _notifier.completeVisit(_visit),
                'Visit completed.',
              ),
        icon: const Icon(Icons.check_rounded),
        label: const Text('Complete Visit'),
      ),
      _ => null,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (primary != null)
          primary
        else
          Text(
            'This visit is ${_visit.status.label.toLowerCase()}.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _ToolButton(
                icon: Icons.edit_note_rounded,
                label: 'Add Note',
                onTap: _busy ? null : _addNote,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _ToolButton(
                icon: Icons.photo_camera_outlined,
                label: 'Upload Photo',
                onTap: _busy ? null : _uploadPhoto,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _ToolButton(
                icon: Icons.qr_code_scanner_rounded,
                label: 'Scan QR',
                onTap: _busy ? null : _scanQr,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}
