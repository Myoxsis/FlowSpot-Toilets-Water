enum PlaceType { toilet, fountain }

class Place {
  const Place({
    required this.id,
    required this.name,
    required this.type,
    required this.distanceMeters,
    required this.address,
    required this.isFree,
    required this.isOpen,
    required this.isWheelchairAccessible,
    required this.cleanlinessScore,
    required this.trustScore,
    required this.verifiedMinutesAgo,
    required this.reviewCount,
    this.hasBabyChanging = false,
    this.isBottleFriendly = false,
  });

  final String id;
  final String name;
  final PlaceType type;
  final int distanceMeters;
  final String address;
  final bool isFree;
  final bool isOpen;
  final bool isWheelchairAccessible;
  final double cleanlinessScore;
  final int trustScore;
  final int verifiedMinutesAgo;
  final int reviewCount;
  final bool hasBabyChanging;
  final bool isBottleFriendly;

  String get typeLabel => type == PlaceType.toilet ? 'Toilet' : 'Fountain';
  String get distanceLabel => distanceMeters < 1000
      ? '${distanceMeters}m'
      : '${(distanceMeters / 1000).toStringAsFixed(1)}km';
}
