import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:game_template/main.dart';
import 'package:game_template/src/in_app_purchase/services/iap_service.dart';
import 'package:game_template/src/play_session/alerts_and_dialogs.dart';
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
  'com.frydoapps.timetoparty.fullversion'
];

class _CardAdvertisementScreenState extends State<CardAdvertisementScreen> {
  late IAPService _iapService;

  @override
  void initState() {
    super.initState();
    _iapService = IAPService(InAppPurchase.instance); // Tworzenie instancji IAPService
    _iapService.initializePurchaseStream(); // Inicjalizacja strumienia zakupów
    _iapService.initStoreInfo(productIds); // Ładowanie informacji o produktach

    _iapService.onPurchaseComplete(() {
      setState(() {
        // Aktualizuj stan po pomyślnym zakupie, np. wywołaj dialog
        AnimatedAlertDialog.showThanksPurchaseDialog(context);
      });
    });
  }

  Widget? _getIAPIcon(productId){
    if(productId == "premium_yt"){
      return Icon(Icons.brightness_7_outlined, size: 50);
    } else if (productId == "unlimited"){
      return Icon(Icons.brightness_5, size: 50);
    } //and so on....
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final audioController = context.watch<AudioController>();

    return WillPopScope(
      onWillPop: () async {
        audioController.playSfx(SfxType.button_back_exit);
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
              audioController.playSfx(SfxType.button_back_exit);
              widget.scaffoldKey.currentState?.openDrawer();
            },
              onBackButtonPressed:(){
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
          ),
          body:
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
                                audioController.playSfx(SfxType.button_back_exit);
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
                                audioController.playSfx(SfxType.button_back_exit);
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
                                audioController.playSfx(SfxType.button_back_exit);
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
                          audioController.playSfx(SfxType.button_back_exit);
                          //IAP:
                          _iapService.buyProduct(productIds);
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
                          audioController.playSfx(SfxType.button_back_exit);
                          await globalLoading.privacy_policy_function(context);
                        },
                        child: translatedText(context, 'privacy_policy_and_personal_data', 14, Palette().white,
                            textAlign: TextAlign.center),
                      ),
                      TextButton(
                        onPressed: () {
                          audioController.playSfx(SfxType.button_back_exit);
                        },
                        child: translatedText(context, 'restore_purchases', 14, Palette().white,
                            textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                ),
              ]),
            ),],
          )

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
                    audioController.playSfx(SfxType.button_back_exit);
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
                    audioController.playSfx(SfxType.button_back_exit);
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
                    audioController.playSfx(SfxType.button_back_exit);
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
