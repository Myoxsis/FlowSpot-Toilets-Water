import '../models/place.dart';

class PlaceQualityService {
  const PlaceQualityService();

  int calculateTrustScore(Place place) {
    var score = 40;

    if (place.id.startsWith('idf-')) score += 8;
    if (place.isOpen) score += 15;
    if (place.isFree) score += 5;
    if (place.isWheelchairAccessible) score += 5;
    if (place.hasBabyChanging || place.isBottleFriendly) score += 5;

    score += place.reviewCount.clamp(0, 30);

    if (place.cleanlinessScore >= 4) {
      score += 10;
    } else if (place.cleanlinessScore >= 3) {
      score += 5;
    }

    score += freshnessBonus(place.verifiedMinutesAgo);

    return score.clamp(0, 100);
  }

  int freshnessBonus(int verifiedMinutesAgo) {
    if (verifiedMinutesAgo <= 30) return 18;
    if (verifiedMinutesAgo <= 60) return 15;
    if (verifiedMinutesAgo <= 240) return 8;
    if (verifiedMinutesAgo <= 720) return 0;
    return -10;
  }

  String freshnessLabel(Place place) {
    if (place.verifiedMinutesAgo <= 30) return 'Freshly verified';
    if (place.verifiedMinutesAgo <= 240) return 'Recently verified';
    if (place.verifiedMinutesAgo <= 720) return 'Needs confirmation';
    return 'Possibly stale';
  }

  int compareRecentlyVerified(Place a, Place b) {
    final trustCompare = calculateTrustScore(b).compareTo(calculateTrustScore(a));
    if (trustCompare != 0) return trustCompare;

    final openCompare = _openWeight(b).compareTo(_openWeight(a));
    if (openCompare != 0) return openCompare;

    final verifiedCompare = a.verifiedMinutesAgo.compareTo(b.verifiedMinutesAgo);
    if (verifiedCompare != 0) return verifiedCompare;

    return a.distanceMeters.compareTo(b.distanceMeters);
  }

  int _openWeight(Place place) => place.isOpen ? 1 : 0;

  List<Place> sortRecentlyVerified(List<Place> places) {
    final sorted = [...places];
    sorted.sort(compareRecentlyVerified);
    return sorted;
  }
}
