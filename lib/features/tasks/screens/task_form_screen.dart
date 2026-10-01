import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/datetime_extensions.dart';
import '../../../core/extensions/task_style_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/adaptive_wrap.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../../data/models/app_user.dart';
import '../../../data/models/task_enums.dart';
import '../../../data/models/task_models.dart';
import '../../../data/models/user_role.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/task_provider.dart';

/// Create (no [taskId]) or edit (with [taskId]) a task.
class TaskFormScreen extends ConsumerWidget {
  const TaskFormScreen({super.key, this.taskId});

  final String? taskId;

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
    required this.options,
    required this.user,
  });

  final TaskItem? initial;
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

  String? _customer;
  String? _assignee;
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

    _customer = t?.customer;
    _assignee = t?.assignee ?? (_isEmployee ? widget.user.name : null);

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

  List<String> _withCurrent(List<String> options, String? current) {
    if (current == null || options.contains(current)) return options;
    return [...options, current];
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
    final task = TaskItem(
      id: initial?.id ?? 't${DateTime.now().microsecondsSinceEpoch}',
      title: _title.text.trim(),
      description: _description.text.trim(),
      customer: _customer!,
      assignee: _assignee!,
      due: DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute),
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

  Widget _dropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<T> items,
    required String Function(T) labelOf,
    required ValueChanged<T?>? onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      items: [
        for (final item in items)
          DropdownMenuItem<T>(
            value: item,
            child: Text(labelOf(item), overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged,
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const gap = SizedBox(height: AppSpacing.lg);
    final time = _time.format(context);

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
          _dropdown<String>(
            label: 'Customer',
            icon: Icons.business_rounded,
            value: _customer,
            items: _withCurrent(widget.options.customers, _customer),
            labelOf: (s) => s,
            onChanged: _saving ? null : (v) => setState(() => _customer = v),
            validator: (v) => v == null ? 'Select a customer' : null,
          ),
          gap,
          _dropdown<String>(
            label: 'Assigned to',
            icon: Icons.person_outline_rounded,
            value: _assignee,
            items: _withCurrent(widget.options.employees, _assignee),
            labelOf: (s) => s,
            // Employees can only create tasks for themselves.
            onChanged: (_saving || _isEmployee)
                ? null
                : (v) => setState(() => _assignee = v),
            validator: (v) => v == null ? 'Select an assignee' : null,
          ),
          gap,
          AdaptiveWrap(
            columns: (width) => width >= 520 ? 2 : 1,
            children: [
              _PickerField(
                icon: Icons.event_rounded,
                label: 'Due date',
                value: _date.shortDate,
                onTap: _saving ? null : _pickDate,
              ),
              _PickerField(
                icon: Icons.schedule_rounded,
                label: 'Due time',
                value: time,
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
          _dropdown<TaskStatus>(
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

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdAll,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
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