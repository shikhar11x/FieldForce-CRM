import 'package:flutter/widgets.dart';

class Breakpoints {
  const Breakpoints._();

  static const double tablet = 600;
  static const double desktop = 900;
  static const double wide = 1200;
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  bool get isPhone => screenWidth < Breakpoints.tablet;
  bool get isTablet => screenWidth >= Breakpoints.tablet;
}