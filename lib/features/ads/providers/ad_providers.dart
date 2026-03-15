import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

/// Provider for [AdService]
final adServiceProvider = Provider<AdService>((ref) {
  return AdMobService();
});

/// Notifier for managing interstitial ad lifecycle
class InterstitialAdNotifier extends StateNotifier<InterstitialAd?> {
  final AdService _adService;

  InterstitialAdNotifier(this._adService) : super(null);

  /// Loads an interstitial ad
  Future<void> load() async {
    await InterstitialAd.load(
      adUnitId: _adService.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              state = null;
              load(); // Preload next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              state = null;
            },
          );
          state = ad;
        },
        onAdFailedToLoad: (error) {
          state = null;
        },
      ),
    );
  }

  /// Shows the interstitial ad if ready
  Future<void> show() async {
    if (state != null) {
      await state!.show();
    }
  }

  @override
  void dispose() {
    state?.dispose();
    super.dispose();
  }
}

/// Provider for interstitial ad notifier
final interstitialAdProvider =
    StateNotifierProvider<InterstitialAdNotifier, InterstitialAd?>((ref) {
  final adService = ref.watch(adServiceProvider);
  final notifier = InterstitialAdNotifier(adService);
  notifier.load();
  return notifier;
});
