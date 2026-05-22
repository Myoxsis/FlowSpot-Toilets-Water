import 'package:flutter/foundation.dart';
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
    final osmPlaces = await _safeLoad(
      label: 'OSM',
      loader: () => _osmService.fetchNearbyPlaces(center: center),
    );

    final officialPlaces = await _safeLoad(
      label: 'IDF CSV',
      loader: () => _idfToiletAssetService.fetchNearbyToilets(center: center),
    );

    final merged = _deduplicate([...officialPlaces, ...osmPlaces]);
    debugPrint('FlowSpot places loaded: official=${officialPlaces.length}, osm=${osmPlaces.length}, merged=${merged.length}');

    if (merged.isNotEmpty) {
      final sorted = _qualityService.sortRecentlyVerified(merged);
      await _cache.savePlaces(sorted);
      return sorted;
    }

    final cached = await _cache.loadPlaces();
    if (cached.isNotEmpty) {
      return _qualityService.sortRecentlyVerified(cached);
    }

    return _qualityService.sortRecentlyVerified(samplePlaces);
  }

  Future<List<Place>> _safeLoad({
    required String label,
    required Future<List<Place>> Function() loader,
  }) async {
    try {
      return await loader();
    } catch (error, stackTrace) {
      debugPrint('FlowSpot $label load failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return const [];
    }
  }

  List<Place> _deduplicate(List<Place> places) {
    final deduped = <Place>[];
    const distance = Distance();

    for (final place in places) {
      final point = LatLng(place.latitude, place.longitude);
      final alreadyExists = deduped.any((existing) {
        final existingPoint = LatLng(existing.latitude, existing.longitude);
        return distance.as(LengthUnit.Meter, point, existingPoint) < 25;
      });

      if (!alreadyExists) {
        deduped.add(place);
      }
    }

    return deduped;
  }
}
