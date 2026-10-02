import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
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

            final managers = [
              for (final u in list)
                if (u.role == UserRole.manager && u.isActive) u.name,
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
  final List<String> managers;

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
  String? _manager;
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
    _manager = (u == null || u.manager.isEmpty) ? null : u.manager;
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    final isEmployee = _role == UserRole.employee;
    final team = isEmployee ? (_team ?? '') : '';
    final manager = isEmployee ? (_manager ?? '') : '';
    final initial = widget.initial;

    final user = initial == null
        ? DirectoryUser(
            id: 'u${DateTime.now().microsecondsSinceEpoch}',
            name: _name.text.trim(),
            email: _email.text.trim(),
            phone: _phone.text.trim(),
            role: _role,
            designation: _designation.text.trim(),
            department: _department.text.trim(),
            team: team,
            manager: manager,
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
            manager: manager,
            isActive: _active,
          );

    final notifier = ref.read(usersProvider.notifier);
    try {
      if (initial == null) {
        await notifier.addUser(user);
      } else {
        await notifier.saveUser(user);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      context.showSnack('Could not save the user. Please try again.');
      return;
    }

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
                (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
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
            onChanged: _saving ? null : (v) => setState(() => _role = v ?? _role),
          ),
          gap,
          AppTextField(
            controller: _designation,
            label: 'Designation',
            hint: 'e.g. Sales Executive',
            prefixIcon: Icons.work_outline_rounded,
            textInputAction: TextInputAction.next,
            enabled: !_saving,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter a designation' : null,
          ),
          gap,
          AppTextField(
            controller: _department,
            label: 'Department',
            prefixIcon: Icons.account_tree_outlined,
            textInputAction: TextInputAction.done,
            enabled: !_saving,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter a department' : null,
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
              value: _manager,
              items: _withCurrent(widget.managers, _manager),
              labelOf: (s) => s,
              onChanged: _saving ? null : (v) => setState(() => _manager = v),
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