import 'package:flutter/material.dart';

import '../../../core/widgets/adaptive_wrap.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/manager_models.dart';
import 'dashboard_layout.dart';
import 'team_member_card.dart';

class TeamPerformanceList extends StatelessWidget {
  const TeamPerformanceList({super.key, required this.members});

  final List<TeamMemberStats> members;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return const AppCard(
        child: EmptyState(
          icon: Icons.groups_outlined,
          title: 'No team members yet',
          message: 'Employees assigned to you will appear here.',
        ),
      );
    }

    return AdaptiveWrap(
      columns: DashboardLayout.teamColumns,
      children: [
        for (final member in members) TeamMemberCard(member: member),
      ],
    );
  }
}