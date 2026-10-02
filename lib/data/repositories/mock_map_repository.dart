import '../mock/mock_map.dart';
import '../models/map_models.dart';
import 'map_repository.dart';

class MockMapRepository implements MapRepository {
  @override
  Future<MapData> getMapData() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return MockMap.data();
  }
}