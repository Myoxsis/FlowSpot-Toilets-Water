import 'package:shared_preferences/shared_preferences.dart';

class OnboardingStore {
  static const _hasSeenKey = 'flowspot.has_seen_onboarding';

  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenKey) ?? false;
  }

  Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenKey, true);
  }
}
