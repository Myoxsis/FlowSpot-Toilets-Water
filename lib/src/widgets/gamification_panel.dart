import 'package:flutter/material.dart';

import '../data/sample_data.dart';

class GamificationPanel extends StatelessWidget {
  const GamificationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = userProgress.points / userProgress.nextLevelPoints;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Community progress', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('${userProgress.levelName} • ${userProgress.points} pts'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress.clamp(0, 1)),
            const SizedBox(height: 16),
            Text('Earn points', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: contributionActions
                  .map((action) => Chip(label: Text('${action.icon} ${action.label} +${action.points}')))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text('Badges', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...userProgress.badges.map(
              (badge) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Text(badge.icon, style: const TextStyle(fontSize: 24)),
                title: Text(badge.name),
                subtitle: Text(badge.description),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
