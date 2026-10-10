import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../../data/models/customer_models.dart';
import '../../../data/models/directory_models.dart';
import '../../../data/models/user_role.dart';
import '../../auth/providers/auth_provider.dart';
import '../../users/providers/user_provider.dart';
import '../providers/customer_provider.dart';

typedef _Assignee = ({String id, String name});

/// Create (no [customerId]) or edit (with [customerId]) a customer.
/// Employees only edit contact details: assignment, status and priority
/// belong to admins and managers.
class CustomerFormScreen extends ConsumerWidget {
  const CustomerFormScreen({super.key, this.customerId});

  final String? customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    // Briefly null while the router redirects after logout.
    if (user == null) return const SizedBox.shrink();

    final id = customerId;
    final isAdmin = user.role == UserRole.admin;
    final customers = id == null ? null : ref.watch(customersProvider);
    final users = isAdmin ? ref.watch(usersProvider) : null;

    final loads = <AsyncValue<Object?>>[
      ?customers,
      ?users,
    ];

    final Widget body;
    if (loads.any((a) => a.hasError && !a.hasValue)) {
      body = ErrorState(
        onRetry: () {
          if (customers != null) ref.invalidate(customersProvider);
          if (users != null) ref.invalidate(usersProvider);
        },
      );
    } else if (loads.any((a) => !a.hasValue)) {
      body = const _FormSkeleton();
    } else {
      Customer? initial;
      if (id != null) initial = findCustomer(customers!.requireValue, id);

      if (id != null && initial == null) {
        body = const EmptyState(
          icon: Icons.search_off_rounded,
          title: 'Customer not found',
          message: 'It may have been removed or reassigned.',
        );
      } else {
        final assignees = <_Assignee>[
          for (final u in users?.value ?? const <DirectoryUser>[])
            if (u.isActive && u.role != UserRole.admin)
              (id: u.id, name: u.name),
        ];
        body = _CustomerForm(
          key: ValueKey(id ?? 'new-customer'),
          initial: initial,
          assignees: assignees,
          role: user.role,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(id == null ? 'Add customer' : 'Edit customer')),
      body: ResponsiveBody(maxWidth: 600, child: body),
    );
  }
}

class _CustomerForm extends ConsumerStatefulWidget {
  const _CustomerForm({
    super.key,
    this.initial,
    required this.assignees,
    required this.role,
  });

  final Customer? initial;
  final List<_Assignee> assignees;
  final UserRole role;

  @override
  ConsumerState<_CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends ConsumerState<_CustomerForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _company;
  late final TextEditingController _contact;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _address;

  String? _assigneeId;
  late CustomerStatus _status;
  late bool _priority;
  bool _saving = false;

  bool get _isEdit => widget.initial != null;
  bool get _isAdmin => widget.role == UserRole.admin;
  bool get _canManage => widget.role != UserRole.employee;

  @override
  void initState() {
    super.initState();
    final c = widget.initial;
    _company = TextEditingController(text: c?.company);
    _contact = TextEditingController(text: c?.contactName);
    _phone = TextEditingController(text: c?.phone);
    _email = TextEditingController(text: c?.email);
    _address = TextEditingController(text: c?.address);

    _assigneeId =
        (c == null || c.assignedEmployeeId.isEmpty) ? null : c.assignedEmployeeId;
    _status = c?.status ?? CustomerStatus.newCustomer;
    _priority = c?.highPriority ?? false;
  }

  @override
  void dispose() {
    _company.dispose();
    _contact.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    super.dispose();
  }

  /// Assignee list, plus the current assignee even if now inactive.
  List<_Assignee> get _assigneeOptions {
    final initial = widget.initial;
    final options = [...widget.assignees];
    if (initial != null &&
        initial.assignedEmployeeId.isNotEmpty &&
        !options.any((a) => a.id == initial.assignedEmployeeId)) {
      options.add(
        (id: initial.assignedEmployeeId, name: initial.assignedEmployee),
      );
    }
    return options;
  }

  String _assigneeName(String id) {
    for (final a in _assigneeOptions) {
      if (a.id == id) return a.name;
    }
    return 'Unassigned';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    final initial = widget.initial;
    final assigneeId = _assigneeId ?? '';

    final customer = Customer(
      id: initial?.id ?? '',
      company: _company.text.trim(),
      contactName: _contact.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      address: _address.text.trim(),
      status: _status,
      assignedEmployee:
          assigneeId.isEmpty ? 'Unassigned' : _assigneeName(assigneeId),
      assignedEmployeeId: assigneeId,
      lastVisit: initial?.lastVisit,
      nextVisit: initial?.nextVisit,
      highPriority: _priority,
    );

    final repo = ref.read(customerRepositoryProvider);
    try {
      if (initial == null) {
        await repo.createCustomer(customer, includeManagedFields: _canManage);
      } else {
        await repo.updateCustomer(customer, includeManagedFields: _canManage);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      context.showSnack(e.message);
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      context.showSnack('Could not save the customer. Please try again.');
      return;
    }

    // Server source of truth hai: list aur detail dobara load hote hain.
    ref.invalidate(customersProvider);
    if (initial != null) ref.invalidate(customerDetailProvider(initial.id));

    if (!mounted) return;
    context.showSnack(initial == null ? 'Customer added.' : 'Customer updated.');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: AppSpacing.lg);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          AppTextField(
            controller: _company,
            label: 'Company',
            prefixIcon: Icons.business_rounded,
            textInputAction: TextInputAction.next,
            enabled: !_saving,
            validator: (v) => (v == null || v.trim().length < 2)
                ? 'Enter the company name'
                : null,
          ),
          gap,
          AppTextField(
            controller: _contact,
            label: 'Contact person',
            prefixIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            enabled: !_saving,
            validator: (v) => (v == null || v.trim().length < 2)
                ? 'Enter a contact name'
                : null,
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
          TextFormField(
            controller: _address,
            enabled: !_saving,
            minLines: 2,
            maxLines: 4,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Address',
              prefixIcon: Icon(Icons.place_outlined),
              alignLabelWithHint: true,
            ),
            validator: (v) => (v == null || v.trim().length < 5)
                ? 'Enter the full address'
                : null,
          ),
          if (_isAdmin) ...[
            gap,
            AppDropdown<String>(
              label: 'Assigned to',
              icon: Icons.badge_outlined,
              value: _assigneeId,
              items: [for (final a in _assigneeOptions) a.id],
              labelOf: _assigneeName,
              onChanged:
                  _saving ? null : (v) => setState(() => _assigneeId = v),
              validator: (v) => v == null ? 'Select who handles this customer' : null,
            ),
          ],
          if (_canManage) ...[
            gap,
            AppDropdown<CustomerStatus>(
              label: 'Status',
              icon: Icons.flag_outlined,
              value: _status,
              items: CustomerStatus.values,
              labelOf: (s) => s.label,
              onChanged: _saving
                  ? null
                  : (v) => setState(() => _status = v ?? _status),
            ),
            const SizedBox(height: AppSpacing.sm),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('High priority'),
              subtitle: const Text('Highlight this customer for the team'),
              value: _priority,
              onChanged: _saving ? null : (v) => setState(() => _priority = v),
            ),
          ] else if (!_isEdit) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'New customers are assigned to you.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: _isEdit ? 'Save changes' : 'Add customer',
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