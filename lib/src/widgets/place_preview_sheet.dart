import 'package:flutter/material.dart';

import '../models/place.dart';

class PlacePreviewSheet extends StatelessWidget {
  const PlacePreviewSheet({
    super.key,
    required this.place,
    required this.onOpenDetails,
  });

  final Place place;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final icon = place.type == PlaceType.toilet ? Icons.wc : Icons.water_drop;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(child: Icon(icon)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(place.name, style: Theme.of(context).textTheme.titleLarge),
                      Text('${place.typeLabel} • ${place.distanceLabel} • ${place.address}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text(place.isOpen ? 'Open now' : 'Closed')),
                Chip(label: Text(place.isFree ? 'Free' : 'Paid')),
                Chip(label: Text('Trust ${place.trustScore}%')),
                Chip(label: Text('Verified ${place.verifiedMinutesAgo}m ago')),
                if (place.reviewCount > 0) Chip(label: Text('${place.reviewCount} reviews')),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onOpenDetails,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Details'),
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
