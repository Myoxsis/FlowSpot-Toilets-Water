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
    this.height = 260,
  });

  final LatLng center;
  final List<Place> places;
  final ValueChanged<Place> onPlaceTap;
  final double height;

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

  int get _zoomBucket => (_zoom * 10).round();

  @override
  void didUpdateWidget(covariant MapPreview oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.places.length != widget.places.length || oldWidget.places != widget.places) {
      _showSearchArea = false;
      _lastSearchCenter = _mapController.camera.center;
      _rebuildClusterCache();
    }
  }

  int get _maxVisibleClusters {
    if (_zoom < 10) return 40;
    if (_zoom < 12) return 80;
    if (_zoom < 14) return 140;
    if (_zoom < 15.5) return 220;
    if (_zoom < 17) return 360;
    return 600;
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

    clusters.sort((a, b) {
      final sizeCompare = b.places.length.compareTo(a.places.length);
      if (sizeCompare != 0) return sizeCompare;

      return _distance(widget.center, a.center).compareTo(_distance(widget.center, b.center));
    });

    return clusters.take(_maxVisibleClusters).toList();
  }

  double get _clusterThreshold {
    if (_zoom < 9) return 0.04;
    if (_zoom < 10.5) return 0.025;
    if (_zoom < 12) return 0.015;
    if (_zoom < 13.5) return 0.008;
    if (_zoom < 15) return 0.004;
    if (_zoom < 16.5) return 0.002;
    return 0.0007;
  }

  double _distance(LatLng a, LatLng b) {
    final dLat = a.latitude - b.latitude;
    final dLng = a.longitude - b.longitude;
    return sqrt(dLat * dLat + dLng * dLng);
  }

  void _zoomBy(double delta) {
    final nextZoom = (_zoom + delta).clamp(8.0, 18.0);
    setState(() {
      _zoom = nextZoom;
      _rebuildClusterCache();
    });
    _mapController.move(_mapController.camera.center, nextZoom);
  }

  void _handleMapMovement(dynamic position) {
    final center = position.center as LatLng?;
    final zoom = position.zoom as double?;

    var needsRebuild = false;

    if (zoom != null && (zoom - _zoom).abs() > 0.1) {
      _zoom = zoom;
      _rebuildClusterCache();
      needsRebuild = true;
    }

    if (center != null && _lastSearchCenter != null) {
      final moved = _distance(center, _lastSearchCenter!);
      if (moved > 0.01 && !_showSearchArea) {
        _showSearchArea = true;
        needsRebuild = true;
      }
    }

    if (needsRebuild) setState(() {});
  }

  void _showPlacePreview(BuildContext context, Place place) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (_) => PlacePreviewSheet(
        place: place,
        onOpenDetails: () {
          Navigator.of(context).pop();
          widget.onPlaceTap(place);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: widget.center,
                initialZoom: _zoom,
                backgroundColor: AppColors.mapLand,
                onPositionChanged: (position, _) => _handleMapMovement(position),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.flowspot.toilets_water',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: widget.center,
                      width: 54,
                      height: 54,
                      child: const CurrentLocationMarker(),
                    ),
                    ..._clusters.map(
                      (cluster) => Marker(
                        point: cluster.center,
                        width: cluster.places.length == 1 ? 52 : 72,
                        height: cluster.places.length == 1 ? 52 : 72,
                        child: cluster.places.length == 1
                            ? FlowSpotMapMarker(
                                place: cluster.places.first,
                                onTap: () => _showPlacePreview(context, cluster.places.first),
                              )
                            : MapClusterMarker(
                                places: cluster.places,
                                onTap: () {},
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.03),
                        Colors.transparent,
                        Colors.black.withOpacity(0.05),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: Column(
                children: [
                  _GlassMapButton(icon: Icons.add, onTap: () => _zoomBy(1)),
                  const SizedBox(height: AppSpacing.sm),
                  _GlassMapButton(icon: Icons.remove, onTap: () => _zoomBy(-1)),
                ],
              ),
            ),
            Positioned(
              left: AppSpacing.md,
              top: AppSpacing.md,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GlassInfoPill(label: '${widget.places.length} civic spots'),
                  const SizedBox(height: AppSpacing.sm),
                  _GlassInfoPill(
                    label: 'Zoom ${_zoom.toStringAsFixed(1)} • ${_clusters.length} clusters',
                  ),
                  if (_showSearchArea) ...[
                    const SizedBox(height: AppSpacing.sm),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
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

class _GlassMapButton extends StatelessWidget {
  const _GlassMapButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.mapControl,
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.14),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: AppColors.primaryDeep),
        ),
      ),
    );
  }
}

class _GlassInfoPill extends StatelessWidget {
  const _GlassInfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.textStrong,
              fontWeight: FontWeight.w700,
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
