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
  LatLng? center;
  List<Place> places = const [];
  Set<String> favoriteIds = const {};
  bool isLoading = true;
  String? statusMessage;

  List<Place> get visiblePlaces {
    final filtered = selectedType == null
        ? places
        : places.where((place) => place.type == selectedType).toList();
    return _qualityService.sortRecentlyVerified(filtered);
  }

  @override
  void initState() {
    super.initState();
    _loadNearbyPlaces();
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
            const SizedBox(height: AppSpacing.md),
            const AdPlaceholder(label: 'Native ad placeholder: nearby city utility'),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Text('Recently verified', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                if (!isLoading) Text('${visiblePlaces.length} found'),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text('Sorted by trust, recent verification, then distance.'),
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
              _StatusCard(message: statusMessage!, onRetry: _loadNearbyPlaces)
            else
              ...visiblePlaces.map(
                (place) => PlaceCard(
                  place: place,
                  isFavorite: favoriteIds.contains(place.id),
                  onTap: () => _openPlace(place),
                ),
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
  const _StatusCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

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
              label: const Text('Try again'),
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
