// Uncomment the following lines when enabling Firebase Crashlytics
// import 'dart:io';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:game_template/src/drawer/global_loading.dart';
import 'package:game_template/src/level_selection/team_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'src/Language_selector_screen/language_selector.dart';
import 'src/Loading_screen/loading_screen.dart';
import 'src/Loading_screen/loading_screen_second.dart';
import 'src/ads/ads_controller.dart';
import 'src/app_lifecycle/TranslationProvider.dart';
import 'src/app_lifecycle/app_lifecycle.dart';
import 'src/audio/audio_controller.dart';
import 'src/crashlytics/crashlytics.dart';
import 'src/games_services/games_services.dart';
import 'src/in_app_purchase/cards_advertisement_screen.dart';
import 'src/in_app_purchase/in_app_purchase.dart';
import 'src/level_selection/level_selection_screen.dart';
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

  // To enable Firebase Crashlytics, uncomment the following lines and
  // the import statements at the top of this file.
  // See the 'Crashlytics' section of the main README.md file for details.

  FirebaseCrashlytics? crashlytics;
  // if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
  //   try {
  //     WidgetsFlutterBinding.ensureInitialized();
  //     await Firebase.initializeApp(
  //       options: DefaultFirebaseOptions.currentPlatform,
  //     );
  //     crashlytics = FirebaseCrashlytics.instance;
  //   } catch (e) {
  //     debugPrint("Firebase couldn't be initialized: $e");
  //   }
  // }

  await guardWithCrashlytics(
    guardedMain,
    crashlytics: crashlytics,
  );
}

/// Without logging and crash reporting, this would be `void main()`.
Future<void> guardedMain() async {

  if (kReleaseMode) {
    // Don't log anything below warnings
    // in production.
    Logger.root.level = Level.WARNING;
  }
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: '
        '${record.loggerName}: '
        '${record.message}');
  });

  WidgetsFlutterBinding.ensureInitialized();

  _log.info('Going full screen');
  WidgetsBinding.instance.addPostFrameCallback((_) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
  });

  //TO_DO: When ready, uncomment the following lines to enable integrations.
  //       Read the README for more info on each integration.

  AdsController? adsController;
  // if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
  //   /// Prepare the google_mobile_ads plugin so that the first ad loads
  //   /// faster. This can be done later or with a delay if startup
  //   /// experience suffers.
  //   adsController = AdsController(MobileAds.instance);
  //   adsController.initialize();
  // }

  GamesServicesController? gamesServicesController;
  // if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
  //   gamesServicesController = GamesServicesController()
  //     // Attempt to log the player in.
  //     ..initialize();
  // }
  final translationProvider = TranslationProvider.fromDeviceLanguage();
  await translationProvider.loadWords();
  InAppPurchaseController? inAppPurchaseController;
  inAppPurchaseController = InAppPurchaseController(InAppPurchase.instance, translationProvider);
  // if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
  //   inAppPurchaseController = InAppPurchaseController(InAppPurchase.instance)
  //     // Subscribing to [InAppPurchase.instance.purchaseStream] as soon
  //     // as possible in order not to miss any updates.
  //     ..subscribe();
  //   // Ask the store what the player has bought already.
  //   inAppPurchaseController.restorePurchases();
  // }
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await translationProvider.loadTranslations().then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: translationProvider,
          ),
      ChangeNotifierProvider<TeamProvider>(
          create: (context) {
            final provider = TeamProvider();
            provider.initializeTeams(context, 2);
            return provider;
          },),
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
          adsController: adsController,
          gamesServicesController: gamesServicesController,
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
Logger _log = Logger('main.dart');

class MyApp extends StatelessWidget {

  static final _router = GoRouter(
    routes: [
      GoRoute(
          path: '/',
          builder: (context, state) =>
          const MainMenuScreen(key: Key('main menu')),
          routes: [
            GoRoute(
              path: 'settings',
              pageBuilder: (context, state) =>
                  buildMyTransition<void>(
                    child: SettingsScreen(
                        key: Key('settings'),
                        scaffoldKey: GlobalKey<ScaffoldState>()),
                    color: context
                        .watch<Palette>()
                        .backgroundTransparent,
                    decoration: BoxDecoration(
                        gradient: context
                            .watch<Palette>()
                            .backgroundLoadingSessionGradient),
                  ),
            ),
            GoRoute(
              path: 'loading',
              pageBuilder: (context, state) =>
                  buildMyTransition<void>(
                    child: LoaderWidgetSecond(key: Key('loading'), countdown: 3),
                    color: context
                        .watch<Palette>()
                        .backgroundPlaySession,
                  ),
            ),
            GoRoute(
              path: 'language_selector',
              pageBuilder: (context, state) =>
                  buildMyTransition<void>(
                    child: LanguageSelector(
                        key: Key('language_selector'),
                        scaffoldKey: GlobalKey<ScaffoldState>()),
                    color: context
                        .watch<Palette>()
                        .backgroundTransparent,
                    decoration: BoxDecoration(
                        gradient: context
                            .watch<Palette>()
                            .backgroundLoadingSessionGradient),
                  ),
            ),
            GoRoute(
              path: 'card_advertisement',
              pageBuilder: (context, state) =>
                  buildMyTransition<void>(
                    child: CardAdvertisementScreen(
                        key: Key('card_advertisement'),
                        scaffoldKey: GlobalKey<ScaffoldState>()),
                    color: context
                        .watch<Palette>()
                        .backgroundTransparent,
                    decoration: BoxDecoration(
                        gradient: context
                            .watch<Palette>()
                            .backgroundLoadingSessionGradient),
                  ),
            ),
          ]),
  ]);

  final PlayerProgressPersistence playerProgressPersistence;

  final SettingsPersistence settingsPersistence;

  final GamesServicesController? gamesServicesController;

  final InAppPurchaseController? inAppPurchaseController;

  final AdsController? adsController;

  final Future initFuture = Future.wait([
    // umieść tutaj swoje operacje inicjalizacyjne, na przykład:
    // Firebase.initializeApp(),
    // initCrashlytics(),
    // initAdmob(),
    // initInAppPurchases(),
    // initGameServices(),
    // itd.
    Future<void>.delayed(Duration(seconds: 3)),
  ]);

  MyApp({super.key, 
    required this.playerProgressPersistence,
    required this.settingsPersistence,
    required this.inAppPurchaseController,
    required this.adsController,
    required this.gamesServicesController,
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
                  Provider<GamesServicesController?>.value(
                      value: gamesServicesController),
                  Provider<AdsController?>.value(value: adsController),
                  ChangeNotifierProvider<InAppPurchaseController?>.value(
                      value: inAppPurchaseController),
                  ChangeNotifierProvider<SettingsController>(
                    lazy: false,
                    create: (context) =>
                    SettingsController(
                      persistence: settingsPersistence,
                    )
                      ..loadStateFromPersistence(),
                  ),
                  ProxyProvider2<SettingsController,
                      ValueNotifier<AppLifecycleState>,
                      AudioController>(
                    // Ensures that the AudioController is created on startup,
                    // and not "only when it's needed", as is default behavior.
                    // This way, music starts immediately.
                    lazy: false,
                    create: (context) =>
                    AudioController()
                      ..initialize(),
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
            return MaterialApp(
                home: Scaffold(
                  body: LoaderWidget()
                )
            );
          }
        }
    );
  }
}
