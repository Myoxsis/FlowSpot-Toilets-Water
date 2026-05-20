import 'package:flutter/material.dart';

import '../models/place.dart';

class PlaceCard extends StatelessWidget {
  const PlaceCard({super.key, required this.place, required this.onTap});

  final Place place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = place.type == PlaceType.toilet ? Icons.wc : Icons.water_drop;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(place.name),
        subtitle: Text(
          '${place.distanceLabel} • ${place.isOpen ? 'Open' : 'Closed'} • ${place.isFree ? 'Free' : 'Paid'} • verified ${place.verifiedMinutesAgo}m ago',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_outlined, size: 18),
            Text('${place.trustScore}%'),
          ],
        ),
      ),
    );
  }
}
