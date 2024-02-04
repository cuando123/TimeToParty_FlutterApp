import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_template/src/in_app_purchase/services/ad_mob_service.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../app_lifecycle/responsive_sizing.dart';
import '../app_lifecycle/translated_text.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../customAppBar/customAppBar_notitle.dart';
import '../drawer/drawer.dart';
import '../games_services/score.dart';
import '../in_app_purchase/models/shared_preferences_helper.dart';
import '../in_app_purchase/services/firebase_service.dart';
import '../in_app_purchase/services/iap_service.dart';
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
  late FirebaseService _firebaseService;
  bool isOnline = false;
  NativeAd? _nativeAd;
  bool _nativeAdLoaded = false;

  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    SharedPreferencesHelper.setLastHowManyFieldReached('');
    _checkPurchaseStatus();
    //if ACCOUNT = FREE
    try {
      if (!_nativeAdLoaded) {
        _nativeAd = NativeAd(adUnitId: context
            .read<AdMobService>()
            .nativeAdUnitId!, factoryId: 'listTile', request: AdRequest(),
            listener: NativeAdListener(
              onAdLoaded: (ad) {
                setState(() {
                  _nativeAdLoaded = true;
                  isOnline = true;
                });
              },
              onAdFailedToLoad: (ad, error) {
                ad.dispose();
              },
            ))
          ..load();
      }
    } catch (e) {
      print('Wystąpił błąd podczas tworzenia reklamy: $e');
    }
    _firebaseService = Provider.of<FirebaseService>(context, listen: false);

    _animationController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )
      ..repeat(); // Powtarza animację w nieskończoność

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.1), weight: 0.05),
      TweenSequenceItem(tween: ConstantTween<double>(1.1), weight: 0.05),
      TweenSequenceItem(tween: Tween<double>(begin: 1.1, end: 1.0), weight: 0.05),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 0.85),
    ]).animate(_animationController);

  }

  Future<void> _checkPurchaseStatus() async {
    IAPService iapService = context.read<IAPService>();
    bool isPurchasedLocally = await SharedPreferencesHelper.getPurchaseState();
    /*
    if (isOnline) {
      bool isPurchaseValidOnline = await iapService.verifyPurchaseOnline();
      if (isPurchasedLocally != isPurchaseValidOnline) {
        iapService.setPurchased(isPurchaseValidOnline, true);
        print ('isPurchaseValidOnline : $isPurchaseValidOnline');
      }
    } else {
      iapService.setPurchased(isPurchasedLocally, true);
      print('Ustawilem: $isPurchasedLocally');
    }*/
    await iapService.setPurchased(isPurchasedLocally, true);
  }

  void _setupConnectivityListener() async {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) async {
      bool isConnected = result != ConnectivityResult.none;
      setState(() {
        isOnline = isConnected;
      });
      if(!_nativeAdLoaded) {
        context.read<AdMobService>().onConnectionChanged(isConnected);
      }
      if (isConnected) {
        //_checkPurchaseStatus();
        _firebaseService
            .updateConnectionStatusIfConnected(); // _firebaseService.signInAnonymouslyAndSaveUID(); to sie wykona ale poczeka na isConnected
        await _firebaseService.updateUserInformations(await SharedPreferencesHelper.getUserID(), 'howManyTimesRunApp', SharedPreferencesHelper.getHowManyTimesRunApp().toString());
        print("ISONLINE: $isConnected");
        print("${_firebaseService.currentUser}");
      }
    });
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    _nativeAd = null;
    _nativeAdLoaded = false;
    _connectivitySubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isOnline == true && _nativeAdLoaded == false) {
      context.read<AdMobService>().reloadAd();
    }
    _setupConnectivityListener();
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

    TeamScore.resetAllScores();
    return Container(
      decoration: BoxDecoration(
        gradient: Palette().backgroundLoadingSessionGradient,
      ),
      child: Scaffold(
        drawer: CustomAppDrawer(),
        key: scaffoldKey,
        appBar: CustomAppBarNoTitle(
          onMenuButtonPressed: () {
            audioController.playSfx(SfxType.buttonBackExit);
            scaffoldKey.currentState?.openDrawer();
          },
          title: '',
        ),
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(child: LogoWidget()),
                    ResponsiveSizing.responsiveHeightGapWithCondition(context, 30, 45, 650),
                    CustomStyledButton(
                      icon: Icons.question_mark,
                      text: getTranslatedString(context, 'game_rules', listen: true),
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
                      builder: (context, child) =>
                          Transform.scale(
                            scale: _scaleAnimation.value,
                            child: child,
                          ),
                      child: CustomStyledButton(
                        icon: Icons.play_arrow_rounded,
                        text: getTranslatedString(context, 'play_now'),
                        onPressed: () {
                          audioController.playSfx(SfxType.buttonAccept);
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
                        audioController.playSfx(SfxType.buttonBackExit);
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
                        audioController.playSfx(SfxType.buttonBackExit);
                        SystemNavigator.pop();
                      },
                      backgroundColor: Palette().bluegrey,
                      foregroundColor: Palette().menudark,
                      width: 200,
                      height: 45,
                      fontSize: ResponsiveSizing.scaleHeight(context, 20),
                    ),
                    Consumer<FirebaseService>(
                      builder: (context, firebaseService, child) {
                        //print('FIREBASE WIDGET z CONSUMERA: $uidUserLoaded');
                        return Text(
                          firebaseService.currentUser?.uid ?? 'Brak UID',
                          style: TextStyle(color: Colors.white),
                        );
                      },
                    ),
                    // Dodaj tutaj pozostałe widgety
                  ],
                ),
              ),
              Consumer<IAPService>(
                builder: (context, purchaseController, child) {
                  if (purchaseController.isPurchased) {
                    return SizedBox.shrink();
                  } else {
                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: Consumer<AdMobService>(
                        builder: (context, adMobService, child) {
                          if (isOnline && _nativeAdLoaded) {
                            return Container(
                              height: 50,
                              alignment: Alignment.center,
                              child: AdWidget(ad: _nativeAd!),
                            );
                          } else {
                            return SizedBox.shrink();
                          }
                        },
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
