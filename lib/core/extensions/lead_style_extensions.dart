import 'package:flutter/material.dart';

import '../../data/models/lead_models.dart';
import '../theme/app_colors.dart';

extension LeadStageStyle on LeadStage {
  Color get color => switch (this) {
        LeadStage.newLead => AppColors.info,
        LeadStage.contacted => AppColors.primary,
        LeadStage.qualified => AppColors.secondary,
        LeadStage.proposal => AppColors.accent,
        LeadStage.negotiation => AppColors.warning,
        LeadStage.won => AppColors.success,
        LeadStage.lost => AppColors.error,
      };
}

extension LeadActivityStyle on LeadActivityType {
  IconData get icon => switch (this) {
        LeadActivityType.created => Icons.flag_rounded,
        LeadActivityType.call => Icons.call_rounded,
        LeadActivityType.meeting => Icons.groups_rounded,
        LeadActivityType.email => Icons.mail_rounded,
        LeadActivityType.note => Icons.sticky_note_2_rounded,
        LeadActivityType.stageChange => Icons.swap_horiz_rounded,
      };

  Color get color => switch (this) {
        LeadActivityType.created => AppColors.primary,
        LeadActivityType.call => AppColors.info,
        LeadActivityType.meeting => AppColors.secondary,
        LeadActivityType.email => AppColors.accent,
        LeadActivityType.note => AppColors.warning,
        LeadActivityType.stageChange => AppColors.success,
      };
}