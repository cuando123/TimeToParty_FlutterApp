import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_template/src/app_lifecycle/loading_status.dart';
import 'package:game_template/src/drawer/global_loading.dart';
import 'package:game_template/src/in_app_purchase/services/ad_mob_service.dart';
import 'package:game_template/src/in_app_purchase/services/firebase_service.dart';
import 'package:game_template/src/level_selection/team_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'myapp.dart';
import 'src/app_lifecycle/TranslationProvider.dart';
import 'src/crashlytics/crashlytics.dart';
import 'src/games_services/games_services.dart';
import 'src/in_app_purchase/in_app_purchase.dart';
import 'src/player_progress/persistence/local_storage_player_progress_persistence.dart';
import 'src/settings/persistence/local_storage_settings_persistence.dart';

final globalLoading = GlobalLoading();

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

  InAppPurchaseController inAppPurchaseController = InAppPurchaseController(InAppPurchase.instance, translationProvider);

  //probably to be unused
  GamesServicesController? gamesServicesController;
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
          ChangeNotifierProvider<InAppPurchaseController?>(
            create: (context) => inAppPurchaseController,
          ),
        ],
        child: MyApp(
          settingsPersistence: LocalStorageSettingsPersistence(),
          playerProgressPersistence: LocalStoragePlayerProgressPersistence(),
          inAppPurchaseController: inAppPurchaseController,
          gamesServicesController: gamesServicesController,
          firebaseService: firebaseService,
        ),
      ),
  );
}
/*
  late StreamSubscription<List<PurchaseDetails>>
      _iap_subscription; //tworze stream subskrypcji - a raczej nasluchuje nawrotu

  @override
  void initState(){
     super.initState()
     final Stream purchaseUpdated = InAppPurchase.instance.purchaseStream; nasluchuje strumienia powrotu
     _iap_subscription = pruchaseUpdated.listen((purchaseDetailsList){  // zapisuje updejt
      print("Pruchase stream started");
      IAPService(uid).listToPurchaseUpdated(purchaseDetailsList); //tu w miejscu wywolania musi byc dostepne UID generowane z firebase akurat jest tutaj w main menu to
      }, onDone: (){
      _iap_subscription.cancel(); jesli wykonano
      }, onError (error){
      _iap_subscription.cancel(); jesli jakis blad, anuluj subskrypcje
     } as StreamSubscription<List<PurchaseDetails>>; //rzutowanie na typ subskrypcji na poczatku iap
     //koniec init State
    TO_DO trzeba to ogolnie przerobic i pomyslec gdzie powinienna byc oczekiwany strumien i jak go przekazac dalej do aplikacji - changeNotifierProvider?
    TO_DO 2 trzeba przeanalizowac teraz mając obecna wiedze czy te funkcje ktore tu byly mi sie przydadza - powinienem juz to w miare zrozumiec to co tu bylo?
below
       }*/