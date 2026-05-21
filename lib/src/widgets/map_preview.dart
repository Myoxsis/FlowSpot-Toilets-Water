import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/place.dart';
import '../theme/app_radius.dart';
import 'map_marker.dart';
import 'place_preview_sheet.dart';

class MapPreview extends StatelessWidget {
  const MapPreview({
    super.key,
    required this.center,
    required this.places,
    required this.onPlaceTap,
  });

  final LatLng center;
  final List<Place> places;
  final ValueChanged<Place> onPlaceTap;

  void _showPlacePreview(BuildContext context, Place place) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => PlacePreviewSheet(
        place: place,
        onOpenDetails: () {
          Navigator.of(context).pop();
          onPlaceTap(place);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: SizedBox(
        height: 240,
        child: FlutterMap(
          options: MapOptions(initialCenter: center, initialZoom: 15),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.flowspot.toilets_water',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: center,
                  width: 46,
                  height: 46,
                  child: const CurrentLocationMarker(),
                ),
                ...places.map(
                  (place) => Marker(
                    point: LatLng(place.latitude, place.longitude),
                    width: 48,
                    height: 48,
                    child: FlowSpotMapMarker(
                      place: place,
                      onTap: () => _showPlacePreview(context, place),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
