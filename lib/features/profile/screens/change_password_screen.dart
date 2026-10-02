import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../auth/providers/auth_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    try {
      await ref.read(authProvider.notifier).changePassword(
            currentPassword: _current.text,
            newPassword: _new.text,
          );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      context.showSnack(e.message);
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      context.showSnack('Could not change your password. Please try again.');
      return;
    }

    if (!mounted) return;
    context.showSnack('Password changed.');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Briefly null while the router redirects after logout.
    if (ref.watch(authProvider).user == null) return const SizedBox.shrink();

    const gap = SizedBox(height: AppSpacing.lg);

    return Scaffold(
      appBar: AppBar(title: const Text('Change password')),
      body: ResponsiveBody(
        maxWidth: 600,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            children: [
              AppTextField(
                controller: _current,
                label: 'Current password',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: true,
                textInputAction: TextInputAction.next,
                enabled: !_saving,
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Enter your current password'
                    : null,
              ),
              gap,
              AppTextField(
                controller: _new,
                label: 'New password',
                prefixIcon: Icons.lock_reset_rounded,
                obscureText: true,
                textInputAction: TextInputAction.next,
                enabled: !_saving,
                validator: (v) {
                  final value = v ?? '';
                  if (value.length < 8) return 'Use at least 8 characters';
                  if (!RegExp(r'[A-Za-z]').hasMatch(value) ||
                      !RegExp(r'\d').hasMatch(value)) {
                    return 'Include a letter and a number';
                  }
                  if (value == _current.text) {
                    return 'Choose a different password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'At least 8 characters, with a letter and a number.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              gap,
              AppTextField(
                controller: _confirm,
                label: 'Confirm new password',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: true,
                textInputAction: TextInputAction.done,
                enabled: !_saving,
                onSubmitted: (_) => _save(),
                validator: (v) =>
                    v != _new.text ? 'Passwords do not match' : null,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Update password',
                isLoading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}