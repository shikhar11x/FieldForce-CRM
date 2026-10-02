import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

/// Asks for confirmation, then signs out. The router sends the user to
/// Login once the auth state clears.
Future<void> confirmAndLogout(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Log out?'),
      content: const Text('You will need to sign in again to continue.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Stay signed in'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Log out'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    await ref.read(authProvider.notifier).logout();
  }
}