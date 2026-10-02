import '../models/map_models.dart';

/// Phase 2 swaps the mock implementation for an API-backed one.
abstract class MapRepository {
  Future<MapData> getMapData();
}