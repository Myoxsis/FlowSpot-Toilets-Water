import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/place.dart';

class OsmService {
  OsmService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final Distance _distance = const Distance();

  Future<List<Place>> fetchNearbyPlaces({
    required LatLng center,
    int radiusMeters = 1200,
  }) async {
    final query = '''
[out:json][timeout:12];
(
  node["amenity"="toilets"](around:$radiusMeters,${center.latitude},${center.longitude});
  way["amenity"="toilets"](around:$radiusMeters,${center.latitude},${center.longitude});
  relation["amenity"="toilets"](around:$radiusMeters,${center.latitude},${center.longitude});
  node["amenity"="drinking_water"](around:$radiusMeters,${center.latitude},${center.longitude});
  way["amenity"="drinking_water"](around:$radiusMeters,${center.latitude},${center.longitude});
  relation["amenity"="drinking_water"](around:$radiusMeters,${center.latitude},${center.longitude});
);
out center tags;
''';

    final response = await _client.post(
      Uri.parse('https://overpass-api.de/api/interpreter'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'data': query},
    );

    if (response.statusCode != 200) {
      throw Exception('Overpass failed with status ${response.statusCode}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final elements = payload['elements'] as List<dynamic>? ?? [];

    return elements.map((raw) => _placeFromOsm(raw as Map<String, dynamic>, center)).toList()
      ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
  }

  Place _placeFromOsm(Map<String, dynamic> element, LatLng center) {
    final tags = (element['tags'] as Map<String, dynamic>?) ?? {};
    final lat = (element['lat'] ?? element['center']?['lat'] ?? center.latitude) as num;
    final lon = (element['lon'] ?? element['center']?['lon'] ?? center.longitude) as num;
    final amenity = tags['amenity']?.toString();
    final type = amenity == 'drinking_water' ? PlaceType.fountain : PlaceType.toilet;
    final name = tags['name']?.toString().trim().isNotEmpty == true
        ? tags['name'].toString()
        : type == PlaceType.toilet
            ? 'Public toilet'
            : 'Drinking fountain';
    final point = LatLng(lat.toDouble(), lon.toDouble());

    return Place(
      id: '${element['type']}-${element['id']}',
      name: name,
      type: type,
      distanceMeters: _distance.as(LengthUnit.Meter, center, point).round(),
      address: tags['operator']?.toString() ?? tags['description']?.toString() ?? 'OpenStreetMap spot',
      isFree: tags['fee']?.toString() != 'yes',
      isOpen: true,
      isWheelchairAccessible: tags['wheelchair']?.toString() == 'yes',
      cleanlinessScore: 0,
      trustScore: 50,
      verifiedMinutesAgo: 999,
      reviewCount: 0,
      latitude: point.latitude,
      longitude: point.longitude,
      hasBabyChanging: tags['changing_table']?.toString() == 'yes',
      isBottleFriendly: type == PlaceType.fountain,
    );
  }
}
