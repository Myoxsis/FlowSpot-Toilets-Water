import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  static const bannerAdUnitId = 'ca-app-pub-xxxxxxxxxxxxxxxx/banner';
  static const nativeAdUnitId = 'ca-app-pub-xxxxxxxxxxxxxxxx/native';

  static const monetizationGuidelines = [
    'Never block navigation with ads',
    'Prioritize utility speed over impressions',
    'Place ads after trust information',
    'Avoid full-screen interstitials during emergency usage',
  ];
}
