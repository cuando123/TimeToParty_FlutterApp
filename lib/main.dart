import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_template/src/app_lifecycle/loading_status.dart';
import 'package:game_template/src/drawer/global_loading.dart';
import 'package:game_template/src/in_app_purchase/models/user_informations.dart';
import 'package:game_template/src/in_app_purchase/services/ad_mob_service.dart';
import 'package:game_template/src/in_app_purchase/services/firebase_service.dart';
import 'package:game_template/src/in_app_purchase/services/iap_service.dart';
import 'package:game_template/src/level_selection/team_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'myapp.dart';
import 'src/app_lifecycle/TranslationProvider.dart';
import 'src/player_progress/persistence/local_storage_player_progress_persistence.dart';
import 'src/settings/persistence/local_storage_settings_persistence.dart';

final globalLoading = GlobalLoading();
 UserInformations userInfo = UserInformations();

Future<void> main() async {
  if (kReleaseMode) {
    Logger.root.level = Level.WARNING; // Don't log anything below warnings in production
  }
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: '
        '${record.loggerName}: '
        '${record.message}');
  });

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Ustawienie Crashlytics
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  // Inicjalizacja innych potrzebnych usług
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
  });

  // Sprawdzenie połączenia internetowego
  var connectivityResult = await Connectivity().checkConnectivity();
  FirebaseService firebaseService = connectivityResult != ConnectivityResult.none
      ? FirebaseService()
      : FirebaseService(isConnected: false);

  final initAdFuture = MobileAds.instance.initialize();
  AdMobService adMobService = AdMobService(initAdFuture);
  RequestConfiguration configuration = RequestConfiguration(testDeviceIds: <String>["F8D4B943818617C80D522DA32ED12984"]);
  await MobileAds.instance.updateRequestConfiguration(configuration);

  // Inicjalizacja TranslationProvider i innych usług
  final translationProvider = TranslationProvider.fromDeviceLanguage();
  await translationProvider.loadWords();
  await translationProvider.loadTranslations();

  IAPService iapService = IAPService(InAppPurchase.instance, translationProvider, firebaseService);

  //probably to be unused
  //GamesServicesController? gamesServicesController;
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<FirebaseService>(
            create: (context) => firebaseService,
          ),
          ChangeNotifierProvider<AdMobService>(
            create: (context) => adMobService,
          ),
          ChangeNotifierProvider<TranslationProvider>(
            create: (context) => translationProvider,
          ),
          ChangeNotifierProvider<TeamProvider>(
            create: (context) {
              final provider = TeamProvider();
              provider.initializeTeams(context, 2);
              return provider;
            },
          ),
          ChangeNotifierProvider<LoadingStatus>(
            create: (_) => LoadingStatus(),
          ),
          ChangeNotifierProvider<IAPService>(
            create: (context) => iapService,
          ),
        ],
        child: MyApp(
          settingsPersistence: LocalStorageSettingsPersistence(),
          playerProgressPersistence: LocalStoragePlayerProgressPersistence(),
          iapService: iapService,
          //gamesServicesController: gamesServicesController,
          firebaseService: firebaseService,
        ),
      ),
  );
}