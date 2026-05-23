import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../models/place.dart';
import '../theme/app_spacing.dart';
import '../widgets/map_preview.dart';
import 'place_detail_screen.dart';

class MapExplorerScreen extends StatelessWidget {
  const MapExplorerScreen({
    super.key,
    required this.center,
    required this.places,
  });

  final LatLng center;
  final List<Place> places;

  Future<void> _openPlace(BuildContext context, Place place) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PlaceDetailScreen(place: place)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore map'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Center(child: Text('${places.length} spots')),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: MapPreview(
            center: center,
            places: places,
            height: double.infinity,
            onPlaceTap: (place) => _openPlace(context, place),
          ),
        ),
      ),
    );
  }
}
