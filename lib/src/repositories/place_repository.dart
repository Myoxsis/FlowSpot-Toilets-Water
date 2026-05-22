import 'package:latlong2/latlong.dart';

import '../data/sample_data.dart';
import '../models/place.dart';
import '../services/idf_toilet_asset_service.dart';
import '../services/offline_place_cache.dart';
import '../services/osm_service.dart';
import '../services/place_quality_service.dart';

class PlaceRepository {
  PlaceRepository({
    OsmService? osmService,
    IdfToiletAssetService? idfToiletAssetService,
    OfflinePlaceCache? cache,
    PlaceQualityService qualityService = const PlaceQualityService(),
  })  : _osmService = osmService ?? OsmService(),
        _idfToiletAssetService = idfToiletAssetService ?? const IdfToiletAssetService(),
        _cache = cache ?? OfflinePlaceCache(),
        _qualityService = qualityService;

  final OsmService _osmService;
  final IdfToiletAssetService _idfToiletAssetService;
  final OfflinePlaceCache _cache;
  final PlaceQualityService _qualityService;

  Future<List<Place>> getNearbyPlaces(LatLng center) async {
    try {
      final osmPlaces = await _osmService.fetchNearbyPlaces(center: center);
      final officialPlaces = await _idfToiletAssetService.fetchNearbyToilets(center: center);

      final merged = [...osmPlaces, ...officialPlaces];

      if (merged.isNotEmpty) {
        final sorted = _qualityService.sortRecentlyVerified(merged);
        await _cache.savePlaces(sorted);
        return sorted;
      }
    } catch (_) {
      final cached = await _cache.loadPlaces();
      if (cached.isNotEmpty) {
        return _qualityService.sortRecentlyVerified(cached);
      }
    }

    final cached = await _cache.loadPlaces();
    if (cached.isNotEmpty) {
      return _qualityService.sortRecentlyVerified(cached);
    }

    return _qualityService.sortRecentlyVerified(samplePlaces);
  }
}
