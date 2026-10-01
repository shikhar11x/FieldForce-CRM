import 'package:flutter/material.dart';

import '../../data/models/task_enums.dart';
import '../theme/app_colors.dart';

extension TaskPriorityStyle on TaskPriority {
  Color get color => switch (this) {
        TaskPriority.low => AppColors.info,
        TaskPriority.medium => AppColors.warning,
        TaskPriority.high => const Color(0xFFEA580C),
        TaskPriority.urgent => AppColors.error,
      };
}

extension TaskStatusStyle on TaskStatus {
  Color get color => switch (this) {
        TaskStatus.pending => AppColors.warning,
        TaskStatus.inProgress => AppColors.primary,
        TaskStatus.completed => AppColors.success,
        TaskStatus.cancelled => AppColors.lightTextSecondary,
      };
}

extension VisitStatusStyle on VisitStatus {
  Color get color => switch (this) {
        VisitStatus.scheduled => AppColors.primary,
        VisitStatus.started => AppColors.info,
        VisitStatus.completed => AppColors.success,
        VisitStatus.cancelled => AppColors.lightTextSecondary,
      };
}