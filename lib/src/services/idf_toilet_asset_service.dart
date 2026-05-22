import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

import '../models/place.dart';

class IdfToiletAssetService {
  const IdfToiletAssetService();

  static const assetPath = 'assets/data/toilettes-publiques-en-ile-de-france.csv';
  final Distance _distance = const Distance();

  Future<List<Place>> fetchNearbyToilets({
    required LatLng center,
    int radiusMeters = 15000,
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
    final cleanRaw = raw.replaceFirst('\uFEFF', '');
    final lines = cleanRaw.split(RegExp(r'\r?\n')).where((line) => line.trim().isNotEmpty).toList();
    if (lines.isEmpty) return const [];

    final headers = _splitLine(lines.first).map(_cleanCell).toList();

    return lines.skip(1).map((line) {
      final values = _splitLine(line).map(_cleanCell).toList();
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
        values.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }

    values.add(buffer.toString());
    return values;
  }

  Place? _placeFromRow(Map<String, String> row, LatLng center) {
    final coordinates = _parseCoordinates(row['coord_geo']);
    if (coordinates == null) return null;

    final point = LatLng(coordinates.$1, coordinates.$2);
    final osmId = row['osm_id'];
    final city = row['nom_de_la_commune'];
    final department = row['nom_departement'];
    final source = row['Source']?.isNotEmpty == true ? row['Source']! : 'Ile-de-France open data';
    final location = row['Indications de localisation'];
    final openingHours = row["Horaires d'ouverture"];

    return Place(
      id: 'idf-${osmId?.isNotEmpty == true ? osmId : '${point.latitude.toStringAsFixed(6)}-${point.longitude.toStringAsFixed(6)}'}',
      name: row['Type']?.isNotEmpty == true ? row['Type']! : 'Toilettes publiques',
      type: PlaceType.toilet,
      distanceMeters: _distance.as(LengthUnit.Meter, center, point).round(),
      address: _address(location: location, city: city, department: department, openingHours: openingHours, source: source),
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

  String _address({String? location, String? city, String? department, String? openingHours, required String source}) {
    return [
      if (location != null && location.isNotEmpty) location,
      if (city != null && city.isNotEmpty) city,
      if (department != null && department.isNotEmpty) department,
      if (openingHours != null && openingHours.isNotEmpty) openingHours,
      source,
    ].join(' • ');
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

  String _cleanCell(String value) => value.replaceFirst('\uFEFF', '').trim();

  bool _parseYes(String? value) {
    final normalized = value?.toLowerCase().trim() ?? '';

    return normalized == 'oui' || normalized == 'yes' || normalized == 'true' || normalized == '1';
  }
}
