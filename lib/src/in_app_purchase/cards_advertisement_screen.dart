import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:game_template/main.dart';
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
import 'in_app_purchase.dart';

class CardAdvertisementScreen extends StatefulWidget {
  const CardAdvertisementScreen({
    required Key key,
    required this.scaffoldKey,
  }) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  _CardAdvertisementScreenState createState() => _CardAdvertisementScreenState();
}

const List<String> _productIds =<String>[
  'com.frydoapps.timetoparty.fullversion'
];

class _CardAdvertisementScreenState extends State<CardAdvertisementScreen> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  bool _isAvailable = false;
  String? _notice;
  List<ProductDetails> _products = [];
  @override
  void initState() {
    super.initState();
    initStoreInfo();
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    setState(() {
      _isAvailable = isAvailable;
    });

    if (!_isAvailable){
      setState(() {
        _notice = "There are no upgrades at this time";
      });
      return;
    }

    setState(() {
      _notice = "There is a connection to the store!";
    });
    //get iap
    ProductDetailsResponse productDetailsResponse = await _inAppPurchase.queryProductDetails(_productIds.toSet());
    setState(() {
      _products = productDetailsResponse.productDetails;
      print(_products);
      print("not found products: ${productDetailsResponse.notFoundIDs}");
    });
    if (productDetailsResponse.error != null){
      setState(() {
        _notice = "There was a problem connecting to the store";
      });
    }else if(productDetailsResponse.productDetails.isEmpty){
      setState(() {
        _notice = "There are no uprgrades at this time";
      });
    }
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
    //final PurchaseParam purchaseParam = PurchaseParam(productDetails: _products[0]);

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
                      //IAP tutorial
                      /*
                      if(_notice != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(_notice!),
                        ),
                      Expanded(
                        child: ListView.builder(
                            itemCount: _products.length,
                            itemBuilder: (context, index){
                              final ProductDetails productDetails = _products[index];
                              return Card(
                                child: Row(
                                  children: [
                                    //_getIAPIcon(productDetails.id), itd robił potem ikonki ktore wyswietlaly sie w zaleznosci od pobranego produktu
                                    Column(
                                      children: [
                                        Text(productDetails.title, style: Theme.of(context).textTheme.headlineMedium),
                                        Text(productDetails.description, style: Theme.of(context).textTheme.headlineSmall)
                                      ],
                                    ),
                                  ],
                                )
                              );
                            })
                      ),*/

                      //IAP tutorial
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
                          if (_products.isNotEmpty) {
                          if (_products[0] == 'premium'){
                          //  InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
                          } // non consunable..
                          else {
                           // InAppPurchase.instance.buyConsumable(purchaseParam: _products[1]); for example
                          }}

                          //symulacja zakupu

                          var provider = Provider.of<InAppPurchaseController>(context, listen: false);
                          provider.setPurchased(true);
                          AnimatedAlertDialog.showThanksPurchaseDialog(context);
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
