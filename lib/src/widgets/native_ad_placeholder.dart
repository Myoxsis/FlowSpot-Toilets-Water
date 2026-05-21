import 'package:flutter/material.dart';

class NativeAdPlaceholder extends StatelessWidget {
  const NativeAdPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.ads_click_outlined),
                const SizedBox(width: 8),
                Text('Sponsored nearby utility', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Native ad placements should remain lightweight and relevant to nearby city utility usage.',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: const [
                Chip(label: Text('Cafe nearby')),
                Chip(label: Text('Public transport')),
                Chip(label: Text('Travel utility')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
