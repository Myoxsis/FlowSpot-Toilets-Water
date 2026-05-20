import 'package:latlong2/latlong.dart';

import '../data/sample_data.dart';
import '../models/place.dart';
import '../services/offline_place_cache.dart';
import '../services/osm_service.dart';
import '../services/place_quality_service.dart';

class PlaceRepository {
  PlaceRepository({
    OsmService? osmService,
    OfflinePlaceCache? cache,
    PlaceQualityService qualityService = const PlaceQualityService(),
  })  : _osmService = osmService ?? OsmService(),
        _cache = cache ?? OfflinePlaceCache(),
        _qualityService = qualityService;

  final OsmService _osmService;
  final OfflinePlaceCache _cache;
  final PlaceQualityService _qualityService;

  Future<List<Place>> getNearbyPlaces(LatLng center) async {
    try {
      final places = await _osmService.fetchNearbyPlaces(center: center);
      if (places.isNotEmpty) {
        final sorted = _qualityService.sortRecentlyVerified(places);
        await _cache.savePlaces(sorted);
        return sorted;
      }
    } catch (_) {
      final cached = await _cache.loadPlaces();
      if (cached.isNotEmpty) return _qualityService.sortRecentlyVerified(cached);
    }

    final cached = await _cache.loadPlaces();
    if (cached.isNotEmpty) return _qualityService.sortRecentlyVerified(cached);

    return _qualityService.sortRecentlyVerified(samplePlaces);
  }
}
