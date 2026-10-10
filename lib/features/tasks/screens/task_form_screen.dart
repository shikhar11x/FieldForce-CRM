import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/datetime_extensions.dart';
import '../../../core/extensions/task_style_extensions.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/adaptive_wrap.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/picker_field.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../../data/models/app_user.dart';
import '../../../data/models/task_enums.dart';
import '../../../data/models/task_models.dart';
import '../../../data/models/user_role.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/task_provider.dart';

/// Create (no [taskId]) or edit (with [taskId]) a task. When creating,
/// [initialCustomer] (customer ka naam) preselects the customer.
class TaskFormScreen extends ConsumerWidget {
  const TaskFormScreen({super.key, this.taskId, this.initialCustomer});

  final String? taskId;
  final String? initialCustomer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final options = ref.watch(taskFormOptionsProvider);
    final tasks = ref.watch(tasksProvider);

    // Briefly null while the router redirects after logout.
    if (user == null) return const SizedBox.shrink();

    final id = taskId;

    return Scaffold(
      appBar: AppBar(title: Text(id == null ? 'New task' : 'Edit task')),
      body: ResponsiveBody(
        maxWidth: 700,
        child: AsyncValueView<TaskFormOptions>(
          value: options,
          onRetry: () => ref.invalidate(taskFormOptionsProvider),
          loading: const _FormSkeleton(),
          data: (opts) {
            if (id == null) {
              return _TaskForm(
                key: const ValueKey('new-task'),
                options: opts,
                user: user,
                initialCustomer: initialCustomer,
              );
            }
            return AsyncValueView<List<TaskItem>>(
              value: tasks,
              onRetry: () => ref.invalidate(tasksProvider),
              loading: const _FormSkeleton(),
              data: (list) {
                final task = findTask(list, id);
                if (task == null) {
                  return const EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'Task not found',
                    message: 'It may have been removed.',
                  );
                }
                return _TaskForm(
                  key: ValueKey(id),
                  initial: task,
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

class _TaskForm extends ConsumerStatefulWidget {
  const _TaskForm({
    super.key,
    this.initial,
    this.initialCustomer,
    required this.options,
    required this.user,
  });

  final TaskItem? initial;
  final String? initialCustomer;
  final TaskFormOptions options;
  final AppUser user;

  @override
  ConsumerState<_TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends ConsumerState<_TaskForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _location;

  late final List<FormOption> _customers;
  late final List<FormOption> _assignees;
  String? _customerId;
  String? _assigneeId;
  late DateTime _date;
  late TimeOfDay _time;
  late TaskPriority _priority;
  late TaskStatus _status;
  bool _saving = false;

  bool get _isEdit => widget.initial != null;
  bool get _isEmployee => widget.user.role == UserRole.employee;

  @override
  void initState() {
    super.initState();
    final t = widget.initial;
    _title = TextEditingController(text: t?.title);
    _description = TextEditingController(text: t?.description);
    _location = TextEditingController(text: t?.location);

    _customers = [...widget.options.customers];
    _assignees = [...widget.options.assignees];

    if (t != null) {
      _customerId = _resolve(_customers, t.customerId, t.customer);
      _assigneeId = _resolve(_assignees, t.assigneeId, t.assignee);

      // Task ka purana customer ya assignee ab options me na ho to bhi dikhe.
      if (_customerId == null) {
        _customers.add(FormOption(id: t.customerId, name: t.customer));
        _customerId = t.customerId;
      }
      if (_assigneeId == null) {
        _assignees.add(FormOption(id: t.assigneeId, name: t.assignee));
        _assigneeId = t.assigneeId;
      }
    } else {
      final customerName = widget.initialCustomer;
      if (customerName != null) {
        _customerId = _resolve(_customers, '', customerName);
      }
      if (_isEmployee) {
        _assigneeId = _resolve(_assignees, widget.user.id, widget.user.name);
      }
    }

    final due = t?.due ?? DateTime.now().add(const Duration(days: 1));
    _date = DateTime(due.year, due.month, due.day);
    _time = t != null
        ? TimeOfDay.fromDateTime(due)
        : const TimeOfDay(hour: 10, minute: 0);

    _priority = t?.priority ?? TaskPriority.medium;
    _status = t?.status ?? TaskStatus.pending;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _location.dispose();
    super.dispose();
  }

  /// Pehle id se dhundta hai, na mile to naam se (mock mode me ids naam hi hain).
  String? _resolve(List<FormOption> options, String id, String name) {
    if (id.isNotEmpty) {
      for (final o in options) {
        if (o.id == id) return o.id;
      }
    }
    for (final o in options) {
      if (o.name == name) return o.id;
    }
    return null;
  }

  String _nameOf(List<FormOption> options, String id) {
    for (final o in options) {
      if (o.id == id) return o.name;
    }
    return '';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    final initial = widget.initial;
    final customerId = _customerId!;
    final assigneeId = _assigneeId!;

    final task = TaskItem(
      // Server asli id deta hai; ye sirf mock mode ke liye.
      id: initial?.id ?? 't${DateTime.now().microsecondsSinceEpoch}',
      title: _title.text.trim(),
      description: _description.text.trim(),
      customer: _nameOf(_customers, customerId),
      customerId: customerId,
      assignee: _nameOf(_assignees, assigneeId),
      assigneeId: assigneeId,
      due: DateTime(
        _date.year,
        _date.month,
        _date.day,
        _time.hour,
        _time.minute,
      ),
      priority: _priority,
      status: _status,
      location: _location.text.trim(),
    );

    final notifier = ref.read(tasksProvider.notifier);
    try {
      if (initial == null) {
        await notifier.addTask(task);
      } else {
        await notifier.saveTask(task);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      context.showSnack(e.message);
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      context.showSnack('Could not save the task. Please try again.');
      return;
    }

    if (!mounted) return;
    context.showSnack(initial == null ? 'Task created.' : 'Task updated.');
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
            controller: _title,
            label: 'Title',
            hint: 'e.g. Collect signed contract',
            prefixIcon: Icons.title_rounded,
            textInputAction: TextInputAction.next,
            enabled: !_saving,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
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
              hintText: 'Add details the assignee should know',
              alignLabelWithHint: true,
            ),
          ),
          gap,
          AppDropdown<String>(
            label: 'Customer',
            icon: Icons.business_rounded,
            value: _customerId,
            items: [for (final c in _customers) c.id],
            labelOf: (id) => _nameOf(_customers, id),
            onChanged: _saving ? null : (v) => setState(() => _customerId = v),
            validator: (v) => v == null ? 'Select a customer' : null,
          ),
          gap,
          AppDropdown<String>(
            label: 'Assigned to',
            icon: Icons.person_outline_rounded,
            value: _assigneeId,
            items: [for (final a in _assignees) a.id],
            labelOf: (id) => _nameOf(_assignees, id),
            // Employees can only create tasks for themselves.
            onChanged: (_saving || _isEmployee)
                ? null
                : (v) => setState(() => _assigneeId = v),
            validator: (v) => v == null ? 'Select an assignee' : null,
          ),
          gap,
          AdaptiveWrap(
            columns: (width) => width >= 520 ? 2 : 1,
            children: [
              PickerField(
                icon: Icons.event_rounded,
                label: 'Due date',
                value: _date.shortDate,
                onTap: _saving ? null : _pickDate,
              ),
              PickerField(
                icon: Icons.schedule_rounded,
                label: 'Due time',
                value: _time.format(context),
                onTap: _saving ? null : _pickTime,
              ),
            ],
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
          AppDropdown<TaskStatus>(
            label: 'Status',
            icon: Icons.flag_outlined,
            value: _status,
            items: TaskStatus.values,
            labelOf: (s) => s.label,
            onChanged: _saving
                ? null
                : (v) => setState(() => _status = v ?? _status),
          ),
          gap,
          AppTextField(
            controller: _location,
            label: 'Location',
            hint: 'Address or area (optional)',
            prefixIcon: Icons.place_outlined,
            textInputAction: TextInputAction.done,
            enabled: !_saving,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: _isEdit ? 'Save changes' : 'Create task',
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