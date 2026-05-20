class Badge {
  const Badge({required this.name, required this.description, required this.icon});

  final String name;
  final String description;
  final String icon;
}

class ContributionAction {
  const ContributionAction({required this.label, required this.points, required this.icon});

  final String label;
  final int points;
  final String icon;
}

class UserProgress {
  const UserProgress({
    required this.points,
    required this.levelName,
    required this.nextLevelPoints,
    required this.badges,
  });

  final int points;
  final String levelName;
  final int nextLevelPoints;
  final List<Badge> badges;
}
