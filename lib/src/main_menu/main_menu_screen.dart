import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_template/src/in_app_purchase/services/ad_mob_service.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_lifecycle/responsive_sizing.dart';
import '../app_lifecycle/translated_text.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../customAppBar/customAppBar_notitle.dart';
import '../drawer/drawer.dart';
import '../games_services/score.dart';
import '../in_app_purchase/services/firebase_service.dart';
import '../instruction_dialog/instruction_dialog.dart';
import '../level_selection/level_selection_screen.dart';
import '../play_session/custom_style_buttons.dart';
import '../style/palette.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _setupConnectivityListener();

    _animationController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat(); // Powtarza animację w nieskończoność

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.1), weight: 0.05),
      TweenSequenceItem(tween: ConstantTween<double>(1.1), weight: 0.05),
      TweenSequenceItem(tween: Tween<double>(begin: 1.1, end: 1.0), weight: 0.05),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 0.85),
    ]).animate(_animationController);
    //_checkPurchaseStatus();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        _tryLoadAd();
      }
    });
  }

  void _tryLoadAd(){
    context.read<AdMobService>().reloadAd();
  }

  Future<void> _checkPurchaseStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isPurchased = prefs.getBool('isPurchased') ?? false;

    if (isPurchased) {
      // Jeśli aplikacja jest zakupiona, spróbuj zalogować użytkownika
      //await _firebaseService.signInAnonymouslyAndSaveUID();
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }
/*
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _adMobService = context.read<AdMobService>();
    _adMobService.initialization.then((value) {
      setState(() {
        _banner = BannerAd(
            size: AdSize.fullBanner,
            adUnitId: _adMobService.bannerAdUnitId!,
            listener: _adMobService.bannerListener,
            request: AdRequest())
          ..load();
      });
    });
  }*/
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: const [
            LevelSelectionScreen(
              key: Key('level selection'),
            ),
          ],
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioController = context.watch<AudioController>();
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final isBannerAdLoaded = context.watch<AdMobService>().isBannerAdLoaded;
    final isInterstitialAdLoaded = context.watch<AdMobService>().isInterstitialAdLoaded;

    TeamScore.resetAllScores();
    return Container(
      decoration: BoxDecoration(
        gradient: Palette().backgroundLoadingSessionGradient,
      ),
      child: Scaffold(
        drawer: CustomAppDrawer(),
        key: scaffoldKey,
        appBar: CustomAppBar_notitle(
          onMenuButtonPressed: () {
            audioController.playSfx(SfxType.button_back_exit);
            scaffoldKey.currentState?.openDrawer();
          },
          title: '',
        ),
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: LogoWidget(),
                ),
                ResponsiveSizing.responsiveHeightGapWithCondition(context, 30, 45, 650),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomStyledButton(
                      icon: Icons.question_mark,
                      text: getTranslatedString(context, 'game_rules'),
                      onPressed: () {
                        audioController.playSfx(SfxType.button_infos);
                        Future.delayed(Duration(milliseconds: 150), () {
                          showDialog<void>(
                            context: context,
                            builder: (context) {
                              return InstructionDialog(isGameOpened: false);
                            },
                          );
                        });
                      },
                      backgroundColor: Palette().bluegrey,
                      foregroundColor: Palette().menudark,
                      width: 200,
                      height: 45,
                      fontSize: ResponsiveSizing.scaleHeight(context, 20),
                    ),
                    ResponsiveSizing.responsiveHeightGapWithCondition(context, 5, 10, 650),
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) => Transform.scale(
                        scale: _scaleAnimation.value,
                        child: child,
                      ),
                      child: CustomStyledButton(
                        icon: Icons.play_arrow_rounded,
                        text: getTranslatedString(context, 'play_now'),
                        onPressed: () {
                          if (isInterstitialAdLoaded) {
                            context.read<AdMobService>().showInterstitialAd();
                            print('powinnoa byc000');
                          }
                          audioController.playSfx(SfxType.button_accept);
                          Navigator.of(context).push(_createRoute());
                        },
                        backgroundColor: Palette().pink,
                        foregroundColor: Palette().white,
                        width: 200,
                        height: 45,
                        fontSize: ResponsiveSizing.scaleHeight(context, 20),
                      ),
                    ),
                    ResponsiveSizing.responsiveHeightGapWithCondition(context, 5, 10, 650),
                    CustomStyledButton(
                      icon: Icons.settings,
                      text: getTranslatedString(context, 'settings'),
                      onPressed: () {
                        audioController.playSfx(SfxType.button_back_exit);
                        GoRouter.of(context).go('/settings');
                      },
                      backgroundColor: Palette().bluegrey,
                      foregroundColor: Palette().menudark,
                      width: 200,
                      height: 45,
                      fontSize: ResponsiveSizing.scaleHeight(context, 20),
                    ),
                    ResponsiveSizing.responsiveHeightGapWithCondition(context, 5, 10, 650),
                    CustomStyledButton(
                      icon: null,
                      text: getTranslatedString(context, 'exit'),
                      onPressed: () {
                        audioController.playSfx(SfxType.button_back_exit);
                        SystemNavigator.pop();
                      },
                      backgroundColor: Palette().bluegrey,
                      foregroundColor: Palette().menudark,
                      width: 200,
                      height: 45,
                      fontSize: ResponsiveSizing.scaleHeight(context, 20),
                    ),
                    //SizedBox(height: ResponsiveSizing.scaleHeight(context, 80)),

                    //Text("Account type: free"),
                    Text("${context.read<FirebaseService?>()?.currentUser?.uid}", style: TextStyle(color: Colors.white)), // print user UID wygenerowanego w firebase
                    //reklamka
                    if (isBannerAdLoaded)
                      Container(
                        height: 60,
                        child: AdWidget(ad: context.read<AdMobService>().bannerAd),
                      ) else  SizedBox(height: 60)
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
