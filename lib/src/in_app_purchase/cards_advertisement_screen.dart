import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:game_template/main.dart';
import 'package:game_template/src/in_app_purchase/services/firebase_service.dart';
import 'package:game_template/src/in_app_purchase/services/iap_service.dart';
import 'package:game_template/src/play_session/alerts_and_dialogs.dart';
import 'package:game_template/src/play_session/extensions.dart';
import 'package:provider/provider.dart';

import '../app_lifecycle/responsive_sizing.dart';
import '../app_lifecycle/translated_text.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../customAppBar/customAppBar.dart';
import '../drawer/drawer.dart';
import '../play_session/custom_style_buttons.dart';
import '../style/palette.dart';

class CardAdvertisementScreen extends StatefulWidget {
  const CardAdvertisementScreen({
    required Key key,
    required this.scaffoldKey,
  }) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  _CardAdvertisementScreenState createState() => _CardAdvertisementScreenState();
}

const List<String> productIds =<String>[
  'timetoparty.fullversion.test'
];

class _CardAdvertisementScreenState extends State<CardAdvertisementScreen> with SingleTickerProviderStateMixin{
  bool _alertShown = false;
  late IAPService _iapService;
  bool isOnline = false;
  late FirebaseService _firebaseService;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  bool _isInitialized = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimationLine1;
  late Animation<double> _scaleAnimationLine2;
  late Animation<double> _scaleAnimationLine3;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _scaleAnimationLine1 = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.1), weight: 0.05),
      TweenSequenceItem(tween: ConstantTween<double>(1.1), weight: 0.05),
      TweenSequenceItem(tween: Tween<double>(begin: 1.1, end: 1.0), weight: 0.05),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 0.85),
    ]).animate(_animationController);

    _scaleAnimationLine2 = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 0.4),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.1), weight: 0.05),
      TweenSequenceItem(tween: ConstantTween<double>(1.1), weight: 0.05),
      TweenSequenceItem(tween: Tween<double>(begin: 1.1, end: 1.0), weight: 0.05),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 0.45),
    ]).animate(_animationController);

    _scaleAnimationLine3 = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 0.6),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.1), weight: 0.05),
      TweenSequenceItem(tween: ConstantTween<double>(1.1), weight: 0.05),
      TweenSequenceItem(tween: Tween<double>(begin: 1.1, end: 1.0), weight: 0.05),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 0.25),
    ]).animate(_animationController);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _firebaseService = Provider.of<FirebaseService>(context, listen: false);
      _iapService = Provider.of<IAPService>(context, listen: true);
      print("IS LOADING CARD ADS: ${_iapService.isLoading}");
      _setupConnectivityListener();
      _iapService.initializePurchaseStream();
      _isInitialized = true;
      setState(() {});
    }
  }

    void _setupConnectivityListener() async {
    // Sprawdzenie początkowego stanu połączenia
    var initialResult = await _connectivity.checkConnectivity();
    bool isConnected = initialResult != ConnectivityResult.none;
    safeSetState(() {
      isOnline = isConnected;
    });
    if (isConnected) {
      await _iapService.initStoreInfo(productIds);
    }
    // Ustawienie listenera na zmiany stanu połączenia
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      isConnected = result != ConnectivityResult.none;
      print('isConnected: $isConnected');
      safeSetState(() {
        isOnline = isConnected;
      });
      if (isConnected) {
        _iapService.initStoreInfo(productIds);
      }
    });
  }


  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _alertShown = false; // Resetowanie flagi przy opuszczaniu ekranu
    _animationController.dispose();
    super.dispose();
  }

  Widget _loadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5), // Przyciemnione tło
      child: Center(
        child: CircularProgressIndicator(color: Palette().pink),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioController = context.watch<AudioController>();
    return WillPopScope(
        onWillPop: () async {
          audioController.playSfx(SfxType.buttonBackExit);
          Navigator.of(context).popUntil((route) => route.isFirst);
          return false;
        },
      child: Consumer<IAPService>(
        builder: (context, iapService, child) {
          if (!_alertShown && iapService.purchaseStatusMessage.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Wyświetlenie odpowiedniego AlertDialog
              AnimatedAlertDialog.showPurchaseDialogs(context, iapService.purchaseStatusMessage);
              iapService.resetPurchaseStatusMessage(); // Resetowanie wiadomości po wyświetleniu alertu
              _alertShown = true; // Ustawienie flagi, że alert został pokazany
            });
          }
      return Container(
        decoration: BoxDecoration(
          gradient: Palette().backgroundLoadingSessionGradient,
        ),
        child: Scaffold(
          key: widget.scaffoldKey,
          drawer: CustomAppDrawer(),
          appBar: CustomAppBar(
            title: translatedText(context, 'buy_now', 14, Palette().white),
            onMenuButtonPressed: () {
              audioController.playSfx(SfxType.buttonBackExit);
              widget.scaffoldKey.currentState?.openDrawer();
            },
              onBackButtonPressed:(){
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
          ),
          body: Stack(
              children: <Widget>[
          ListView(
            children: [Padding(
              padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 2.0),
              child: Stack(children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ResponsiveSizing.responsiveHeightGapWithCondition(context, 18, 10, 650),
                      translatedText(context, 'exclusive_adventure', 18, Palette().pink, textAlign: TextAlign.center),
                      SvgPicture.asset(
                        'assets/time_to_party_assets/banner_cards_advert.svg',
                        //width: ResponsiveSizing.responsiveWidthWithCondition(context, 160, 260, 400),
                        height: ResponsiveSizing.responsiveHeightWithCondition(context, 125, 210, 650),
                      ),
                      translatedText(context, 'buy_unlimited_version', 20, Palette().white, textAlign: TextAlign.center),
                      ResponsiveSizing.responsiveHeightGapWithCondition(context, 18, 10, 650),
                      SvgPicture.asset('assets/time_to_party_assets/banner_cards_advert_linear.svg',
                          width: ResponsiveSizing.scaleWidth(context, 77),
                          height: ResponsiveSizing.scaleHeight(context, 40)),
                      translatedText(context, 'discover_the_full_potential', 18, Palette().pink,
                          textAlign: TextAlign.center),
                      Center(
                        child: Column(
                          children: [
                            TextButton(
                              onPressed: () {
                                audioController.playSfx(SfxType.buttonBackExit);
                                showDialogMoreFun(context);
                              },
                              child:
                              AnimatedBuilder(
                                animation: _scaleAnimationLine1,
                                builder: (context, child) => Transform.scale(
                                  scale: _scaleAnimationLine1.value,
                                  child: child,
                                ),
                                child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Image.asset(
                                    'assets/time_to_party_assets/banner_baloon_icon_advert.png',
                                    height: ResponsiveSizing.scaleHeight(context, 29),
                                    width: ResponsiveSizing.scaleHeight(context, 24),
                                  ),
                                  ResponsiveSizing.responsiveWidthGap(context, 10),
                                  translatedText(context, 'more_fun', 14, Palette().white, textAlign: TextAlign.center),
                                  ResponsiveSizing.responsiveWidthGap(context, 10),
                                  Icon(Icons.arrow_back, color: Colors.white),
                                ],
                              ),),
                            ),
                            TextButton(
                              onPressed: () {
                                audioController.playSfx(SfxType.buttonBackExit);
                                showDialogMoreRandomEvents(context);
                              },
                              child: AnimatedBuilder(
                                animation: _scaleAnimationLine2,
                                builder: (context, child) => Transform.scale(
                                  scale: _scaleAnimationLine2.value,
                                  child: child,
                                ),
                                child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SvgPicture.asset(
                                    'assets/time_to_party_assets/no_ads_icon.svg',
                                    height: ResponsiveSizing.scaleHeight(context, 34),
                                    width: ResponsiveSizing.scaleWidth(context, 34),
                                  ),
                                  ResponsiveSizing.responsiveWidthGap(context, 10),
                                  translatedText(context, 'no_ads', 14, Palette().white,
                                      textAlign: TextAlign.center),
                                  ResponsiveSizing.responsiveWidthGap(context, 10),
                                  Icon(Icons.arrow_back, color: Colors.white),
                                ],
                              ),),
                            ),
                            TextButton(
                              onPressed: () {
                                audioController.playSfx(SfxType.buttonBackExit);
                                showDialogLongerGameplay(context);
                              },
                              child: AnimatedBuilder(
                                animation: _scaleAnimationLine3,
                                builder: (context, child) => Transform.scale(
                                  scale: _scaleAnimationLine3.value,
                                  child: child,
                                ),
                                child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SvgPicture.asset(
                                    'assets/time_to_party_assets/banner_timer_icon_advert.svg',
                                    height: ResponsiveSizing.scaleHeight(context, 24),
                                    width: ResponsiveSizing.scaleWidth(context, 24),
                                  ),
                                  ResponsiveSizing.responsiveWidthGap(context, 10),
                                  translatedText(context, 'longer_and_more_interesting_gameplay', 14, Palette().white,
                                      textAlign: TextAlign.center),
                                  ResponsiveSizing.responsiveWidthGap(context, 10),
                                  Icon(Icons.arrow_back, color: Colors.white),
                                ],
                              ),),
                            ),
                          ],
                        ),
                      ),
                      CustomStyledButton(
                        icon: null,
                        text: getTranslatedString(context, 'pay_once'),
                        onPressed: () {
                          _alertShown = false; // Resetowanie flagi przed nowym zakupem
                          audioController.playSfx(SfxType.buttonBackExit);
                          if (_firebaseService.currentUser?.uid == null){
                            _iapService.setPurchaseStatusMessage('BillingResponse.serviceUnavailable');
                          } else {
                            if (_iapService.isLoading == false) {
                              if (isOnline) {
                                _iapService.buyProduct(productIds);
                              } else {
                                _iapService.setPurchaseStatusMessage('NoInternetConnection');
                              }
                            } else {
                              _iapService.setPurchaseStatusMessage('BillingResponse.pending');
                            }
                          }
                        },
                        backgroundColor: Palette().pink,
                        foregroundColor: Palette().white,
                        width: 200,
                        height: 45,
                        fontSize: ResponsiveSizing.scaleHeight(context, 20),
                      ),
                      TextButton(
                        onPressed: () async {
                          audioController.playSfx(SfxType.buttonBackExit);
                          await globalLoading.privacy_policy_function(context);
                        },
                        child: translatedText(context, 'privacy_policy_and_personal_data', 14, Palette().white,
                            textAlign: TextAlign.center),
                      ),
                      TextButton(
                        onPressed: () {
                          _alertShown = false;
                          audioController.playSfx(SfxType.buttonBackExit);
                          if (_iapService.isLoading == false) {
                            if (isOnline) {
                              print('PRODUCT IDS: $productIds');
                              _iapService.restorePurchases();
                            } else {
                              _iapService.setPurchaseStatusMessage('NoInternetConnection');
                            }
                          }
                        },
                        child: translatedText(context, 'restore_purchases', 14, Palette().white,
                            textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                ),
              ]),
            ),],
          ),
                Consumer<IAPService>(
                  builder: (context, iapService, child) {
                    if (iapService.isLoading) {
                      return _loadingOverlay();
                    } else {
                      return SizedBox.shrink();
                    }
                  },
                ),
              ],
          ),
        ),
      );},),
    );
  }

  void showDialogMoreFun(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final audioController = context.watch<AudioController>();
        return AlertDialog(
          backgroundColor: Palette().white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: translatedText(context, 'more_fun', 18, Palette().pink, textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SvgPicture.asset('assets/time_to_party_assets/line_instruction_screen.svg'),
              ),
              ResponsiveSizing.responsiveHeightGapWithCondition(context, 18, 10, 650),
        Center(child:
              SvgPicture.asset(
                'assets/time_to_party_assets/instruction_cards_linear_2.svg',
                height: ResponsiveSizing.scaleHeight(context, 75)
              )),
              ResponsiveSizing.responsiveHeightGapWithCondition(context, 18, 10, 650),
              translatedText(context, 'more_fun_description', 16, Palette().menudark, textAlign: TextAlign.center),
              ResponsiveSizing.responsiveHeightGapWithCondition(context, 18, 10, 650),
              Center(
                child: CustomStyledButton(
                  icon: null,
                  text: 'OK',
                  onPressed: () {
                    audioController.playSfx(SfxType.buttonBackExit);
                    Navigator.of(context).pop();
                  },
                  backgroundColor: Palette().pink,
                  foregroundColor: Palette().white,
                  width: 200,
                  height: 45,
                  fontSize: ResponsiveSizing.scaleHeight(context, 20),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showDialogMoreRandomEvents(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final audioController = context.watch<AudioController>();
        return AlertDialog(
          backgroundColor: Palette().white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: translatedText(context, 'no_ads', 18, Palette().pink, textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SvgPicture.asset('assets/time_to_party_assets/line_instruction_screen.svg'),
              ),
              ResponsiveSizing.responsiveHeightGapWithCondition(context, 18, 10, 650),
              Center(child:
              SvgPicture.asset(
                'assets/time_to_party_assets/no_ads_icon.svg',
                height: ResponsiveSizing.scaleHeight(context, 74),
                width: ResponsiveSizing.scaleWidth(context, 74),
              )),
              ResponsiveSizing.responsiveHeightGapWithCondition(context, 18, 10, 650),
              translatedText(context, 'no_ads_description', 16, Palette().menudark,
                  textAlign: TextAlign.center),
              ResponsiveSizing.responsiveHeightGapWithCondition(context, 18, 10, 650),
              Center(
                child: CustomStyledButton(
                  icon: null,
                  text: 'OK',
                  onPressed: () {
                    audioController.playSfx(SfxType.buttonBackExit);
                    Navigator.of(context).pop();
                  },
                  backgroundColor: Palette().pink,
                  foregroundColor: Palette().white,
                  width: 200,
                  height: 45,
                  fontSize: ResponsiveSizing.scaleHeight(context, 20),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showDialogLongerGameplay(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final audioController = context.watch<AudioController>();
        return AlertDialog(
          backgroundColor: Palette().white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: translatedText(context, 'longer_and_more_interesting_gameplay', 20, Palette().pink,
              textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SvgPicture.asset('assets/time_to_party_assets/line_instruction_screen.svg'),
              ),
              ResponsiveSizing.responsiveHeightGapWithCondition(context, 18, 10, 650),
              Center(child:
              SvgPicture.asset(
                'assets/time_to_party_assets/banner_timer_icon_advert.svg',
                height: ResponsiveSizing.scaleHeight(context, 74),
                width: ResponsiveSizing.scaleWidth(context, 74),
                color: Colors.black,
              )),
              ResponsiveSizing.responsiveHeightGapWithCondition(context, 18, 10, 650),
              translatedText(context, 'longer_and_more_interesting_gameplay_description', 16, Palette().menudark,
                  textAlign: TextAlign.center),
              ResponsiveSizing.responsiveHeightGapWithCondition(context, 18, 10, 650),
              Center(
                child: CustomStyledButton(
                  icon: null,
                  text: 'OK',
                  onPressed: () {
                    audioController.playSfx(SfxType.buttonBackExit);
                    Navigator.of(context).pop();
                  },
                  backgroundColor: Palette().pink,
                  foregroundColor: Palette().white,
                  width: 200,
                  height: 45,
                  fontSize: ResponsiveSizing.scaleHeight(context, 20),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
