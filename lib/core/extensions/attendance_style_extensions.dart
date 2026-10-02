import 'package:flutter/material.dart';

import '../../data/models/attendance_models.dart';
import '../theme/app_colors.dart';

extension AttendanceStatusStyle on AttendanceDayStatus {
  Color get color => switch (this) {
        AttendanceDayStatus.present => AppColors.success,
        AttendanceDayStatus.lateIn => AppColors.warning,
        AttendanceDayStatus.halfDay => AppColors.info,
        AttendanceDayStatus.absent => AppColors.error,
        AttendanceDayStatus.weekOff => AppColors.lightTextSecondary,
      };
}