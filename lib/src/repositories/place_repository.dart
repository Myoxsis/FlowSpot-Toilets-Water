import 'package:latlong2/latlong.dart';

import '../data/sample_data.dart';
import '../models/place.dart';
import '../services/osm_service.dart';
import '../services/place_quality_service.dart';

class PlaceRepository {
  PlaceRepository({
    OsmService? osmService,
    PlaceQualityService qualityService = const PlaceQualityService(),
  })  : _osmService = osmService ?? OsmService(),
        _qualityService = qualityService;

  final OsmService _osmService;
  final PlaceQualityService _qualityService;

  Future<List<Place>> getNearbyPlaces(LatLng center) async {
    try {
      final places = await _osmService.fetchNearbyPlaces(center: center);
      if (places.isEmpty) return _qualityService.sortRecentlyVerified(samplePlaces);
      return _qualityService.sortRecentlyVerified(places);
    } catch (_) {
      return _qualityService.sortRecentlyVerified(samplePlaces);
    }
  }
}
