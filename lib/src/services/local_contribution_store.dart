import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/review.dart';

class LocalContributionStore {
  static const _pointsKey = 'flowspot.contribution_points';
  static const _reviewsPrefix = 'flowspot.reviews.';

  Future<int> loadPoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_pointsKey) ?? 0;
  }

  Future<int> addPoints(int points) async {
    final prefs = await SharedPreferences.getInstance();
    final total = (prefs.getInt(_pointsKey) ?? 0) + points;
    await prefs.setInt(_pointsKey, total);
    return total;
  }

  Future<List<Review>> loadReviewsForPlace(String placeId) async {
    final prefs = await SharedPreferences.getInstance();
    final rawReviews = prefs.getStringList('$_reviewsPrefix$placeId') ?? const [];

    return rawReviews.map((raw) {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return Review.fromJson(json);
    }).toList();
  }

  Future<void> saveReviewForPlace(String placeId, Review review) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_reviewsPrefix$placeId';
    final rawReviews = prefs.getStringList(key) ?? <String>[];
    rawReviews.insert(0, jsonEncode(review.toJson()));
    await prefs.setStringList(key, rawReviews);
  }
}
