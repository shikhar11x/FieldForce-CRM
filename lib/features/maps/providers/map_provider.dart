import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/map_models.dart';
import '../../../data/repositories/map_repository.dart';
import '../../../data/repositories/mock_map_repository.dart';

final mapRepositoryProvider = Provider<MapRepository>(
  (ref) => MockMapRepository(),
);

final mapDataProvider = FutureProvider.autoDispose<MapData>((ref) {
  return ref.watch(mapRepositoryProvider).getMapData();
});