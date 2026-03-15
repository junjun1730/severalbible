import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Abstract interface for ad services
abstract class AdService {
  Future<void> initialize();
  String get bannerAdUnitId;
  String get interstitialAdUnitId;
}

/// AdMob implementation of [AdService]
class AdMobService implements AdService {
  // Google official test Ad Unit IDs
  static const String _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerIos = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIos = 'ca-app-pub-3940256099942544/4411468910';

  // Production Ad Unit IDs (to be configured after AdMob account setup)
  static const String _prodBannerAndroid = '';
  static const String _prodBannerIos = '';
  static const String _prodInterstitialAndroid = '';
  static const String _prodInterstitialIos = '';

  @override
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  @override
  String get bannerAdUnitId {
    if (kDebugMode) {
      return defaultTargetPlatform == TargetPlatform.iOS
          ? _testBannerIos
          : _testBannerAndroid;
    }
    return defaultTargetPlatform == TargetPlatform.iOS
        ? _prodBannerIos
        : _prodBannerAndroid;
  }

  @override
  String get interstitialAdUnitId {
    if (kDebugMode) {
      return defaultTargetPlatform == TargetPlatform.iOS
          ? _testInterstitialIos
          : _testInterstitialAndroid;
    }
    return defaultTargetPlatform == TargetPlatform.iOS
        ? _prodInterstitialIos
        : _prodInterstitialAndroid;
  }
}
