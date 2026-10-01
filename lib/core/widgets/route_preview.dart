import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class RoutePoint {
  const RoutePoint({
    required this.x,
    required this.y,
    required this.completed,
  });

  /// Normalised 0..1 coordinates inside the preview.
  final double x;
  final double y;
  final bool completed;
}

/// Painted placeholder map. Phase 2 swaps this for Google Maps / Mapbox
/// behind the same call site.
class RoutePreview extends StatelessWidget {
  const RoutePreview({super.key, required this.points, this.height = 190});

  final List<RoutePoint> points;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _RoutePainter(
          points: points,
          background: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
          grid: scheme.outlineVariant.withValues(alpha: 0.6),
          done: AppColors.success,
          todo: scheme.primary,
        ),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  _RoutePainter({
    required this.points,
    required this.background,
    required this.grid,
    required this.done,
    required this.todo,
  });

  final List<RoutePoint> points;
  final Color background;
  final Color grid;
  final Color done;
  final Color todo;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);

    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (double x = 0; x <= size.width; x += 36) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += 36) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    const inset = 28.0;
    final offsets = [
      for (final p in points)
        Offset(
          inset + p.x * (size.width - inset * 2),
          inset + p.y * (size.height - inset * 2),
        ),
    ];

    for (var i = 0; i < offsets.length - 1; i++) {
      canvas.drawLine(
        offsets[i],
        offsets[i + 1],
        Paint()
          ..color = points[i + 1].completed ? done : todo
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
    }

    for (var i = 0; i < offsets.length; i++) {
      final o = offsets[i];
      canvas.drawCircle(o, 14, Paint()..color = Colors.white);
      canvas.drawCircle(
        o,
        11,
        Paint()..color = points[i].completed ? done : todo,
      );

      final label = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(canvas, o - Offset(label.width / 2, label.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePainter old) =>
      old.points != points ||
      old.background != background ||
      old.grid != grid ||
      old.done != done ||
      old.todo != todo;
}