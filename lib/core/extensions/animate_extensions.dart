import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

extension EntranceAnimation on Widget {
  /// Subtle fade + slide-up. Pass an index to stagger sibling blocks.
  Widget entrance([int index = 0]) {
    return Animate(
      delay: Duration(milliseconds: 70 * index),
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 350)),
        SlideEffect(
          begin: Offset(0, 0.05),
          end: Offset.zero,
          duration: Duration(milliseconds: 350),
          curve: Curves.easeOut,
        ),
      ],
      child: this,
    );
  }
}