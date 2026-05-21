import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/place.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'map_cluster_marker.dart';
import 'map_marker.dart';
import 'place_preview_sheet.dart';

class MapPreview extends StatefulWidget {
  const MapPreview({
    super.key,
    required this.center,
    required this.places,
    required this.onPlaceTap,
  });

  final LatLng center;
  final List<Place> places;
  final ValueChanged<Place> onPlaceTap;

  @override
  State<MapPreview> createState() => _MapPreviewState();
}

class _MapPreviewState extends State<MapPreview> {
  double _zoom = 15;
  int? _cachedZoomBucket;
  int? _cachedPlaceCount;
  List<_PlaceCluster> _cachedClusters = const [];

  @override
  void initState() {
    super.initState();
    _rebuildClusterCache();
  }

  @override
  void didUpdateWidget(covariant MapPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.places.length != widget.places.length || oldWidget.places != widget.places) {
      _rebuildClusterCache();
    }
  }

  int get _zoomBucket => (_zoom * 10).round();

  void _rebuildClusterCache() {
    _cachedZoomBucket = _zoomBucket;
    _cachedPlaceCount = widget.places.length;
    _cachedClusters = _buildClusters();
  }

  List<_PlaceCluster> get _clusters {
    if (_cachedZoomBucket != _zoomBucket || _cachedPlaceCount != widget.places.length) {
      _rebuildClusterCache();
    }
    return _cachedClusters;
  }

  List<_PlaceCluster> _buildClusters() {
    if (_zoom >= 16) {
      return widget.places.map((place) => _PlaceCluster([place])).toList();
    }

    final threshold = _zoom >= 14.5 ? 0.0015 : 0.0035;
    final clusters = <_PlaceCluster>[];

    for (final place in widget.places) {
      final point = LatLng(place.latitude, place.longitude);
      _PlaceCluster? match;

      for (final cluster in clusters) {
        if (_distance(cluster.center, point) < threshold) {
          match = cluster;
          break;
        }
      }

      if (match == null) {
        clusters.add(_PlaceCluster([place]));
      } else {
        match.places.add(place);
      }
    }

    return clusters;
  }

  double _distance(LatLng a, LatLng b) {
    final dLat = a.latitude - b.latitude;
    final dLng = a.longitude - b.longitude;
    return sqrt(dLat * dLat + dLng * dLng);
  }

  void _showPlacePreview(BuildContext context, Place place) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => PlacePreviewSheet(
        place: place,
        onOpenDetails: () {
          Navigator.of(context).pop();
          widget.onPlaceTap(place);
        },
      ),
    );
  }

  void _showClusterSheet(BuildContext context, _PlaceCluster cluster) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text('${cluster.places.length} spots nearby', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            ...cluster.places.map(
              (place) => ListTile(
                leading: Icon(place.type == PlaceType.toilet ? Icons.wc : Icons.water_drop),
                title: Text(place.name),
                subtitle: Text('${place.distanceLabel} • Trust ${place.trustScore}%'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showPlacePreview(context, place);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePositionChanged(MapPosition position) {
    final newZoom = position.zoom;
    if (newZoom == null || (newZoom - _zoom).abs() <= 0.1) return;

    setState(() {
      _zoom = newZoom;
      _rebuildClusterCache();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: SizedBox(
        height: 240,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: widget.center,
            initialZoom: _zoom,
            onPositionChanged: (position, _) => _handlePositionChanged(position),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.flowspot.toilets_water',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: widget.center,
                  width: 46,
                  height: 46,
                  child: const CurrentLocationMarker(),
                ),
                ..._clusters.map(
                  (cluster) => Marker(
                    point: cluster.center,
                    width: cluster.places.length == 1 ? 48 : 64,
                    height: cluster.places.length == 1 ? 48 : 64,
                    child: cluster.places.length == 1
                        ? FlowSpotMapMarker(
                            place: cluster.places.first,
                            onTap: () => _showPlacePreview(context, cluster.places.first),
                          )
                        : MapClusterMarker(
                            places: cluster.places,
                            onTap: () => _showClusterSheet(context, cluster),
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

class _PlaceCluster {
  _PlaceCluster(this.places);

  final List<Place> places;

  LatLng get center {
    final lat = places.map((place) => place.latitude).reduce((a, b) => a + b) / places.length;
    final lng = places.map((place) => place.longitude).reduce((a, b) => a + b) / places.length;
    return LatLng(lat, lng);
  }
}
