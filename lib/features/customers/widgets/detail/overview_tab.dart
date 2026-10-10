import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/customer_style_extensions.dart';
import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../core/extensions/task_style_extensions.dart';
import '../../../../core/routing/app_navigation.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_wrap.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/detail_row.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../data/models/customer_models.dart';
import '../../../../data/models/task_enums.dart';
import '../../../../data/models/user_role.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key, required this.customer, required this.role});

  final Customer customer;
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        AppCard(
          child: Row(
            children: [
              InitialsAvatar(name: customer.company, radius: 28),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer.company, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      customer.contactName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        StatusChip(
                          label: customer.status.label,
                          color: customer.status.color,
                        ),
                        if (customer.highPriority)
                          StatusChip(
                            label: 'High priority',
                            color: TaskPriority.high.color,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SectionHeader(title: 'Contact information'),
        AppCard(
          child: Column(
            children: [
              DetailRow(
                icon: Icons.person_outline_rounded,
                label: 'Contact person',
                value: customer.contactName,
              ),
              DetailRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: customer.phone,
              ),
              DetailRow(
                icon: Icons.mail_outline_rounded,
                label: 'Email',
                value: customer.email,
              ),
            ],
          ),
        ),
        const SectionHeader(title: 'Address'),
        AppCard(
          child: DetailRow(
            icon: Icons.place_outlined,
            label: 'Business address',
            value: customer.address,
          ),
        ),
        const SectionHeader(title: 'Assignment'),
        AppCard(
          child: Column(
            children: [
              DetailRow(
                icon: Icons.badge_outlined,
                label: 'Assigned employee',
                value: customer.assignedEmployee,
              ),
              DetailRow(
                icon: Icons.history_rounded,
                label: 'Last visit',
                value: customer.lastVisit?.shortDate ?? 'No visits yet',
              ),
              DetailRow(
                icon: Icons.event_rounded,
                label: 'Next visit',
                value: customer.nextVisit?.shortDate ?? 'Not scheduled',
              ),
            ],
          ),
        ),
        const SectionHeader(title: 'Actions'),
        AdaptiveWrap(
          columns: (width) => width >= 560 ? 3 : 2,
          children: [
            _ActionButton(
              icon: Icons.call_rounded,
              label: 'Call',
              onTap: () => context.showSnack(
                'Calling ${customer.phone} is wired up in Phase 2.',
              ),
            ),
            _ActionButton(
              icon: Icons.mail_rounded,
              label: 'Email',
              onTap: () => context.showSnack(
                'Emailing ${customer.email} is wired up in Phase 2.',
              ),
            ),
            _ActionButton(
              icon: Icons.navigation_rounded,
              label: 'Navigate',
              onTap: () => context.push('${role.basePath}/maps'),
            ),
            _ActionButton(
              icon: Icons.event_available_rounded,
              label: 'Schedule Visit',
              onTap: () => context.showSnack(
                'Visit scheduling is wired up in Phase 2.',
              ),
            ),
            _ActionButton(
              icon: Icons.add_task_rounded,
              label: 'Create Task',
              onTap: () {
                final path = newTaskPath(role, customer: customer.company);
                if (path == null) {
                  context.showSnack(
                    'Tasks are created by managers and employees.',
                  );
                } else {
                  context.go(path);
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}