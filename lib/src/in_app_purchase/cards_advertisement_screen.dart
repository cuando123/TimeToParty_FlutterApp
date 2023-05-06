import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../customAppBar/customAppBar.dart';
import '../drawer/drawer.dart';
import '../style/palette.dart';
import '../app_lifecycle/translated_text.dart';

class CardAdvertisementScreen extends StatelessWidget {
  const CardAdvertisementScreen({super.key, required this.scaffoldKey});
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    final customAppDrawer = CustomAppDrawer();
    final _gap = SizedBox(height: MediaQuery.of(context).size.height < 650 ? ResponsiveText.scaleHeight(context, 18) : ResponsiveText.scaleHeight(context, 10));

    return Container(
      decoration: BoxDecoration(
        gradient: Palette().backgroundLoadingSessionGradient,
      ),
      child: Scaffold(
        key: scaffoldKey,
        drawer: CustomAppDrawer(),
        appBar: CustomAppBar(
          title: translatedText(context,'buy_now', 14, Palette().white),
          onMenuButtonPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _gap,
              translatedText(context, 'exclusive_adventure', 18, Palette().pink, textAlign: TextAlign.center),
              SvgPicture.asset(
                  'assets/time_to_party_assets/banner_cards_advert.svg',
                  width: MediaQuery.of(context).size.width < 400 ? ResponsiveText.scaleWidth(context, 260 * 130 / 212) : ResponsiveText.scaleWidth(context, 260),
                  height: MediaQuery.of(context).size.height < 650 ? ResponsiveText.scaleHeight(context, 130) : ResponsiveText.scaleHeight(context, 212),
              ),
             translatedText(context, 'buy_unlimited_version', 20, Palette().white, textAlign: TextAlign.center),
              _gap,
              SvgPicture.asset(
                  'assets/time_to_party_assets/banner_cards_advert_linear.svg',
                  width: ResponsiveText.scaleWidth(context, 77),
                  height: ResponsiveText.scaleHeight(context, 40)),
              _gap,
              translatedText(context, 'discover_the_full_potential', 18, Palette().pink, textAlign: TextAlign.center),
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width < 380 || MediaQuery.of(context).size.width > 500
                    ? ResponsiveText.scaleWidth(context, 90)
                    : ResponsiveText.scaleWidth(context, 65),
              ),
                child: Column(
                  children: [
                    _gap,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/time_to_party_assets/banner_baloon_icon_advert.png',
                          height: ResponsiveText.scaleHeight(context, 29),
                          width: ResponsiveText.scaleHeight(context, 24),
                        ),
                        SizedBox(
                            width: ResponsiveText.scaleWidth(context, 10)),
                        translatedText(context, 'more_fun', 14, Palette().white, textAlign: TextAlign.center),
                      ],
                    ),
                    _gap,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          'assets/time_to_party_assets/banner_random_icon_advert.svg',
                          height: ResponsiveText.scaleHeight(context, 24),
                          width: ResponsiveText.scaleWidth(context, 24),
                        ),
                        SizedBox(
                            width: ResponsiveText.scaleHeight(context, 10)),
                        translatedText(context, 'more_random_events', 14, Palette().white, textAlign: TextAlign.center),
                      ],
                    ),
                    _gap,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          'assets/time_to_party_assets/banner_timer_icon_advert.svg',
                          height: ResponsiveText.scaleHeight(context, 24),
                          width: ResponsiveText.scaleWidth(context, 24),
                        ),
                        SizedBox(
                            width: ResponsiveText.scaleHeight(context,
                                10)),
                        translatedText(context, 'longer_and_more_interesting_gameplay', 14, Palette().white, textAlign: TextAlign.center),
                      ],
                    ),
                  ],
                ),
              ),
              _gap,
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette().pink, // color
                  foregroundColor: Palette().white, // textColor
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize:
                      Size(ResponsiveText.scaleWidth(context, 95), ResponsiveText.scaleHeight(context, 41)),
                  textStyle: TextStyle(
                      fontFamily: 'HindMadurai',
                      fontSize: ResponsiveText.scaleHeight(context, 20)),
                ),
                onPressed: () {},
                child: translatedText(context, 'pay_once', 20, Palette().white),
              ),
              TextButton(
                onPressed: () async {
                  CustomAppDrawer.callPrivacyPolicyFunction(
                      context, customAppDrawer);
                },
                child:
                translatedText(context, 'privacy_policy_and_personal_data', 14, Palette().white, textAlign: TextAlign.center),
              ),
              TextButton(
                onPressed: () {},
                child:translatedText(context, 'restore_purchases', 14, Palette().white, textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
