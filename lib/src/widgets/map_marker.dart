import 'package:flutter/material.dart';

import '../models/place.dart';
import '../theme/app_colors.dart';

class FlowSpotMapMarker extends StatelessWidget {
  const FlowSpotMapMarker({
    super.key,
    required this.place,
    required this.onTap,
  });

  final Place place;
  final VoidCallback onTap;

  Color get _markerColor {
    if (place.type == PlaceType.fountain) return AppColors.accent;
    if (place.trustScore >= 80) return AppColors.trustHigh;
    if (place.trustScore >= 55) return AppColors.trustMedium;
    return AppColors.trustLow;
  }

  IconData get _icon => place.type == PlaceType.toilet ? Icons.wc : Icons.water_drop;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _markerColor.withOpacity(0.18),
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _markerColor,
              boxShadow: [
                BoxShadow(
                  color: _markerColor.withOpacity(0.34),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(_icon, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}

class CurrentLocationMarker extends StatelessWidget {
  const CurrentLocationMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withOpacity(0.16),
      ),
      child: Center(
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
            border: Border.all(color: Colors.white, width: 3),
          ),
        ),
      ),
    );
  }
}
