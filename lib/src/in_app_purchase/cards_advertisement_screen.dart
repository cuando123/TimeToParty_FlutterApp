import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:game_template/main.dart';
import 'package:game_template/src/in_app_purchase/services/iap_service.dart';
import 'package:game_template/src/play_session/alerts_and_dialogs.dart';
import 'package:game_template/src/play_session/extensions.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
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

class _CardAdvertisementScreenState extends State<CardAdvertisementScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Zachowaj stan
  late IAPService _iapService;
  bool isOnline = false;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _iapService = Provider.of<IAPService>(context, listen: true);
      print("IS LOADING CARD ADS: ${_iapService.isLoading}");
      _setupConnectivityListener();
      _iapService.initializePurchaseStream();
      _iapService.onPurchaseComplete(() {
        safeSetState(() {
          // Aktualizuj stan po pomyślnym zakupie, np. wywołaj dialog
          AnimatedAlertDialog.showPurchaseDialogs(context, "PurchaseSuccess");
          print("IS PURCHASED: ${_iapService.isPurchased}");
        });
      });
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
      child: Container(
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
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                audioController.playSfx(SfxType.buttonBackExit);
                                showDialogMoreRandomEvents(context);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SvgPicture.asset(
                                    'assets/time_to_party_assets/banner_random_icon_advert.svg',
                                    height: ResponsiveSizing.scaleHeight(context, 24),
                                    width: ResponsiveSizing.scaleWidth(context, 24),
                                  ),
                                  ResponsiveSizing.responsiveWidthGap(context, 10),
                                  translatedText(context, 'more_random_events', 14, Palette().white,
                                      textAlign: TextAlign.center),
                                  ResponsiveSizing.responsiveWidthGap(context, 10),
                                  Icon(Icons.arrow_back, color: Colors.white),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                audioController.playSfx(SfxType.buttonBackExit);
                                showDialogLongerGameplay(context);
                              },
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
                              ),
                            ),
                          ],
                        ),
                      ),
                      CustomStyledButton(
                        icon: null,
                        text: getTranslatedString(context, 'pay_once'),
                        onPressed: () {
                          audioController.playSfx(SfxType.buttonBackExit);
                          _iapService.onPurchaseErrorsComplete(() { //IAP obsługa błędów
                            AnimatedAlertDialog.showPurchaseDialogs(context, _iapService.billingResponsesErrors);
                          });
                          //IAP kupno i alert gdy brak internetu
                          if (_iapService.isLoading == false) {
                            if (isOnline == true) {
                              _iapService.buyProduct(productIds);
                            } else {
                              AnimatedAlertDialog.showPurchaseDialogs(context, 'NoInternetConnection');
                            }
                          } else {
                            AnimatedAlertDialog.showPurchaseDialogs(context, 'BillingResponse.pending');
                          }
                          //symulacja zakupu
                          //var provider = Provider.of<IAPService>(context, listen: false);
                          //provider.setPurchased(true);
                          //AnimatedAlertDialog.showThanksPurchaseDialog(context);
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
                        onPressed: () async {
                          audioController.playSfx(SfxType.buttonBackExit);
                          await _iapService.restorePurchases();
                          _iapService.onPurchaseComplete(() {
                            setState(() {
                              // Aktualizuj stan po pomyślnym zakupie, np. wywołaj dialog
                              AnimatedAlertDialog.showPurchaseDialogs(context, "PurchaseRestored");
                            });
                          });
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
      ),
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
          title: translatedText(context, 'more_random_events', 18, Palette().pink, textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SvgPicture.asset('assets/time_to_party_assets/line_instruction_screen.svg'),
              ),
              ResponsiveSizing.responsiveHeightGapWithCondition(context, 18, 10, 650),
              translatedText(context, 'more_random_events_description', 16, Palette().menudark,
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
