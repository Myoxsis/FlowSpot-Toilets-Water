import 'package:latlong2/latlong.dart';

import '../data/sample_data.dart';
import '../models/place.dart';
import '../services/osm_service.dart';

class PlaceRepository {
  PlaceRepository({OsmService? osmService}) : _osmService = osmService ?? OsmService();

  final OsmService _osmService;

  Future<List<Place>> getNearbyPlaces(LatLng center) async {
    try {
      final places = await _osmService.fetchNearbyPlaces(center: center);
      if (places.isEmpty) return samplePlaces;
      return places;
    } catch (_) {
      return samplePlaces;
    }
  }
}
