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

  bool get _isOfficial => widget.place.id.startsWith('idf-');

  String get _semanticLabel => '${widget.place.typeLabel} ${widget.place.name}, ${widget.place.distanceLabel} away, trust ${widget.place.trustScore} percent';

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: _semanticLabel,
      hint: 'Open place preview',
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        child: AnimatedScale(
          scale: _isPressed ? 1.14 : 1,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutBack,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: _isPressed ? 54 : 48,
                height: _isPressed ? 54 : 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _markerColor.withOpacity(_isPressed ? 0.26 : 0.14),
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_markerColor.withOpacity(0.92), _markerColor],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _markerColor.withOpacity(0.34),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Icon(_icon, color: Colors.white, size: 19),
              ),
              if (_isOfficial)
                Positioned(
                  right: -2,
                  top: -2,
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
              Positioned(
                bottom: -3,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: _markerColor.withOpacity(0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: _markerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CurrentLocationMarker extends StatelessWidget {
  const CurrentLocationMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Your current location',
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.14),
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.28),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
