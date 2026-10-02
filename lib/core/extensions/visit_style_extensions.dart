import 'package:flutter/material.dart';

import '../../data/models/visit_models.dart';
import '../theme/app_colors.dart';
import 'datetime_extensions.dart';

extension VisitTypeStyle on VisitType {
  IconData get icon => switch (this) {
        VisitType.sales => Icons.storefront_rounded,
        VisitType.service => Icons.build_rounded,
        VisitType.followUp => Icons.phone_callback_rounded,
        VisitType.delivery => Icons.local_shipping_rounded,
        VisitType.demo => Icons.slideshow_rounded,
      };
}

extension VisitEventStyle on VisitEventType {
  IconData get icon => switch (this) {
        VisitEventType.scheduled => Icons.event_rounded,
        VisitEventType.started => Icons.play_arrow_rounded,
        VisitEventType.qrVerified => Icons.qr_code_2_rounded,
        VisitEventType.note => Icons.sticky_note_2_rounded,
        VisitEventType.photo => Icons.photo_camera_rounded,
        VisitEventType.completed => Icons.check_circle_rounded,
        VisitEventType.cancelled => Icons.cancel_rounded,
      };

  Color get color => switch (this) {
        VisitEventType.scheduled => AppColors.primary,
        VisitEventType.started => AppColors.info,
        VisitEventType.qrVerified => AppColors.success,
        VisitEventType.note => AppColors.accent,
        VisitEventType.photo => AppColors.secondary,
        VisitEventType.completed => AppColors.success,
        VisitEventType.cancelled => AppColors.error,
      };
}

extension VisitItemLabels on VisitItem {
  /// e.g. "Today, 9:30 AM".
  String scheduleLabel(BuildContext context) =>
      '${scheduledAt.dayLabel}, ${TimeOfDay.fromDateTime(scheduledAt).format(context)}';
}