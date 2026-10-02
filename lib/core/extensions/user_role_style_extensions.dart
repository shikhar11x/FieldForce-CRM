import 'package:flutter/material.dart';

import '../../data/models/user_role.dart';
import '../theme/app_colors.dart';

extension UserRoleStyle on UserRole {
  Color get color => switch (this) {
        UserRole.admin => AppColors.accent,
        UserRole.manager => AppColors.info,
        UserRole.employee => AppColors.secondary,
      };
}