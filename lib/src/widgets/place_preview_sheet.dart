import 'package:flutter/material.dart';

import '../models/place.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class PlacePreviewSheet extends StatelessWidget {
  const PlacePreviewSheet({
    super.key,
    required this.place,
    required this.onOpenDetails,
  });

  final Place place;
  final VoidCallback onOpenDetails;

  Color get _trustColor {
    if (place.trustScore >= 80) return AppColors.trustHigh;
    if (place.trustScore >= 55) return AppColors.trustMedium;
    return AppColors.trustLow;
  }

  String get _trustLabel {
    if (place.trustScore >= 80) return 'Highly reliable';
    if (place.trustScore >= 55) return 'Needs confirmation';
    return 'Low confidence';
  }

  @override
  Widget build(BuildContext context) {
    final icon = place.type == PlaceType.toilet ? Icons.wc : Icons.water_drop;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: _trustColor.withOpacity(0.12),
                  ),
                  child: Icon(icon, color: _trustColor),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(place.name, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.xs),
                      Text('${place.typeLabel} • ${place.distanceLabel} away'),
                      Text(place.address, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: _trustColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _trustColor, width: 5),
                      color: AppColors.surface,
                    ),
                    child: Center(
                      child: Text(
                        '${place.trustScore}%',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: _trustColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_trustLabel, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.xs),
                        Text('Verified ${place.verifiedMinutesAgo}m ago • ${place.reviewCount} reviews'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _PreviewPill(label: place.isOpen ? 'Open now' : 'Closed', color: place.isOpen ? AppColors.trustHigh : AppColors.trustLow),
                _PreviewPill(label: place.isFree ? 'Free' : 'Paid', color: AppColors.secondary),
                if (place.isWheelchairAccessible) const _PreviewPill(label: 'Accessible', color: AppColors.primary),
                if (place.hasBabyChanging) const _PreviewPill(label: 'Baby changing', color: AppColors.primary),
                if (place.isBottleFriendly) const _PreviewPill(label: 'Bottle-friendly', color: AppColors.accent),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
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

class _PreviewPill extends StatelessWidget {
  const _PreviewPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
      ),
    );
  }
}
