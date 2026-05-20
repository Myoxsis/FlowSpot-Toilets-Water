import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/place.dart';

class OfflinePlaceCache {
  static const placesKey = 'flowspot.cached_places';

  Future<void> savePlaces(List<Place> places) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = places.map((place) => jsonEncode(place.toJson())).toList();
    await prefs.setStringList(placesKey, payload);
  }

  Future<List<Place>> loadPlaces() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = prefs.getStringList(placesKey) ?? const [];

    return payload.map((raw) {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return Place.fromJson(json);
    }).toList();
  }
}
