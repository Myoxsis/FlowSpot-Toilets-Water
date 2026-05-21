import 'package:flutter/material.dart';

import '../models/place.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'pressable_scale.dart';

class PlaceCard extends StatelessWidget {
  const PlaceCard({
    super.key,
    required this.place,
    required this.onTap,
    this.isFavorite = false,
  });

  final Place place;
  final VoidCallback onTap;
  final bool isFavorite;

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

  String get _semanticLabel => '${place.typeLabel} ${place.name}, ${place.distanceLabel} away, ${place.isOpen ? 'open' : 'closed'}, ${place.isFree ? 'free' : 'paid'}, trust ${place.trustScore} percent, $_trustLabel';

  @override
  Widget build(BuildContext context) {
    final icon = place.type == PlaceType.toilet ? Icons.wc : Icons.water_drop;

    return Semantics(
      button: true,
      label: _semanticLabel,
      hint: 'Open place details',
      child: PressableScale(
        onTap: onTap,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                _PlaceIcon(icon: icon, color: _trustColor),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              place.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          if (isFavorite) ...[
                            const SizedBox(width: AppSpacing.sm),
                            const Icon(Icons.favorite, size: 18, color: AppColors.trustLow),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${place.distanceLabel} away • ${place.typeLabel}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: [
                          _StatusPill(
                            label: place.isOpen ? 'Open' : 'Closed',
                            color: place.isOpen ? AppColors.trustHigh : AppColors.trustLow,
                          ),
                          _StatusPill(
                            label: place.isFree ? 'Free' : 'Paid',
                            color: AppColors.secondary,
                          ),
                          _StatusPill(
                            label: 'Verified ${place.verifiedMinutesAgo}m ago',
                            color: _trustColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                _TrustScore(score: place.trustScore, label: _trustLabel, color: _trustColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceIcon extends StatelessWidget {
  const _PlaceIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, color: color),
      ),
    );
  }
}

class _TrustScore extends StatelessWidget {
  const _TrustScore({required this.score, required this.label, required this.color});

  final int score;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 4),
              color: color.withOpacity(0.08),
            ),
            child: Center(
              child: Text(
                '$score%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          SizedBox(
            width: 74,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
        ),
      ),
    );
  }
}
