import 'package:flutter/material.dart';

import '../../data/models/notification_models.dart';
import '../theme/app_colors.dart';

extension NotificationCategoryStyle on NotificationCategory {
  IconData get icon => switch (this) {
        NotificationCategory.tasks => Icons.task_alt_rounded,
        NotificationCategory.visits => Icons.place_rounded,
        NotificationCategory.attendance => Icons.event_available_rounded,
        NotificationCategory.leads => Icons.filter_alt_rounded,
        NotificationCategory.system => Icons.notifications_active_rounded,
      };

  Color get color => switch (this) {
        NotificationCategory.tasks => AppColors.primary,
        NotificationCategory.visits => AppColors.info,
        NotificationCategory.attendance => AppColors.accent,
        NotificationCategory.leads => AppColors.secondary,
        NotificationCategory.system => AppColors.lightTextSecondary,
      };
}