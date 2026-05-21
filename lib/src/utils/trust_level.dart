import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class TrustLevel {
  const TrustLevel._({
    required this.color,
    required this.label,
    required this.semanticLabel,
  });

  final Color color;
  final String label;
  final String semanticLabel;

  static TrustLevel fromScore(int score) {
    if (score >= 80) {
      return const TrustLevel._(
        color: AppColors.trustHigh,
        label: 'Highly reliable',
        semanticLabel: 'highly reliable',
      );
    }

    if (score >= 55) {
      return const TrustLevel._(
        color: AppColors.trustMedium,
        label: 'Needs confirmation',
        semanticLabel: 'needs confirmation',
      );
    }

    return const TrustLevel._(
      color: AppColors.trustLow,
      label: 'Low confidence',
      semanticLabel: 'low confidence',
    );
  }
}
