import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../auth/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _name = TextEditingController(text: user?.name);
    _email = TextEditingController(text: user?.email);
    _phone = TextEditingController(text: user?.phone);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    try {
      await ref.read(authProvider.notifier).updateProfile(
            email: _email.text.trim(),
            phone: _phone.text.trim(),
          );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      context.showSnack('Could not save your profile. Please try again.');
      return;
    }

    if (!mounted) return;
    context.showSnack('Profile updated.');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Briefly null while the router redirects after logout.
    if (ref.watch(authProvider).user == null) return const SizedBox.shrink();

    const gap = SizedBox(height: AppSpacing.lg);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: ResponsiveBody(
        maxWidth: 600,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            children: [
              AppTextField(
                controller: _name,
                label: 'Full name',
                prefixIcon: Icons.person_outline_rounded,
                enabled: false,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Your name, employee ID and department are managed by '
                'your administrator.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              gap,
              AppTextField(
                controller: _email,
                label: 'Email',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                enabled: !_saving,
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return 'Enter your email';
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              gap,
              AppTextField(
                controller: _phone,
                label: 'Phone',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                enabled: !_saving,
                onSubmitted: (_) => _save(),
                validator: (v) {
                  final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
                  if (digits.length < 10 || digits.length > 13) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Save changes',
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