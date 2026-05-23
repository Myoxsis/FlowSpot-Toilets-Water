import 'dart:math';

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
  int get _officialCount => places.where((place) => place.id.startsWith('idf-')).length;

  double get _size {
    if (places.length >= 150) return 72;
    if (places.length >= 60) return 66;
    if (places.length >= 20) return 60;
    return 54;
  }

  double get _glow => min(0.34, 0.16 + places.length / 600);

  @override
  Widget build(BuildContext context) {
    final size = _size;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.86, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.14),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: size - 8,
                height: size - 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.accent, AppColors.primaryDeep],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(_glow),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Text(
                        '${places.length}',
                        key: ValueKey(places.length),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              if (_officialCount > 0)
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.official,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.verified, size: 10, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String get _subtitle {
    if (_toiletCount > 0 && _fountainCount > 0) return 'WC · Water';
    if (_toiletCount > 0) return 'WC';
    return 'Water';
  }
}
