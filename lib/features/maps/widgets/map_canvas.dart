import 'package:flutter/material.dart';

import '../../../core/extensions/map_style_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/map_models.dart';
import '../../../data/models/task_enums.dart';

const double _inset = 32;

Offset _project(Size size, MapMarkerData m) => Offset(
      _inset + m.x * (size.width - _inset * 2),
      _inset + m.y * (size.height - _inset * 2),
    );

/// Painted placeholder map with tappable markers and a route line.
/// Phase 2 swaps this widget for Google Maps / Mapbox with the same inputs.
class MapCanvas extends StatelessWidget {
  const MapCanvas({
    super.key,
    required this.markers,
    required this.route,
    required this.selectedId,
    required this.onSelect,
    this.height = 380,
  });

  final List<MapMarkerData> markers;

  /// Visit stops in route order.
  final List<MapMarkerData> route;
  final String? selectedId;
  final ValueChanged<MapMarkerData> onSelect;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: AppRadius.lgAll,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);

            // The selected marker is drawn last so it sits on top.
            final ordered = [
              for (final m in markers)
                if (m.id != selectedId) m,
              for (final m in markers)
                if (m.id == selectedId) m,
            ];

            return Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _MapPainter(
                      background:
                          scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      grid: scheme.outlineVariant.withValues(alpha: 0.5),
                      road: scheme.surface,
                      park: AppColors.success.withValues(alpha: 0.14),
                      water: AppColors.info.withValues(alpha: 0.16),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: _RoutePainter(
                      points: [
                        for (final m in route)
                          (
                            offset: _project(size, m),
                            done: m.visitStatus == VisitStatus.completed,
                          ),
                      ],
                      doneColor: AppColors.success,
                      todoColor: scheme.primary,
                    ),
                  ),
                ),
                for (final m in ordered)
                  Positioned(
                    left: _project(size, m).dx - 20,
                    top: _project(size, m).dy - 20,
                    width: 40,
                    height: 40,
                    child: _Pin(
                      marker: m,
                      selected: m.id == selectedId,
                      onTap: () => onSelect(m),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Pin extends StatelessWidget {
  const _Pin({
    required this.marker,
    required this.selected,
    required this.onTap,
  });

  final MapMarkerData marker;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = marker.color;
    final number = marker.stopNumber;
    final isMe = marker.kind == MapMarkerKind.me;

    return Semantics(
      button: true,
      label: marker.title,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: selected ? 1.25 : 1,
          duration: const Duration(milliseconds: 150),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: isMe
                      ? color.withValues(alpha: 0.28)
                      : Colors.black.withValues(alpha: 0.25),
                  blurRadius: isMe ? 0 : 6,
                  spreadRadius: isMe ? 6 : 0,
                  offset: isMe ? Offset.zero : const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: number != null
                  ? Text(
                      '$number',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : Icon(marker.kind.icon, size: 18, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter({
    required this.background,
    required this.grid,
    required this.road,
    required this.park,
    required this.water,
  });

  final Color background;
  final Color grid;
  final Color road;
  final Color park;
  final Color water;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(Offset.zero & size, Paint()..color = background);

    final waterPath = Path()
      ..moveTo(0, h * 0.88)
      ..quadraticBezierTo(w * 0.3, h * 0.72, w * 0.55, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(waterPath, Paint()..color = water);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.62, h * 0.04, w * 0.2, h * 0.2),
        const Radius.circular(16),
      ),
      Paint()..color = park,
    );

    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (double x = 0; x <= w; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 0; y <= h; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    final roadPaint = Paint()
      ..color = road
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.40)
        ..quadraticBezierTo(w * 0.5, h * 0.22, w, h * 0.46),
      roadPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.3, 0)
        ..quadraticBezierTo(w * 0.42, h * 0.5, w * 0.36, h),
      roadPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.7)
        ..lineTo(w, h * 0.58),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) =>
      old.background != background ||
      old.grid != grid ||
      old.road != road ||
      old.park != park ||
      old.water != water;
}

class _RoutePainter extends CustomPainter {
  _RoutePainter({
    required this.points,
    required this.doneColor,
    required this.todoColor,
  });

  final List<({Offset offset, bool done})> points;
  final Color doneColor;
  final Color todoColor;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < points.length - 1; i++) {
      canvas.drawLine(
        points[i].offset,
        points[i + 1].offset,
        Paint()
          ..color = points[i + 1].done ? doneColor : todoColor
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePainter old) => true;
}