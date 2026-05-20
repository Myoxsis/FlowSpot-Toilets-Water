import '../models/place.dart';

class PlaceQualityService {
  const PlaceQualityService();

  int calculateTrustScore(Place place) {
    var score = 40;

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

    if (place.verifiedMinutesAgo <= 60) {
      score += 15;
    } else if (place.verifiedMinutesAgo <= 240) {
      score += 8;
    } else if (place.verifiedMinutesAgo > 720) {
      score -= 10;
    }

    return score.clamp(0, 100);
  }

  int compareRecentlyVerified(Place a, Place b) {
    final trustCompare = b.trustScore.compareTo(a.trustScore);
    if (trustCompare != 0) return trustCompare;

    final verifiedCompare = a.verifiedMinutesAgo.compareTo(b.verifiedMinutesAgo);
    if (verifiedCompare != 0) return verifiedCompare;

    return a.distanceMeters.compareTo(b.distanceMeters);
  }

  List<Place> sortRecentlyVerified(List<Place> places) {
    final sorted = [...places];
    sorted.sort(compareRecentlyVerified);
    return sorted;
  }
}
