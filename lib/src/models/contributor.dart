class Contributor {
  const Contributor({
    required this.name,
    required this.points,
    required this.badge,
    required this.rank,
    this.isCurrentUser = false,
  });

  final String name;
  final int points;
  final String badge;
  final int rank;
  final bool isCurrentUser;
}
