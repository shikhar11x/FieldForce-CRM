import 'package:flutter/material.dart';

import '../../data/models/customer_models.dart';
import '../theme/app_colors.dart';

extension CustomerStatusStyle on CustomerStatus {
  Color get color => switch (this) {
        CustomerStatus.active => AppColors.success,
        CustomerStatus.inactive => AppColors.lightTextSecondary,
        CustomerStatus.newCustomer => AppColors.info,
      };
}