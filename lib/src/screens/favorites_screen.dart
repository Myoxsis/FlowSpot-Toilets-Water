import 'package:flutter/material.dart';

import '../models/place.dart';
import '../services/local_contribution_store.dart';
import '../widgets/place_card.dart';
import 'place_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key, required this.places});

  final List<Place> places;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _store = LocalContributionStore();
  Set<String> _favoriteIds = const {};
  bool _isLoading = true;

  List<Place> get _favoritePlaces => widget.places
      .where((place) => _favoriteIds.contains(place.id))
      .toList()
    ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final ids = await _store.loadFavoritePlaceIds();
    if (!mounted) return;
    setState(() {
      _favoriteIds = ids;
      _isLoading = false;
    });
  }

  Future<void> _openPlace(Place place) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PlaceDetailScreen(place: place)),
    );
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = _favoritePlaces;

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: RefreshIndicator(
        onRefresh: _loadFavorites,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Saved spots', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('Favorite toilets and fountains are stored locally on this device.'),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (favorites.isEmpty)
              const _EmptyFavoritesCard()
            else
              ...favorites.map(
                (place) => PlaceCard(
                  place: place,
                  isFavorite: true,
                  onTap: () => _openPlace(place),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFavoritesCard extends StatelessWidget {
  const _EmptyFavoritesCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.favorite_border, size: 40, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text('No favorites yet', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            const Text(
              'Open a toilet or fountain and tap the heart icon to save it here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
