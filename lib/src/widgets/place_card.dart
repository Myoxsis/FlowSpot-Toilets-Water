import 'package:flutter/material.dart';

import '../models/place.dart';
import '../services/local_contribution_store.dart';
import '../services/navigation_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'pressable_scale.dart';

class PlaceCard extends StatefulWidget {
  const PlaceCard({
    super.key,
    required this.place,
    required this.onTap,
    this.isFavorite = false,
  });

  final Place place;
  final VoidCallback onTap;
  final bool isFavorite;

  @override
  State<PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard> {
  static const _navigationService = NavigationService();
  static final _store = LocalContributionStore();

  String? verificationStatus;

  @override
  void initState() {
    super.initState();
    _loadVerification();
  }

  Future<void> _loadVerification() async {
    final status = await _store.loadVerificationStatus(widget.place.id);
    if (!mounted) return;
    setState(() => verificationStatus = status);
  }

  Future<void> _verify(String status) async {
    await _store.saveVerification(widget.place.id, status);

    if (!mounted) return;

    setState(() => verificationStatus = status);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          status == 'open'
              ? 'Thanks for verifying this place is open.'
              : 'Thanks for reporting this place as closed.',
        ),
      ),
    );
  }

  Color get _trustColor {
    if (widget.place.trustScore >= 80) return AppColors.trustHigh;
    if (widget.place.trustScore >= 55) return AppColors.trustMedium;
    return AppColors.trustLow;
  }

  String get _trustLabel {
    if (widget.place.trustScore >= 80) return 'Highly reliable';
    if (widget.place.trustScore >= 55) return 'Needs confirmation';
    return 'Low confidence';
  }

  bool get _isOfficialSource => widget.place.id.startsWith('idf-');

  String get _semanticLabel => '${widget.place.typeLabel} ${widget.place.name}, ${widget.place.distanceLabel} away, ${widget.place.isOpen ? 'open' : 'closed'}, ${widget.place.isFree ? 'free' : 'paid'}, trust ${widget.place.trustScore} percent, $_trustLabel';

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    final icon = place.type == PlaceType.toilet ? Icons.wc : Icons.water_drop;

    return Semantics(
      button: true,
      label: _semanticLabel,
      hint: 'Open place details',
      child: PressableScale(
        onTap: widget.onTap,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                              if (widget.isFavorite) ...[
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
                                label: place.isOpen ? 'Open now' : 'Likely closed',
                                color: place.isOpen ? AppColors.trustHigh : AppColors.trustLow,
                              ),
                              _StatusPill(
                                label: place.isFree ? 'Free' : 'Paid',
                                color: AppColors.secondary,
                              ),
                              if (place.isWheelchairAccessible)
                                const _StatusPill(
                                  label: 'PMR',
                                  color: AppColors.trustHigh,
                                  icon: Icons.accessible_forward,
                                ),
                              if (place.hasBabyChanging)
                                const _StatusPill(
                                  label: 'Baby',
                                  color: AppColors.primary,
                                  icon: Icons.child_friendly,
                                ),
                              if (_isOfficialSource)
                                const _StatusPill(
                                  label: 'Official source',
                                  color: AppColors.primary,
                                  icon: Icons.verified,
                                ),
                              if (verificationStatus == 'open')
                                const _StatusPill(
                                  label: 'Community verified',
                                  color: AppColors.trustHigh,
                                  icon: Icons.check_circle,
                                ),
                              if (verificationStatus == 'closed')
                                const _StatusPill(
                                  label: 'Reported closed',
                                  color: AppColors.trustLow,
                                  icon: Icons.warning_amber,
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
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: widget.onTap,
                        icon: const Icon(Icons.info_outline),
                        label: const Text('Details'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _navigationService.navigateToPlace(place),
                        icon: const Icon(Icons.navigation),
                        label: const Text('Navigate'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _verify('open'),
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Verify open'),
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _verify('closed'),
                        icon: const Icon(Icons.report_problem_outlined),
                        label: const Text('Report closed'),
                      ),
                    ),
                  ],
                ),
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
  const _StatusPill({required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
