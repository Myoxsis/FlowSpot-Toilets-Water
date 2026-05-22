import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

import '../models/place.dart';

class IdfToiletAssetService {
  const IdfToiletAssetService();

  static const assetPath = 'assets/data/toilettes-publiques-en-ile-de-france.csv';
  final Distance _distance = const Distance();

  Future<List<Place>> fetchNearbyToilets({
    required LatLng center,
    int radiusMeters = 5000,
  }) async {
    final raw = await rootBundle.loadString(assetPath);
    final rows = _parseCsv(raw);

    return rows
        .map((row) => _placeFromRow(row, center))
        .whereType<Place>()
        .where((place) => place.distanceMeters <= radiusMeters)
        .toList()
      ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
  }

  List<Map<String, String>> _parseCsv(String raw) {
    final lines = raw.split(RegExp(r'\r?\n')).where((line) => line.trim().isNotEmpty).toList();
    if (lines.isEmpty) return const [];

    final headers = _splitLine(lines.first);

    return lines.skip(1).map((line) {
      final values = _splitLine(line);
      final row = <String, String>{};

      for (var i = 0; i < headers.length; i++) {
        row[headers[i]] = i < values.length ? values[i] : '';
      }

      return row;
    }).toList();
  }

  List<String> _splitLine(String line) {
    final values = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ';' && !inQuotes) {
        values.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }

    values.add(buffer.toString().trim());
    return values;
  }

  Place? _placeFromRow(Map<String, String> row, LatLng center) {
    final coordinates = _parseCoordinates(row['coord_geo']);
    if (coordinates == null) return null;

    final point = LatLng(coordinates.$1, coordinates.$2);

    return Place(
      id: 'idf-${row['osm_id'] ?? point.latitude}',
      name: row['Type']?.isNotEmpty == true
          ? row['Type']!
          : 'Toilettes publiques',
      type: PlaceType.toilet,
      distanceMeters: _distance.as(LengthUnit.Meter, center, point).round(),
      address: row['Indications de localisation'] ?? '',
      isFree: !(row['Tarif']?.toLowerCase().contains('payant') ?? false),
      isOpen: true,
      isWheelchairAccessible: _parseYes(row['Accessibilite PMR']),
      cleanlinessScore: 0,
      trustScore: 76,
      verifiedMinutesAgo: 240,
      reviewCount: 0,
      latitude: point.latitude,
      longitude: point.longitude,
      hasBabyChanging: _parseYes(row['Relais bébé']),
    );
  }

  (double, double)? _parseCoordinates(String? value) {
    if (value == null || value.isEmpty) return null;

    final parts = value.split(',');
    if (parts.length < 2) return null;

    final lat = double.tryParse(parts[0].trim());
    final lon = double.tryParse(parts[1].trim());

    if (lat == null || lon == null) return null;

    return (lat, lon);
  }

  bool _parseYes(String? value) {
    final normalized = value?.toLowerCase().trim() ?? '';

    return normalized == 'oui' ||
        normalized == 'yes' ||
        normalized == 'true' ||
        normalized == '1';
  }
}
