import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/place.dart';
import '../theme/app_colors.dart';
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
  final MapController _mapController = MapController();

  double _zoom = 13;
  bool _showSearchArea = false;
  LatLng? _lastSearchCenter;

  int? _cachedZoomBucket;
  int? _cachedPlaceCount;
  List<_PlaceCluster> _cachedClusters = const [];

  @override
  void initState() {
    super.initState();
    _lastSearchCenter = widget.center;
    _rebuildClusterCache();
  }

  @override
  void didUpdateWidget(covariant MapPreview oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.places.length != widget.places.length || oldWidget.places != widget.places) {
      _showSearchArea = false;
      _lastSearchCenter = _mapController.camera.center;
      _rebuildClusterCache();
    }
  }

  int get _zoomBucket => (_zoom * 10).round();

  int get _maxVisibleClusters {
    if (_zoom < 12) return 80;
    if (_zoom < 14) return 160;
    if (_zoom < 16) return 280;
    return 450;
  }

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
    final threshold = _clusterThreshold;
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

    clusters.sort((a, b) => _distance(widget.center, a.center).compareTo(_distance(widget.center, b.center)));
    return clusters.take(_maxVisibleClusters).toList();
  }

  double get _clusterThreshold {
    if (_zoom < 12) return 0.015;
    if (_zoom < 14) return 0.007;
    if (_zoom < 16) return 0.0025;
    return 0.0008;
  }

  double _distance(LatLng a, LatLng b) {
    final dLat = a.latitude - b.latitude;
    final dLng = a.longitude - b.longitude;
    return sqrt(dLat * dLat + dLng * dLng);
  }

  void _zoomBy(double delta) {
    final nextZoom = (_zoom + delta).clamp(10.0, 18.0);
    setState(() {
      _zoom = nextZoom;
      _rebuildClusterCache();
    });
    _mapController.move(_mapController.camera.center, nextZoom);
  }

  void _handleMapMovement(MapPosition position) {
    final center = position.center;
    final zoom = position.zoom;

    if (zoom != null && (zoom - _zoom).abs() > 0.1) {
      _zoom = zoom;
      _rebuildClusterCache();
    }

    if (center != null && _lastSearchCenter != null) {
      final moved = _distance(center, _lastSearchCenter!);
      if (moved > 0.01) {
        setState(() => _showSearchArea = true);
      }
    }
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
    final visiblePlaces = cluster.places.take(25).toList();

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
            ...visiblePlaces.map(
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
            if (cluster.places.length > visiblePlaces.length)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text('+${cluster.places.length - visiblePlaces.length} more nearby spots'),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: SizedBox(
        height: 260,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: widget.center,
                initialZoom: _zoom,
                onPositionChanged: (position, _) => setState(() => _handleMapMovement(position)),
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
            Positioned(
              right: AppSpacing.sm,
              bottom: AppSpacing.sm,
              child: Column(
                children: [
                  _ZoomButton(icon: Icons.add, onTap: () => _zoomBy(1)),
                  const SizedBox(height: AppSpacing.sm),
                  _ZoomButton(icon: Icons.remove, onTap: () => _zoomBy(-1)),
                ],
              ),
            ),
            Positioned(
              left: AppSpacing.sm,
              top: AppSpacing.sm,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                    child: Text('${widget.places.length} spots loaded'),
                  ),
                  if (_showSearchArea) ...[
                    const SizedBox(height: AppSpacing.sm),
                    FilledButton.icon(
                      onPressed: () {
                        setState(() {
                          _showSearchArea = false;
                          _lastSearchCenter = _mapController.camera.center;
                        });
                      },
                      icon: const Icon(Icons.search, size: 18),
                      label: const Text('Search this area'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface.withOpacity(0.94),
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: AppColors.primary),
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
