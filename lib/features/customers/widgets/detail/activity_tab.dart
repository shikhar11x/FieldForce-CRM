import 'package:flutter/material.dart';

import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/timeline_tile.dart';
import '../../../../data/models/customer_models.dart';

class ActivityTab extends StatelessWidget {
  const ActivityTab({super.key, required this.items});

  final List<CustomerActivity> items;

  (IconData, Color) _styleFor(CustomerActivityType type) => switch (type) {
        CustomerActivityType.call => (Icons.call_rounded, AppColors.info),
        CustomerActivityType.visit => (Icons.place_rounded, AppColors.success),
        CustomerActivityType.task =>
          (Icons.task_alt_rounded, AppColors.warning),
        CustomerActivityType.note =>
          (Icons.sticky_note_2_rounded, AppColors.accent),
        CustomerActivityType.statusUpdate =>
          (Icons.flag_rounded, AppColors.primary),
      };

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const EmptyState(
        icon: Icons.history_rounded,
        title: 'No activity yet',
        message: 'Calls, visits and notes will appear here.',
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        AppCard(
          child: Column(
            children: [
              for (final (i, item) in items.indexed)
                TimelineTile(
                  icon: _styleFor(item.type).$1,
                  color: _styleFor(item.type).$2,
                  title: item.title,
                  subtitle: item.description,
                  meta: item.timestamp.timeAgo,
                  isLast: i == items.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}