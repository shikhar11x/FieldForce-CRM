import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/datetime_extensions.dart';
import '../../../core/extensions/task_style_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/picker_field.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../../data/models/app_user.dart';
import '../../../data/models/lead_models.dart';
import '../../../data/models/task_enums.dart';
import '../../../data/models/user_role.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/lead_provider.dart';

/// Create (no [leadId]) or edit (with [leadId]) a lead.
class LeadFormScreen extends ConsumerWidget {
  const LeadFormScreen({super.key, this.leadId});

  final String? leadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final options = ref.watch(leadFormOptionsProvider);
    final leads = ref.watch(leadsProvider);

    // Briefly null while the router redirects after logout.
    if (user == null) return const SizedBox.shrink();

    final id = leadId;

    return Scaffold(
      appBar: AppBar(title: Text(id == null ? 'New lead' : 'Edit lead')),
      body: ResponsiveBody(
        maxWidth: 700,
        child: AsyncValueView<LeadFormOptions>(
          value: options,
          onRetry: () => ref.invalidate(leadFormOptionsProvider),
          loading: const _FormSkeleton(),
          data: (opts) {
            if (id == null) {
              return _LeadForm(
                key: const ValueKey('new-lead'),
                options: opts,
                user: user,
              );
            }
            return AsyncValueView<List<LeadItem>>(
              value: leads,
              onRetry: () => ref.invalidate(leadsProvider),
              loading: const _FormSkeleton(),
              data: (list) {
                final lead = findLead(list, id);
                if (lead == null) {
                  return const EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'Lead not found',
                    message: 'It may have been removed.',
                  );
                }
                return _LeadForm(
                  key: ValueKey(id),
                  initial: lead,
                  options: opts,
                  user: user,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _LeadForm extends ConsumerStatefulWidget {
  const _LeadForm({
    super.key,
    this.initial,
    required this.options,
    required this.user,
  });

  final LeadItem? initial;
  final LeadFormOptions options;
  final AppUser user;

  @override
  ConsumerState<_LeadForm> createState() => _LeadFormState();
}

class _LeadFormState extends ConsumerState<_LeadForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _company;
  late final TextEditingController _contact;
  late final TextEditingController _value;
  late final TextEditingController _description;

  String? _assignee;
  String? _source;
  late DateTime _closeDate;
  late TaskPriority _priority;
  late LeadStage _stage;
  bool _saving = false;

  bool get _isEdit => widget.initial != null;
  bool get _isEmployee => widget.user.role == UserRole.employee;

  @override
  void initState() {
    super.initState();
    final l = widget.initial;
    _company = TextEditingController(text: l?.customer);
    _contact = TextEditingController(text: l?.contactName);
    _value = TextEditingController(text: l?.value.toStringAsFixed(0));
    _description = TextEditingController(text: l?.description);

    _assignee = l?.assignee ?? (_isEmployee ? widget.user.name : null);
    _source = l?.source;

    final close = l?.expectedClose ??
        DateTime.now().add(const Duration(days: 30));
    _closeDate = DateTime(close.year, close.month, close.day);

    _priority = l?.priority ?? TaskPriority.medium;
    _stage = l?.stage ?? LeadStage.newLead;
  }

  @override
  void dispose() {
    _company.dispose();
    _contact.dispose();
    _value.dispose();
    _description.dispose();
    super.dispose();
  }

  List<String> _withCurrent(List<String> options, String? current) {
    if (current == null || options.contains(current)) return options;
    return [...options, current];
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _closeDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) setState(() => _closeDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    final initial = widget.initial;
    final value = int.parse(_value.text.trim()).toDouble();

    final lead = initial == null
        ? LeadItem(
            id: 'l${DateTime.now().microsecondsSinceEpoch}',
            customer: _company.text.trim(),
            contactName: _contact.text.trim(),
            value: value,
            assignee: _assignee!,
            priority: _priority,
            stage: _stage,
            source: _source!,
            expectedClose: _closeDate,
            description: _description.text.trim(),
            createdAt: DateTime.now(),
          )
        : initial.copyWith(
            customer: _company.text.trim(),
            contactName: _contact.text.trim(),
            value: value,
            assignee: _assignee,
            priority: _priority,
            stage: _stage,
            source: _source,
            expectedClose: _closeDate,
            description: _description.text.trim(),
          );

    final notifier = ref.read(leadsProvider.notifier);
    try {
      if (initial == null) {
        await notifier.addLead(lead);
      } else {
        await notifier.saveLead(lead);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      context.showSnack('Could not save the lead. Please try again.');
      return;
    }

    if (!mounted) return;
    context.showSnack(initial == null ? 'Lead created.' : 'Lead updated.');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const gap = SizedBox(height: AppSpacing.lg);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          AppTextField(
            controller: _company,
            label: 'Company',
            hint: 'e.g. Horizon Retail',
            prefixIcon: Icons.business_rounded,
            textInputAction: TextInputAction.next,
            enabled: !_saving,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter a company name' : null,
          ),
          gap,
          AppTextField(
            controller: _contact,
            label: 'Contact person',
            prefixIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            enabled: !_saving,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter a contact name' : null,
          ),
          gap,
          TextFormField(
            controller: _value,
            enabled: !_saving,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Deal value',
              hintText: 'e.g. 250000',
              prefixIcon: Icon(Icons.currency_rupee_rounded),
            ),
            validator: (v) {
              final n = int.tryParse(v?.trim() ?? '');
              if (n == null || n <= 0) return 'Enter a deal value';
              return null;
            },
          ),
          gap,
          AppDropdown<String>(
            label: 'Assigned to',
            icon: Icons.badge_outlined,
            value: _assignee,
            items: _withCurrent(widget.options.employees, _assignee),
            labelOf: (s) => s,
            // Employees can only create leads for themselves.
            onChanged: (_saving || _isEmployee)
                ? null
                : (v) => setState(() => _assignee = v),
            validator: (v) => v == null ? 'Select an assignee' : null,
          ),
          gap,
          AppDropdown<String>(
            label: 'Lead source',
            icon: Icons.campaign_outlined,
            value: _source,
            items: _withCurrent(widget.options.sources, _source),
            labelOf: (s) => s,
            onChanged: _saving ? null : (v) => setState(() => _source = v),
            validator: (v) => v == null ? 'Select a source' : null,
          ),
          gap,
          PickerField(
            icon: Icons.event_rounded,
            label: 'Expected close date',
            value: _closeDate.shortDate,
            onTap: _saving ? null : _pickDate,
          ),
          gap,
          Text('Priority', style: theme.textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final p in TaskPriority.values)
                ChoiceChip(
                  label: Text(p.label),
                  selected: _priority == p,
                  showCheckmark: false,
                  selectedColor: p.color.withValues(alpha: 0.18),
                  onSelected:
                      _saving ? null : (_) => setState(() => _priority = p),
                ),
            ],
          ),
          gap,
          AppDropdown<LeadStage>(
            label: 'Stage',
            icon: Icons.flag_outlined,
            value: _stage,
            items: LeadStage.values,
            labelOf: (s) => s.label,
            onChanged: _saving
                ? null
                : (v) => setState(() => _stage = v ?? _stage),
          ),
          gap,
          TextFormField(
            controller: _description,
            enabled: !_saving,
            minLines: 3,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'What is this deal about? (optional)',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: _isEdit ? 'Save changes' : 'Create lead',
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