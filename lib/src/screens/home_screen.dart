import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../models/place.dart';
import '../repositories/place_repository.dart';
import '../services/local_contribution_store.dart';
import '../services/location_service.dart';
import '../services/place_quality_service.dart';
import '../theme/app_spacing.dart';
import '../widgets/ad_placeholder.dart';
import '../widgets/gamification_panel.dart';
import '../widgets/map_preview.dart';
import '../widgets/place_card.dart';
import '../widgets/skeleton_loader.dart';
import 'favorites_screen.dart';
import 'place_detail_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _locationService = LocationService();
  final _placeRepository = PlaceRepository();
  final _qualityService = const PlaceQualityService();
  final _store = LocalContributionStore();

  PlaceType? selectedType;
  bool freeOnly = false;
  bool paidOnly = false;
  bool babyChangingOnly = false;
  bool accessibleOnly = false;
  LatLng? center;
  List<Place> places = const [];
  Set<String> favoriteIds = const {};
  bool isLoading = true;
  String? statusMessage;

  bool get hasAdvancedFilters => freeOnly || paidOnly || babyChangingOnly || accessibleOnly;

  List<Place> get visiblePlaces {
    Iterable<Place> filtered = places;

    if (selectedType != null) {
      filtered = filtered.where((place) => place.type == selectedType);
    }
    if (freeOnly && !paidOnly) {
      filtered = filtered.where((place) => place.isFree);
    }
    if (paidOnly && !freeOnly) {
      filtered = filtered.where((place) => !place.isFree);
    }
    if (babyChangingOnly) {
      filtered = filtered.where((place) => place.hasBabyChanging);
    }
    if (accessibleOnly) {
      filtered = filtered.where((place) => place.isWheelchairAccessible);
    }

    return _qualityService.sortRecentlyVerified(filtered.toList());
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNearbyPlaces());
  }

  Future<void> _loadNearbyPlaces() async {
    setState(() {
      isLoading = true;
      statusMessage = null;
    });

    try {
      final currentCenter = await _locationService.getCurrentLocationOrFallback();
      final nearbyPlaces = await _placeRepository.getNearbyPlaces(currentCenter);
      final favorites = await _store.loadFavoritePlaceIds();

      if (!mounted) return;
      setState(() {
        center = currentCenter;
        places = nearbyPlaces;
        favoriteIds = favorites;
        isLoading = false;
        statusMessage = nearbyPlaces.isEmpty ? 'No nearby spots found yet.' : null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        center = LocationService.parisFallback;
        places = const [];
        favoriteIds = const {};
        isLoading = false;
        statusMessage = 'Could not load nearby spots. Pull to retry.';
      });
    }
  }

  void _clearAdvancedFilters() {
    setState(() {
      freeOnly = false;
      paidOnly = false;
      babyChangingOnly = false;
      accessibleOnly = false;
    });
  }

  Future<void> _refreshFavorites() async {
    final favorites = await _store.loadFavoritePlaceIds();
    if (!mounted) return;
    setState(() => favoriteIds = favorites);
  }

  Future<void> _openPlace(Place place) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PlaceDetailScreen(place: place)),
    );
    await _refreshFavorites();
  }

  Future<void> _openFavorites() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => FavoritesScreen(places: places)),
    );
    await _refreshFavorites();
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentCenter = center ?? LocationService.parisFallback;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FlowSpot'),
        actions: [
          IconButton(
            tooltip: 'Contributor profile',
            onPressed: _openProfile,
            icon: const Icon(Icons.person_outline),
          ),
          IconButton(
            tooltip: 'Favorites',
            onPressed: _openFavorites,
            icon: const Icon(Icons.favorite_border),
          ),
          IconButton(
            tooltip: 'Refresh nearby spots',
            onPressed: _loadNearbyPlaces,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Add spot',
            onPressed: () {},
            icon: const Icon(Icons.add_location_alt_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNearbyPlaces,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            if (isLoading)
              const MapSkeleton()
            else
              MapPreview(
                center: currentCenter,
                places: visiblePlaces,
                onPlaceTap: _openPlace,
              ),
            const SizedBox(height: AppSpacing.md),
            _FilterChips(
              selectedType: selectedType,
              onChanged: (type) => setState(() => selectedType = type),
            ),
            const SizedBox(height: AppSpacing.sm),
            _AdvancedFilterChips(
              freeOnly: freeOnly,
              paidOnly: paidOnly,
              babyChangingOnly: babyChangingOnly,
              accessibleOnly: accessibleOnly,
              hasFilters: hasAdvancedFilters,
              onFreeChanged: (value) => setState(() => freeOnly = value),
              onPaidChanged: (value) => setState(() => paidOnly = value),
              onBabyChanged: (value) => setState(() => babyChangingOnly = value),
              onAccessibleChanged: (value) => setState(() => accessibleOnly = value),
              onClear: _clearAdvancedFilters,
            ),
            const SizedBox(height: AppSpacing.md),
            const AdPlaceholder(label: 'Native ad placeholder: nearby city utility'),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Text('Recently verified', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                if (!isLoading) Text('${visiblePlaces.length} / ${places.length} found'),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text('Top trusted and freshest nearby spots.'),
            const SizedBox(height: AppSpacing.sm),
            if (isLoading)
              const Column(
                children: [
                  PlaceCardSkeleton(),
                  PlaceCardSkeleton(),
                  PlaceCardSkeleton(),
                ],
              )
            else if (statusMessage != null)
              _StatusCard(message: statusMessage!, onRetry: _loadNearbyPlaces, actionLabel: 'Try again')
            else if (visiblePlaces.isEmpty)
              _StatusCard(message: 'No spots match these filters.', onRetry: _clearAdvancedFilters, actionLabel: 'Clear filters')
            else
              ...visiblePlaces.take(5).map(
                (place) => PlaceCard(
                  place: place,
                  isFavorite: favoriteIds.contains(place.id),
                  onTap: () => _openPlace(place),
                ),
              ),
            if (!isLoading && visiblePlaces.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text('+${visiblePlaces.length - 5} more spots available on the map explorer'),
              ),
            const SizedBox(height: AppSpacing.md),
            const GamificationPanel(),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.message, required this.onRetry, required this.actionLabel});

  final String message;
  final VoidCallback onRetry;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            const Icon(Icons.info_outline),
            const SizedBox(height: AppSpacing.sm),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selectedType, required this.onChanged});

  final PlaceType? selectedType;
  final ValueChanged<PlaceType?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        ChoiceChip(
          label: const Text('All'),
          selected: selectedType == null,
          onSelected: (_) => onChanged(null),
        ),
        ChoiceChip(
          label: const Text('Toilets'),
          avatar: const Icon(Icons.wc, size: 18),
          selected: selectedType == PlaceType.toilet,
          onSelected: (_) => onChanged(PlaceType.toilet),
        ),
        ChoiceChip(
          label: const Text('Fountains'),
          avatar: const Icon(Icons.water_drop, size: 18),
          selected: selectedType == PlaceType.fountain,
          onSelected: (_) => onChanged(PlaceType.fountain),
        ),
      ],
    );
  }
}

class _AdvancedFilterChips extends StatelessWidget {
  const _AdvancedFilterChips({
    required this.freeOnly,
    required this.paidOnly,
    required this.babyChangingOnly,
    required this.accessibleOnly,
    required this.hasFilters,
    required this.onFreeChanged,
    required this.onPaidChanged,
    required this.onBabyChanged,
    required this.onAccessibleChanged,
    required this.onClear,
  });

  final bool freeOnly;
  final bool paidOnly;
  final bool babyChangingOnly;
  final bool accessibleOnly;
  final bool hasFilters;
  final ValueChanged<bool> onFreeChanged;
  final ValueChanged<bool> onPaidChanged;
  final ValueChanged<bool> onBabyChanged;
  final ValueChanged<bool> onAccessibleChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        FilterChip(
          label: const Text('Free'),
          avatar: const Icon(Icons.euro, size: 18),
          selected: freeOnly,
          onSelected: onFreeChanged,
        ),
        FilterChip(
          label: const Text('Paid'),
          avatar: const Icon(Icons.payments_outlined, size: 18),
          selected: paidOnly,
          onSelected: onPaidChanged,
        ),
        FilterChip(
          label: const Text('Baby'),
          avatar: const Icon(Icons.child_friendly, size: 18),
          selected: babyChangingOnly,
          onSelected: onBabyChanged,
        ),
        FilterChip(
          label: const Text('PMR'),
          avatar: const Icon(Icons.accessible_forward, size: 18),
          selected: accessibleOnly,
          onSelected: onAccessibleChanged,
        ),
        if (hasFilters)
          ActionChip(
            label: const Text('Clear'),
            avatar: const Icon(Icons.close, size: 18),
            onPressed: onClear,
          ),
      ],
    );
  }
}
