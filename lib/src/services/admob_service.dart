import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  // Official Google Mobile Ads test ad unit IDs.
  // Replace these with real production IDs before App Store / Play Store release.
  static const androidTestAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const iosTestAppId = 'ca-app-pub-3940256099942544~1458002511';

  static const bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const nativeAdUnitId = 'ca-app-pub-3940256099942544/2247696110';

  static const monetizationGuidelines = [
    'Never block navigation with ads',
    'Prioritize utility speed over impressions',
    'Place ads after trust information',
    'Avoid full-screen interstitials during emergency usage',
  ];
}
