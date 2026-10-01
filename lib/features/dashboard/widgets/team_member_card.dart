import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/manager_models.dart';

class TeamMemberCard extends StatelessWidget {
  const TeamMemberCard({super.key, required this.member});

  final TeamMemberStats member;

  (String, Color) _levelFor(int percent) {
    if (percent >= 85) return ('Excellent', AppColors.success);
    if (percent >= 70) return ('Good', AppColors.info);
    return ('Needs focus', AppColors.warning);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final (levelLabel, levelColor) = _levelFor(member.completionPercent);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              InitialsAvatar(name: member.name),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    Text(
                      member.designation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              StatusChip(label: levelLabel, color: levelColor),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: member.completionPercent / 100,
                    minHeight: 6,
                    color: levelColor,
                    backgroundColor: levelColor.withValues(alpha: 0.15),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${member.completionPercent}%',
                style: theme.textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _Metric(
                icon: Icons.place_rounded,
                text: '${member.visits} visits',
              ),
              const SizedBox(width: AppSpacing.xl),
              _Metric(
                icon: Icons.task_alt_rounded,
                text: '${member.tasks} tasks',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: muted),
        const SizedBox(width: 4),
        Text(text, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
      ],
    );
  }
}