import 'task_enums.dart';

enum MapMarkerKind { me, employee, customer, visit }

class MapMarkerData {
  const MapMarkerData({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.x,
    required this.y,
    this.stopNumber,
    this.visitStatus,
  });

  final String id;
  final MapMarkerKind kind;
  final String title;
  final String subtitle;

  /// Normalised 0..1 position on the mock map. Real coordinates
  /// (latitude / longitude) replace these in Phase 2.
  final double x;
  final double y;

  /// Set for visit stops.
  final int? stopNumber;
  final VisitStatus? visitStatus;
}

class MapData {
  const MapData({required this.markers, required this.route});

  final List<MapMarkerData> markers;

  /// Marker ids of the visit stops, in route order.
  final List<String> route;
}