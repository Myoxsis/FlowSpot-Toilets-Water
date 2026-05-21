import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../data/sample_leaderboard.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../widgets/gamification_panel.dart';
import '../widgets/leaderboard_panel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contributor profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const _ProfileHero(),
          const SizedBox(height: AppSpacing.md),
          const _StatsGrid(),
          const SizedBox(height: AppSpacing.md),
          const GamificationPanel(),
          const SizedBox(height: AppSpacing.md),
          LeaderboardPanel(currentUserPoints: userProgress.points),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero();

  @override
  Widget build(BuildContext context) {
    final rankPreview = sampleLeaderboard.length + 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.12),
              ),
              child: const Icon(Icons.person_outline, size: 34, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('You', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Text(userProgress.levelName, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary)),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Rank preview #$rankPreview • ${userProgress.points} pts', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _StatCard(label: 'Reviews', value: '12', icon: Icons.rate_review_outlined)),
        SizedBox(width: AppSpacing.sm),
        Expanded(child: _StatCard(label: 'Badges', value: '3', icon: Icons.workspace_premium_outlined)),
        SizedBox(width: AppSpacing.sm),
        Expanded(child: _StatCard(label: 'Verifies', value: '28', icon: Icons.verified_outlined)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
