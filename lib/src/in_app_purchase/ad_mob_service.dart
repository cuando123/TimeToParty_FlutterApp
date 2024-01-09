import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService extends ChangeNotifier {
  Future<InitializationStatus> initialization;
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  AdMobService(this.initialization) {
    _setupBannerAd();
  }
  void reloadAd() {
    _bannerAd?.dispose();
    _setupBannerAd();
  }

  bool get isAdLoaded => _isAdLoaded;

  String? get bannerAdUnitId {
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
        return "ca-app-pub-3940256099942544/6300978111";
      }
    }
  }

  String? get interstitialAdUnitId {
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
        return "ca-app-pub-3940256099942544/1033173712";
      }
    }
  }

  void _setupBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId ?? '',
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('Ad loaded.');
          _isAdLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Ad failed to load: $error');
          ad.dispose();
          // Ustawienie timera do ponownego próbowania załadowania
          Timer(Duration(seconds: 30), () {
            _setupBannerAd(); // Ponowne próby ładowania
          });
        },
        onAdOpened: (Ad ad) => print('Ad opened.'),
        onAdClosed: (Ad ad) => print('Ad closed.'),
      ),
    )..load();
  }

  // Metoda do uzyskania bannerAd dla widgetu
  BannerAd get bannerAd => _bannerAd;
}
