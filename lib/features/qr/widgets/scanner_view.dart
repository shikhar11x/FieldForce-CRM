import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

/// Camera ke upar scanner frame aur status. [child] live camera preview hai.
class ScannerView extends StatelessWidget {
  const ScannerView({
    super.key,
    required this.child,
    this.busy = false,
    this.caption,
  });

  final Widget child;
  final bool busy;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: AppRadius.lgAll,
      child: SizedBox(
        height: 340,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: Colors.black, child: child),
            Center(
              child: CustomPaint(
                size: const Size.square(220),
                painter: _FramePainter(color: Colors.white),
              ),
            ),
            if (busy)
              ColoredBox(
                color: Colors.black.withValues(alpha: 0.55),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            if (caption != null)
              Positioned(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: AppSpacing.lg,
                child: Text(
                  caption!,
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FramePainter extends CustomPainter {
  _FramePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const len = 36.0;
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(
      Path()
        ..moveTo(0, len)
        ..lineTo(0, 0)
        ..lineTo(len, 0),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w - len, 0)
        ..lineTo(w, 0)
        ..lineTo(w, len),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w, h - len)
        ..lineTo(w, h)
        ..lineTo(w - len, h),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(len, h)
        ..lineTo(0, h)
        ..lineTo(0, h - len),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _FramePainter old) => old.color != color;
}