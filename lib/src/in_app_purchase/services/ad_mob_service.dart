import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService extends ChangeNotifier {
  Future<InitializationStatus> initialization;
  late BannerAd _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isBannerAdLoaded = false;
  bool _isInterstitialAdLoaded = false;
  bool isInterstitialAdShowed = false;

  AdMobService(this.initialization) {
    _setupBannerAd();
    _setupInterstitialAd();
  }

  late Function onInterstitialClosed;

  void setOnInterstitialClosed(Function callback) {
    onInterstitialClosed = callback;
  }

  void onConnectionChanged(bool isConnected) {
    if (isConnected) {
      reloadAd();
    } else {
      _handleLostConnection();
    }
  }

  void _handleLostConnection() {
    _isBannerAdLoaded = false;
    _isInterstitialAdLoaded = false;
    _bannerAd.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    notifyListeners();
  }

  void reloadAd() {
    _bannerAd.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _setupBannerAd();
    _setupInterstitialAd();
  }

  bool get isBannerAdLoaded => _isBannerAdLoaded;
  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded;

  String? get bannerAdUnitId {
    if (kReleaseMode) {
      if (Platform.isIOS) {
        return "ios-value-of-app-id-from-admob-production";
      } else {
        return "android-value-of-app-id-from-admob-production"; //TO_DO do updejtu finalne wersje produkcyjnych IDkow
      }
    } else {
      if (Platform.isIOS) {
        return "ios-value-of-app-id-from-admob-test";
      } else {
        return "ca-app-pub-3940256099942544/6300978111";
      }
    }
  }

  String? get interstitialAdUnitId {
    if (kReleaseMode) {
      if (Platform.isIOS) {
        return "ios-value-of-app-id-from-admob-production";
      } else {
        return "android-value-of-app-id-from-admob-production"; //TO_DO do updejtu finalne wersje produkcyjnych IDkow
      }
    } else {
      if (Platform.isIOS) {
        return "ios-value-of-app-id-from-admob-test";
      } else {
        return "ca-app-pub-3940256099942544/8691691433";
      }
    }
  }

  String? get nativeAdUnitId {
    if (kReleaseMode) {
      if (Platform.isIOS) {
        return "ios-value-of-app-id-from-admob-production";
      } else {
        return "android-value-of-app-id-from-admob-production";
      }
    } else {
      if (Platform.isIOS) {
        return "ios-value-of-app-id-from-admob-test";
      } else {
        return "ca-app-pub-3940256099942544/2247696110";
      }
    }
  }

  void _setupBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId ?? '',
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          //print('Ad loaded.');
          _isBannerAdLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, error) {
          //print('Ad failed to load: $error');
          ad.dispose();
          notifyListeners();
          // Ustawienie timera do ponownego próbowania załadowania
          Timer(Duration(seconds: 30), () {
            _setupBannerAd();
          });
        },
        onAdOpened: (ad) => print('Ad opened.'),
        onAdClosed: (ad) {
          //print('Ad closed.');
          _isBannerAdLoaded = false;
          notifyListeners();
        },
      ),
    )..load();
  }

  // Metoda do uzyskania bannerAd dla widgetu
  BannerAd get bannerAd => _bannerAd;

  void _setupInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId ?? '',
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true; // Ustaw flagę, że reklama została załadowana
          notifyListeners();
        },
        onAdFailedToLoad: (error) {
          //print('InterstitialAd failed to load: $error');
          _interstitialAd = null;
          _isInterstitialAdLoaded = false; // Ustaw flagę, że reklama nie została załadowana
          notifyListeners();
        },
      ),
    );
  }

  void showInterstitialAd() {
    final interstitialAd = _interstitialAd;
    if (interstitialAd != null) {
      interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          isInterstitialAdShowed = true;
          //print('Ad showed full screen content.');
        },
        onAdDismissedFullScreenContent: (ad) async {
          await ad.dispose();
          //print('Ad dismissed full screen content.');
          // Wywołanie callbacku
          isInterstitialAdShowed = false;
          await onInterstitialClosed();
          //print('wykonalem callback');
          _setupInterstitialAd(); // Ponowne ładowanie reklamy pełnoekranowej
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          //print('Ad failed to show full screen content: $error');
          ad.dispose();
          _setupInterstitialAd(); // Ponowne ładowanie reklamy pełnoekranowej
        },
      );
      interstitialAd.show();
    } else {
      //print('Interstitial ad is not ready yet.');
    }
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }
}
