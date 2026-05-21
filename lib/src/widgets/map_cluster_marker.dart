import 'package:flutter/material.dart';

import '../models/place.dart';
import '../theme/app_colors.dart';

class MapClusterMarker extends StatelessWidget {
  const MapClusterMarker({
    super.key,
    required this.places,
    required this.onTap,
  });

  final List<Place> places;
  final VoidCallback onTap;

  int get _toiletCount => places.where((place) => place.type == PlaceType.toilet).length;
  int get _fountainCount => places.length - _toiletCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.30),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.white, width: 3),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${places.length}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
            Text(
              '$_toiletCount 🚻 $_fountainCount 💧',
              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
