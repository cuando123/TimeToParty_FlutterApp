import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:game_template/src/Language_selector_screen/language_selector.dart';
import 'package:game_template/src/Loading_screen/loading_screen.dart';
import 'package:game_template/src/Loading_screen/loading_screen_second.dart';
import 'package:game_template/src/app_lifecycle/TranslationProvider.dart';
import 'package:game_template/src/app_lifecycle/app_lifecycle.dart';
import 'package:game_template/src/audio/audio_controller.dart';
import 'package:game_template/src/in_app_purchase/cards_advertisement_screen.dart';
import 'package:game_template/src/in_app_purchase/models/global_stopwatch.dart';
import 'package:game_template/src/in_app_purchase/models/shared_preferences_helper.dart';
import 'package:game_template/src/in_app_purchase/services/firebase_service.dart';
import 'package:game_template/src/in_app_purchase/services/iap_service.dart';
import 'package:game_template/src/main_menu/main_menu_screen.dart';
import 'package:game_template/src/notifications/notifications_manager.dart';
import 'package:game_template/src/player_progress/persistence/player_progress_persistence.dart';
import 'package:game_template/src/player_progress/player_progress.dart';
import 'package:game_template/src/settings/persistence/settings_persistence.dart';
import 'package:game_template/src/settings/settings.dart';
import 'package:game_template/src/settings/settings_screen.dart';
import 'package:game_template/src/style/my_transition.dart';
import 'package:game_template/src/style/palette.dart';
import 'package:game_template/src/style/snack_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'main.dart';

class MyApp extends StatefulWidget {
  final PlayerProgressPersistence playerProgressPersistence;
  final SettingsPersistence settingsPersistence;
  //final GamesServicesController? gamesServicesController;
  final FirebaseService firebaseService;
  final IAPService iapService;
  final TranslationProvider translationProvider;

  const MyApp({
    super.key,
    required this.playerProgressPersistence,
    required this.settingsPersistence,
    required this.iapService,
    //required this.gamesServicesController,
    required this.firebaseService,
    required this.translationProvider,
  });

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final Future initFuture = Future.wait([]);

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    GlobalStopwatch.start(); // Rozpoczęcie pomiaru czasu sesji
    SharedPreferencesHelper.setHowManyTimesRunApp();
    print("MyApp received FirebaseService instance hashCode: ${widget.firebaseService.hashCode}");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    GlobalStopwatch.stop(); // Zatrzymanie pomiaru czasu sesji
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      GlobalStopwatch.stop();
      Future.microtask(() async {
        await _saveDataAsync();
      });
    } else if (state == AppLifecycleState.resumed) {
      GlobalStopwatch.reset();
      GlobalStopwatch.start();
    }
  }

  Future<void> _saveDataAsync() async {
    int lastSessionTime = GlobalStopwatch.getElapsedTime();
    await SharedPreferencesHelper.setFinalSpendTimeOnGame(lastSessionTime);
    await SharedPreferencesHelper.setLastOneSpendTimeOnGame(lastSessionTime);
    await SharedPreferencesHelper.setLastPlayDate(DateFormat('yyyy-MM-dd – HH:mm').format(DateTime.now()));

    String? userId = await SharedPreferencesHelper.getUserID();
    int? finalSpendTimeOnGame = await SharedPreferencesHelper.getFinalSpendTimeOnGame();
    int? lastOneSpendTimeOnGame = await SharedPreferencesHelper.getLastOneSpendTimeOnGame();
    String? lastPlayDate = await SharedPreferencesHelper.getLastPlayDate();
    int? howManyTimesRunApp = await SharedPreferencesHelper.getHowManyTimesRunApp();
    int? howManyTimesFinishedGame = await SharedPreferencesHelper.getHowManyTimesFinishedGame();
    int? howManyTimesRunInterstitialAd = await SharedPreferencesHelper.getHowManyTimesRunInterstitialAd();
    String? lastHowManyFieldReached = await SharedPreferencesHelper.getLastHowManyFieldReached();

    // Teraz możemy bezpiecznie używać toString(), ponieważ mamy już rozwiązane wartości
    if(userId != null){ // Upewnij się, że userId nie jest null przed aktualizacją
      if(finalSpendTimeOnGame != null) await widget.firebaseService.updateUserInformations(userId, 'finalSpendTimeOnGame', finalSpendTimeOnGame.toString());
      if(lastOneSpendTimeOnGame != null) await widget.firebaseService.updateUserInformations(userId, 'lastOneSpendTimeOnGame', lastOneSpendTimeOnGame.toString());
      if(lastPlayDate != null) await widget.firebaseService.updateUserInformations(userId, 'lastPlayDate', lastPlayDate.toString());
      if(howManyTimesRunApp != null) await widget.firebaseService.updateUserInformations(userId, 'howManyTimesRunApp', howManyTimesRunApp.toString());
      if(howManyTimesFinishedGame != null) await widget.firebaseService.updateUserInformations(userId, 'howManyTimesFinishedGame', howManyTimesFinishedGame.toString());
      if(howManyTimesRunInterstitialAd != null) await widget.firebaseService.updateUserInformations(userId, 'howManyTimesRunInstertitialAd', howManyTimesRunInterstitialAd.toString());
      if(lastHowManyFieldReached != null) await widget.firebaseService.updateUserInformations(userId, 'lastHowManyFieldReached', lastHowManyFieldReached);
    }
  }


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
                      var progress = PlayerProgress(widget.playerProgressPersistence);
                      progress.getLatestFromStore();
                      return progress;
                    },
                  ),
                  Provider(
                    create: (_) => NotificationsManager(context, widget.firebaseService),
                  ),
                  //Provider<GamesServicesController?>.value(value: gamesServicesController),
                  //IAPService iapService = IAPService(InAppPurchase.instance, translationProvider, firebaseService);
                  ChangeNotifierProvider<IAPService>.value(value: widget.iapService),
                  //ChangeNotifierProvider<IAPService>.value(value: widget.iapService),
                  ChangeNotifierProvider<SettingsController>(
                    lazy: false,
                    create: (context) => SettingsController(
                      persistence: widget.settingsPersistence,
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
                  ChangeNotifierProvider<FirebaseService>(create: (context) => widget.firebaseService),
                ],
                child: Builder(builder: (context) {
                  final palette = context.watch<Palette>();
                  return MaterialApp.router(debugShowCheckedModeBanner: false,
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