import 'package:flutter/material.dart';

import '../../data/models/map_models.dart';
import '../theme/app_colors.dart';
import 'task_style_extensions.dart';

extension MapMarkerKindStyle on MapMarkerKind {
  IconData get icon => switch (this) {
        MapMarkerKind.me => Icons.my_location_rounded,
        MapMarkerKind.employee => Icons.person_rounded,
        MapMarkerKind.customer => Icons.storefront_rounded,
        MapMarkerKind.visit => Icons.place_rounded,
      };

  Color get color => switch (this) {
        MapMarkerKind.me => AppColors.primary,
        MapMarkerKind.employee => AppColors.accent,
        MapMarkerKind.customer => AppColors.secondary,
        MapMarkerKind.visit => AppColors.info,
      };

  String get label => switch (this) {
        MapMarkerKind.me => 'You',
        MapMarkerKind.employee => 'Team member',
        MapMarkerKind.customer => 'Customer',
        MapMarkerKind.visit => 'Visit stop',
      };
}

extension MapMarkerStyle on MapMarkerData {
  /// Visit stops take their color from the visit status.
  Color get color => visitStatus?.color ?? kind.color;
}