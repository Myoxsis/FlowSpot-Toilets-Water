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
    this.latitude = 48.8566,
    this.longitude = 2.3522,
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
  final double latitude;
  final double longitude;
  final bool hasBabyChanging;
  final bool isBottleFriendly;

  String get typeLabel => type == PlaceType.toilet ? 'Toilet' : 'Fountain';
  String get distanceLabel => distanceMeters < 1000
      ? '${distanceMeters}m'
      : '${(distanceMeters / 1000).toStringAsFixed(1)}km';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'distanceMeters': distanceMeters,
        'address': address,
        'isFree': isFree,
        'isOpen': isOpen,
        'isWheelchairAccessible': isWheelchairAccessible,
        'cleanlinessScore': cleanlinessScore,
        'trustScore': trustScore,
        'verifiedMinutesAgo': verifiedMinutesAgo,
        'reviewCount': reviewCount,
        'latitude': latitude,
        'longitude': longitude,
        'hasBabyChanging': hasBabyChanging,
        'isBottleFriendly': isBottleFriendly,
      };

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as String? ?? 'unknown',
      name: json['name'] as String? ?? 'Public spot',
      type: json['type'] == 'fountain' ? PlaceType.fountain : PlaceType.toilet,
      distanceMeters: json['distanceMeters'] as int? ?? 0,
      address: json['address'] as String? ?? 'Cached spot',
      isFree: json['isFree'] as bool? ?? true,
      isOpen: json['isOpen'] as bool? ?? true,
      isWheelchairAccessible: json['isWheelchairAccessible'] as bool? ?? false,
      cleanlinessScore: (json['cleanlinessScore'] as num?)?.toDouble() ?? 0,
      trustScore: json['trustScore'] as int? ?? 50,
      verifiedMinutesAgo: json['verifiedMinutesAgo'] as int? ?? 999,
      reviewCount: json['reviewCount'] as int? ?? 0,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 48.8566,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 2.3522,
      hasBabyChanging: json['hasBabyChanging'] as bool? ?? false,
      isBottleFriendly: json['isBottleFriendly'] as bool? ?? false,
    );
  }
}
