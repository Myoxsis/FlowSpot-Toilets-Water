import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/place.dart';
import '../widgets/ad_placeholder.dart';
import '../widgets/gamification_panel.dart';
import '../widgets/place_card.dart';
import 'place_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PlaceType? selectedType;

  List<Place> get visiblePlaces => selectedType == null
      ? samplePlaces
      : samplePlaces.where((place) => place.type == selectedType).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlowSpot'),
        actions: [
          IconButton(
            tooltip: 'Add spot',
            onPressed: () {},
            icon: const Icon(Icons.add_location_alt_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeroMapPlaceholder(selectedType: selectedType),
          const SizedBox(height: 12),
          _FilterChips(
            selectedType: selectedType,
            onChanged: (type) => setState(() => selectedType = type),
          ),
          const SizedBox(height: 12),
          const AdPlaceholder(label: 'Native ad placeholder: nearby city utility'),
          const SizedBox(height: 16),
          Text('Nearby spots', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...visiblePlaces.map(
            (place) => PlaceCard(
              place: place,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PlaceDetailScreen(place: place),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const GamificationPanel(),
        ],
      ),
    );
  }
}

class _HeroMapPlaceholder extends StatelessWidget {
  const _HeroMapPlaceholder({required this.selectedType});

  final PlaceType? selectedType;

  @override
  Widget build(BuildContext context) {
    final label = selectedType == null
        ? 'Toilets + fountains near you'
        : selectedType == PlaceType.toilet
            ? 'Public toilets near you'
            : 'Drinking fountains near you';

    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE0F7F4), Color(0xFFDDF0FF)],
        ),
      ),
      child: Stack(
        children: [
          const Positioned(top: 36, left: 42, child: _MapPin(icon: Icons.wc)),
          const Positioned(bottom: 48, right: 52, child: _MapPin(icon: Icons.water_drop)),
          const Positioned(top: 84, right: 112, child: _MapPin(icon: Icons.wc)),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.map_outlined, size: 40),
                const SizedBox(height: 8),
                Text(label, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                const Text('Real map integration comes next'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Icon(icon, color: Colors.white),
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
      spacing: 8,
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
