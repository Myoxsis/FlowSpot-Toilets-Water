import 'package:flutter/material.dart';

import '../data/sample_leaderboard.dart';
import '../models/contributor.dart';

class LeaderboardPanel extends StatelessWidget {
  const LeaderboardPanel({
    super.key,
    required this.currentUserPoints,
  });

  final int currentUserPoints;

  List<Contributor> get leaderboard {
    final entries = [...sampleLeaderboard];

    entries.add(
      Contributor(
        name: 'You',
        points: currentUserPoints,
        badge: currentUserPoints >= 100 ? 'Trusted Scout' : 'New Contributor',
        rank: entries.length + 1,
        isCurrentUser: true,
      ),
    );

    entries.sort((a, b) => b.points.compareTo(a.points));

    return entries.asMap().entries.map((entry) {
      final contributor = entry.value;
      return Contributor(
        name: contributor.name,
        points: contributor.points,
        badge: contributor.badge,
        rank: entry.key + 1,
        isCurrentUser: contributor.isCurrentUser,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = leaderboard.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.leaderboard_outlined),
                const SizedBox(width: 8),
                Text('Top contributors', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map(
              (contributor) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: contributor.isCurrentUser
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: Row(
                  children: [
                    CircleAvatar(child: Text('#${contributor.rank}')),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(contributor.name),
                          Text(contributor.badge),
                        ],
                      ),
                    ),
                    Text('${contributor.points} pts'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
