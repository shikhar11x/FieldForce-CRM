import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Camera placeholder with a scanner frame. Phase 2 swaps the dark
/// backdrop for a live camera preview and keeps the frame overlay.
class ScannerView extends StatelessWidget {
  const ScannerView({super.key, this.busy = false});

  final bool busy;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 320,
      decoration: BoxDecoration(
        borderRadius: AppRadius.lgAll,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B1020), Color(0xFF1A2038)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.square(
            dimension: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size.square(220),
                  painter: _FramePainter(color: Colors.white),
                ),
                if (busy)
                  const CircularProgressIndicator(color: Colors.white)
                else
                  Positioned(
                    left: 14,
                    right: 14,
                    top: 12,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryLight
                                .withValues(alpha: 0.7),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .moveY(
                          begin: 0,
                          end: 190,
                          duration: 1600.ms,
                          curve: Curves.easeInOut,
                        ),
                  ),
              ],
            ),
          ),
          Positioned(
            bottom: AppSpacing.lg,
            child: Text(
              busy ? 'Verifying...' : 'Camera preview appears here',
              style: textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
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