import 'package:flutter/material.dart';

import '../models/place.dart';
import '../theme/app_colors.dart';

class FlowSpotMapMarker extends StatefulWidget {
  const FlowSpotMapMarker({
    super.key,
    required this.place,
    required this.onTap,
  });

  final Place place;
  final VoidCallback onTap;

  @override
  State<FlowSpotMapMarker> createState() => _FlowSpotMapMarkerState();
}

class _FlowSpotMapMarkerState extends State<FlowSpotMapMarker> {
  bool _isPressed = false;

  Color get _markerColor {
    if (widget.place.type == PlaceType.fountain) return AppColors.accent;
    if (widget.place.trustScore >= 80) return AppColors.trustHigh;
    if (widget.place.trustScore >= 55) return AppColors.trustMedium;
    return AppColors.trustLow;
  }

  IconData get _icon => widget.place.type == PlaceType.toilet ? Icons.wc : Icons.water_drop;

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _isPressed ? 1.12 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutBack,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              width: _isPressed ? 50 : 46,
              height: _isPressed ? 50 : 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _markerColor.withOpacity(_isPressed ? 0.26 : 0.18),
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
