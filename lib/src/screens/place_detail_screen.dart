import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/place.dart';
import '../models/review.dart';
import '../widgets/ad_placeholder.dart';
import '../widgets/quick_review_sheet.dart';
import '../widgets/review_card.dart';

class PlaceDetailScreen extends StatefulWidget {
  const PlaceDetailScreen({super.key, required this.place});

  final Place place;

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  final List<Review> _reviews = [...sampleReviews];
  int _sessionPoints = 0;

  Place get place => widget.place;

  Future<void> _openQuickReview() async {
    final review = await showModalBottomSheet<Review>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => QuickReviewSheet(place: place),
    );

    if (review == null || !mounted) return;

    setState(() {
      _reviews.insert(0, review);
      _sessionPoints += 5;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thanks! You earned +5 pts. Session total: $_sessionPoints pts'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isToilet = place.type == PlaceType.toilet;

    return Scaffold(
      appBar: AppBar(title: Text(place.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(isToilet ? Icons.wc : Icons.water_drop, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(place.name, style: Theme.of(context).textTheme.headlineSmall),
                    Text('${place.typeLabel} • ${place.distanceLabel} • ${place.address}'),
                    if (_sessionPoints > 0) ...[
                      const SizedBox(height: 6),
                      Text('Session contribution: +$_sessionPoints pts'),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(label: place.isOpen ? 'Open now' : 'Closed', icon: Icons.access_time),
              _InfoChip(label: place.isFree ? 'Free' : 'Paid', icon: Icons.payments_outlined),
              _InfoChip(label: 'Trust ${place.trustScore}%', icon: Icons.verified_outlined),
              _InfoChip(label: '${place.cleanlinessScore}/5 clean', icon: Icons.cleaning_services_outlined),
              if (place.isWheelchairAccessible)
                const _InfoChip(label: 'Accessible', icon: Icons.accessible),
              if (place.hasBabyChanging)
                const _InfoChip(label: 'Baby changing', icon: Icons.child_care),
              if (place.isBottleFriendly)
                const _InfoChip(label: 'Bottle-friendly', icon: Icons.local_drink_outlined),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.navigation_outlined),
            label: const Text('Navigate'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _openQuickReview,
            icon: const Icon(Icons.rate_review_outlined),
            label: const Text('Add quick review +5 pts'),
          ),
          const SizedBox(height: 16),
          const AdPlaceholder(label: 'Banner ad placeholder: after details, never before navigation'),
          const SizedBox(height: 16),
          Text('Recent reviews', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ..._reviews.map((review) => ReviewCard(review: review)),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
