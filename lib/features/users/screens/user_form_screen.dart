import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../../data/models/directory_models.dart';
import '../../../data/models/user_role.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/user_provider.dart';

typedef _ManagerOption = ({String id, String name});

/// Create (no [userId]) or edit (with [userId]) a user. Admin only.
class UserFormScreen extends ConsumerWidget {
  const UserFormScreen({super.key, this.userId});

  final String? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(authProvider).user;
    final users = ref.watch(usersProvider);

    // Briefly null while the router redirects after logout.
    if (me == null) return const SizedBox.shrink();

    final id = userId;

    return Scaffold(
      appBar: AppBar(title: Text(id == null ? 'Add user' : 'Edit user')),
      body: ResponsiveBody(
        maxWidth: 600,
        child: AsyncValueView<List<DirectoryUser>>(
          value: users,
          onRetry: () => ref.invalidate(usersProvider),
          loading: const _FormSkeleton(),
          data: (list) {
            DirectoryUser? initial;
            if (id != null) {
              initial = findUser(list, id);
              if (initial == null) {
                return const EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'User not found',
                  message: 'They may have been removed.',
                );
              }
            }

            // Active managers, plus the current one even if now inactive.
            final currentManagerId = initial?.managerId;
            final managers = <_ManagerOption>[
              for (final u in list)
                if (u.role == UserRole.manager &&
                    (u.isActive || u.id == currentManagerId))
                  (id: u.id, name: u.name),
            ];

            return _UserForm(
              key: ValueKey(id ?? 'new-user'),
              initial: initial,
              managers: managers,
            );
          },
        ),
      ),
    );
  }
}

class _UserForm extends ConsumerStatefulWidget {
  const _UserForm({super.key, this.initial, required this.managers});

  final DirectoryUser? initial;
  final List<_ManagerOption> managers;

  @override
  ConsumerState<_UserForm> createState() => _UserFormState();
}

class _UserFormState extends ConsumerState<_UserForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _designation;
  late final TextEditingController _department;

  late UserRole _role;
  String? _team;
  String? _managerId;
  late bool _active;
  bool _saving = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final u = widget.initial;
    _name = TextEditingController(text: u?.name);
    _email = TextEditingController(text: u?.email);
    _phone = TextEditingController(text: u?.phone);
    _designation = TextEditingController(text: u?.designation);
    _department = TextEditingController(text: u?.department);

    _role = u?.role ?? UserRole.employee;
    _team = (u == null || u.team.isEmpty) ? null : u.team;
    _managerId = (u == null || u.managerId.isEmpty) ? null : u.managerId;
    _active = u?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _designation.dispose();
    _department.dispose();
    super.dispose();
  }

  List<String> _withCurrent(List<String> options, String? current) {
    if (current == null || options.contains(current)) return options;
    return [...options, current];
  }

  String _managerName(String id) {
    for (final m in widget.managers) {
      if (m.id == id) return m.name;
    }
    return '';
  }

  Future<void> _showTemporaryPassword(String password) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('User created'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share this temporary password securely. It is shown only '
              'once. Ask them to change it after signing in.',
            ),
            const SizedBox(height: AppSpacing.md),
            SelectableText(
              password,
              style: Theme.of(dialogContext).textTheme.titleMedium?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Clipboard.setData(ClipboardData(text: password)),
            child: const Text('Copy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    final isEmployee = _role == UserRole.employee;
    final team = isEmployee ? (_team ?? '') : '';
    final managerId = isEmployee ? (_managerId ?? '') : '';
    final managerName = managerId.isEmpty ? '' : _managerName(managerId);
    final initial = widget.initial;

    final user = initial == null
        ? DirectoryUser(
            // Server asli id aur employeeId deta hai; ye sirf mock mode ke liye.
            id: 'u${DateTime.now().microsecondsSinceEpoch}',
            name: _name.text.trim(),
            email: _email.text.trim(),
            phone: _phone.text.trim(),
            role: _role,
            designation: _designation.text.trim(),
            department: _department.text.trim(),
            team: team,
            manager: managerName,
            managerId: managerId,
            employeeId:
                'FF-${1000 + DateTime.now().millisecondsSinceEpoch % 9000}',
            joiningDate: DateTime.now(),
            isActive: _active,
          )
        : initial.copyWith(
            name: _name.text.trim(),
            email: _email.text.trim(),
            phone: _phone.text.trim(),
            role: _role,
            designation: _designation.text.trim(),
            department: _department.text.trim(),
            team: team,
            manager: managerName,
            managerId: managerId,
            isActive: _active,
          );

    final notifier = ref.read(usersProvider.notifier);
    String? temporaryPassword;
    try {
      if (initial == null) {
        final created = await notifier.addUser(user);
        temporaryPassword = created.temporaryPassword;
      } else {
        await notifier.saveUser(user);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      context.showSnack(e.message);
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      context.showSnack('Could not save the user. Please try again.');
      return;
    }

    if (!mounted) return;
    if (temporaryPassword != null) await _showTemporaryPassword(temporaryPassword);
    if (!mounted) return;
    context.showSnack(initial == null ? 'User added.' : 'User updated.');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: AppSpacing.lg);
    final isEmployee = _role == UserRole.employee;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          AppTextField(
            controller: _name,
            label: 'Full name',
            prefixIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            enabled: !_saving,
            validator: (v) =>
                (v == null || v.trim().length < 2) ? 'Enter a name' : null,
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
              if (value.isEmpty) return 'Enter an email';
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
            textInputAction: TextInputAction.next,
            enabled: !_saving,
            validator: (v) {
              final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
              if (digits.length < 10 || digits.length > 13) {
                return 'Enter a valid phone number';
              }
              return null;
            },
          ),
          gap,
          AppDropdown<UserRole>(
            label: 'Role',
            icon: Icons.verified_user_outlined,
            value: _role,
            items: UserRole.values,
            labelOf: (r) => r.label,
            onChanged:
                _saving ? null : (v) => setState(() => _role = v ?? _role),
          ),
          gap,
          AppTextField(
            controller: _designation,
            label: 'Designation',
            hint: 'e.g. Sales Executive',
            prefixIcon: Icons.work_outline_rounded,
            textInputAction: TextInputAction.next,
            enabled: !_saving,
            validator: (v) => (v == null || v.trim().length < 2)
                ? 'Enter a designation'
                : null,
          ),
          gap,
          AppTextField(
            controller: _department,
            label: 'Department',
            prefixIcon: Icons.account_tree_outlined,
            textInputAction: TextInputAction.done,
            enabled: !_saving,
            validator: (v) => (v == null || v.trim().length < 2)
                ? 'Enter a department'
                : null,
          ),
          if (isEmployee) ...[
            gap,
            AppDropdown<String>(
              label: 'Team',
              icon: Icons.groups_rounded,
              value: _team,
              items: _withCurrent(userTeams, _team),
              labelOf: (s) => s,
              onChanged: _saving ? null : (v) => setState(() => _team = v),
              validator: (v) => v == null ? 'Select a team' : null,
            ),
            gap,
            AppDropdown<String>(
              label: 'Reports to',
              icon: Icons.supervisor_account_outlined,
              value: _managerId,
              items: [for (final m in widget.managers) m.id],
              labelOf: _managerName,
              onChanged:
                  _saving ? null : (v) => setState(() => _managerId = v),
              validator: (v) => v == null ? 'Select a manager' : null,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Active'),
            subtitle: const Text('Inactive users cannot sign in'),
            value: _active,
            onChanged: _saving ? null : (v) => setState(() => _active = v),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: _isEdit ? 'Save changes' : 'Add user',
            isLoading: _saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}

class _FormSkeleton extends StatelessWidget {
  const _FormSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < 5; i++) ...[
          const SkeletonBox(height: 56, radius: AppRadius.md),
          const SizedBox(height: AppSpacing.lg),
        ],
      ],
    );
  }
}