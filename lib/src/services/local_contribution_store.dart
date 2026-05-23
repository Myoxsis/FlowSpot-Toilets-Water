import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/review.dart';

class LocalContributionStore {
  static const _pointsKey = 'flowspot.contribution_points';
  static const _favoritesKey = 'flowspot.favorite_place_ids';
  static const _reviewsPrefix = 'flowspot.reviews.';
  static const _verificationPrefix = 'flowspot.verification.';

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

  Future<Set<String>> loadFavoritePlaceIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_favoritesKey) ?? const []).toSet();
  }

  Future<bool> isFavorite(String placeId) async {
    final favorites = await loadFavoritePlaceIds();
    return favorites.contains(placeId);
  }

  Future<bool> toggleFavorite(String placeId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = (prefs.getStringList(_favoritesKey) ?? <String>[]).toSet();
    final isNowFavorite = !favorites.contains(placeId);

    if (isNowFavorite) {
      favorites.add(placeId);
    } else {
      favorites.remove(placeId);
    }

    await prefs.setStringList(_favoritesKey, favorites.toList()..sort());
    return isNowFavorite;
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

  Future<void> saveVerification(String placeId, String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_verificationPrefix$placeId', status);
    await prefs.setString('$_verificationPrefix${placeId}_at', DateTime.now().toIso8601String());
    await addPoints(status == 'open' ? 5 : 3);
  }

  Future<String?> loadVerificationStatus(String placeId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_verificationPrefix$placeId');
  }
}
