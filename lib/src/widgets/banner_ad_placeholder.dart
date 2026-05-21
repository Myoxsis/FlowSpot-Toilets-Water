import 'package:flutter/material.dart';

class BannerAdPlaceholder extends StatelessWidget {
  const BannerAdPlaceholder({
    super.key,
    this.label = 'AdMob banner placeholder',
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Center(
        child: Text(label),
      ),
    );
  }
}
