import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:game_template/src/drawer/global_loading.dart';
import 'package:game_template/src/in_app_purchase/services/ad_mob_service.dart';
import 'package:game_template/src/in_app_purchase/services/firebase_service.dart';
import 'package:game_template/src/level_selection/team_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'src/Language_selector_screen/language_selector.dart';
import 'src/Loading_screen/loading_screen.dart';
import 'src/Loading_screen/loading_screen_second.dart';
import 'src/app_lifecycle/TranslationProvider.dart';
import 'src/app_lifecycle/app_lifecycle.dart';
import 'src/audio/audio_controller.dart';
import 'src/crashlytics/crashlytics.dart';
import 'src/games_services/games_services.dart';
import 'src/in_app_purchase/cards_advertisement_screen.dart';
import 'src/in_app_purchase/in_app_purchase.dart';
import 'src/main_menu/main_menu_screen.dart';
import 'src/notifications/notifications_manager.dart';
import 'src/player_progress/persistence/local_storage_player_progress_persistence.dart';
import 'src/player_progress/persistence/player_progress_persistence.dart';
import 'src/player_progress/player_progress.dart';
import 'src/settings/persistence/local_storage_settings_persistence.dart';
import 'src/settings/persistence/settings_persistence.dart';
import 'src/settings/settings.dart';
import 'src/settings/settings_screen.dart';
import 'src/style/my_transition.dart';
import 'src/style/palette.dart';
import 'src/style/snack_bar.dart';

final globalLoading = GlobalLoading();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseCrashlytics? crashlytics;

  try {
    await Firebase.initializeApp();
    crashlytics = FirebaseCrashlytics.instance;
  } catch (e) {
    debugPrint("Firebase couldn't be initialized: $e");
  }

  await guardWithCrashlytics(
    guardedMain,
    crashlytics: crashlytics,
  );
}

/// Without logging and crash reporting, this would be `void main()`.
Future<void> guardedMain() async {
  if (kReleaseMode) {
    Logger.root.level = Level.WARNING; // Don't log anything below warnings in production
  }
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: '
        '${record.loggerName}: '
        '${record.message}');
  });

  WidgetsBinding.instance.addPostFrameCallback((_) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
  });

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Sprawdź połączenie internetowe
  var connectivityResult = await Connectivity().checkConnectivity();
  FirebaseService firebaseService;
  // inicjalizacja która dotyczy TYLKO POCZATKOWEGO STANU
  // Inicjalizuj usługi tylko przy dostępnym połączeniu
  if (connectivityResult != ConnectivityResult.none) {
    firebaseService = FirebaseService(); // Przy dostępnym połączeniu
    // Inicjalizuj inne usługi zależne od połączenia
  } else {
    firebaseService = FirebaseService(isConncected: false); // W trybie offline
  }
  final initAdFuture = MobileAds.instance.initialize();

  AdMobService? adMobService = AdMobService(initAdFuture);
  RequestConfiguration configuration =
      RequestConfiguration(testDeviceIds: <String>["F8D4B943818617C80D522DA32ED12984"]); // Ustaw testowe ID urządzeń
  await MobileAds.instance.updateRequestConfiguration(configuration);

  final translationProvider = TranslationProvider.fromDeviceLanguage();
  await translationProvider.loadWords();

  GamesServicesController? gamesServicesController;
  InAppPurchaseController? inAppPurchaseController;
  inAppPurchaseController = InAppPurchaseController(InAppPurchase.instance, translationProvider);

  late StreamSubscription<List<PurchaseDetails>>
      _iap_subscription; //tworze stream subskrypcji - a raczej nasluchuje nawrotu
  /*
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
  await translationProvider.loadTranslations().then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<FirebaseService?>(
            create: (context) => firebaseService, //provider uzytkownika
          ),
          ChangeNotifierProvider<AdMobService?>(
            create: (context) => adMobService, //provider admob
          ),
          ChangeNotifierProvider.value(
            value: translationProvider,
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
  });
}

class LoadingStatus extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  static final _router = GoRouter(routes: [
    GoRoute(path: '/', builder: (context, state) => const MainMenuScreen(key: Key('main menu')), routes: [
      GoRoute(
        path: 'settings',
        pageBuilder: (context, state) => buildMyTransition<void>(
          child: SettingsScreen(key: Key('settings'), scaffoldKey: GlobalKey<ScaffoldState>()),
          color: context.watch<Palette>().backgroundTransparent,
          decoration: BoxDecoration(gradient: context.watch<Palette>().backgroundLoadingSessionGradient),
        ),
      ),
      GoRoute(
        path: 'loading',
        pageBuilder: (context, state) => buildMyTransition<void>(
          child: LoaderWidgetSecond(key: Key('loading'), countdown: 3),
          color: context.watch<Palette>().backgroundPlaySession,
        ),
      ),
      GoRoute(
        path: 'language_selector',
        pageBuilder: (context, state) => buildMyTransition<void>(
          child: LanguageSelector(key: Key('language_selector'), scaffoldKey: GlobalKey<ScaffoldState>()),
          color: context.watch<Palette>().backgroundTransparent,
          decoration: BoxDecoration(gradient: context.watch<Palette>().backgroundLoadingSessionGradient),
        ),
      ),
      GoRoute(
        path: 'card_advertisement',
        pageBuilder: (context, state) => buildMyTransition<void>(
          child: CardAdvertisementScreen(key: Key('card_advertisement'), scaffoldKey: GlobalKey<ScaffoldState>()),
          color: context.watch<Palette>().backgroundTransparent,
          decoration: BoxDecoration(gradient: context.watch<Palette>().backgroundLoadingSessionGradient),
        ),
      ),
    ]),
  ]);

  final PlayerProgressPersistence playerProgressPersistence;

  final SettingsPersistence settingsPersistence;

  final GamesServicesController? gamesServicesController;

  final FirebaseService firebaseService;

  final InAppPurchaseController? inAppPurchaseController;

  final Future initFuture = Future.wait([]);

  MyApp({
    super.key,
    required this.playerProgressPersistence,
    required this.settingsPersistence,
    required this.inAppPurchaseController,
    required this.gamesServicesController,
    required this.firebaseService,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return AppLifecycleObserver(
              child: MultiProvider(
                providers: [
                  ChangeNotifierProvider(
                    create: (context) {
                      var progress = PlayerProgress(playerProgressPersistence);
                      progress.getLatestFromStore();
                      return progress;
                    },
                  ),
                  Provider(
                    create: (_) => NotificationsManager(context),
                  ),
                  Provider<GamesServicesController?>.value(value: gamesServicesController),
                  ChangeNotifierProvider<InAppPurchaseController?>.value(value: inAppPurchaseController),
                  ChangeNotifierProvider<SettingsController>(
                    lazy: false,
                    create: (context) => SettingsController(
                      persistence: settingsPersistence,
                    )..loadStateFromPersistence(),
                  ),
                  ProxyProvider2<
                      SettingsController, // Ensures that the AudioController is created on startup,
                      ValueNotifier<AppLifecycleState>, // and not "only when it's needed", as is default behavior.
                      AudioController>(
                    // This way, music starts immediately.
                    lazy: false,
                    create: (context) => AudioController()..initialize(),
                    update: (context, settings, lifecycleNotifier, audio) {
                      if (audio == null) throw ArgumentError.notNull();
                      audio.attachSettings(settings);
                      audio.attachLifecycleNotifier(lifecycleNotifier);
                      return audio;
                    },
                    dispose: (context, audio) => audio.dispose(),
                  ),
                  Provider(
                    create: (context) => Palette(),
                  ),
                  ChangeNotifierProvider<FirebaseService>(create: (context) => firebaseService),
                ],
                child: Builder(builder: (context) {
                  final palette = context.watch<Palette>();
                  return MaterialApp.router(
                    title: 'Time To Party',
                    theme: ThemeData.from(
                      colorScheme: ColorScheme.fromSeed(
                        seedColor: palette.darkPen,
                        background: palette.backgroundMain,
                      ),
                      textTheme: TextTheme(
                        bodyMedium: TextStyle(
                          color: palette.ink,
                        ),
                      ),
                      useMaterial3: true,
                    ),
                    routeInformationProvider: _router.routeInformationProvider,
                    routeInformationParser: _router.routeInformationParser,
                    routerDelegate: _router.routerDelegate,
                    scaffoldMessengerKey: scaffoldMessengerKey,
                    localizationsDelegates: const [
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: const [
                      Locale('en', 'EN'), // Angielski
                      Locale('de', 'DE'), // Niemiecki
                      Locale('it', 'IT'), // Włoski
                      Locale('es', 'ES'), // Hiszpański
                      Locale('pl', 'PL'), // Polski
                      Locale('fr', 'FR'), // Francuski
                    ],
                  );
                }),
              ),
            );
          } else {
            return MaterialApp(home: Scaffold(body: LoaderWidget()));
          }
        });
  }
}
