import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../customAppBar/customAppBar.dart';
import '../drawer/drawer.dart';
import '../style/palette.dart';

class CardAdvertisementScreen extends StatelessWidget {
  const CardAdvertisementScreen({super.key, required this.scaffoldKey});
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    final customAppDrawer = CustomAppDrawer();
    final _gap = SizedBox(height: ResponsiveText.scaleHeight(context, 18));
    return Container(
      decoration: BoxDecoration(
        gradient: Palette().backgroundLoadingSessionGradient,
      ),
      child: Scaffold(
        key: scaffoldKey,
        drawer: CustomAppDrawer(),
        appBar: CustomAppBar(
          title: 'Kup Teraz!',
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
              ResponsiveText.customText(
                context,
                'Ekskluzywna przygoda z kartami na wyciągnięcie ręki!',
                Palette().pink,
                TextAlign.center,
                ResponsiveText.scaleHeight(context, 18),
              ),
              SvgPicture.asset(
                  'assets/time_to_party_assets/banner_cards_advert.svg',
                  width: MediaQuery.of(context).size.width < 400 ? ResponsiveText.scaleWidth(context, 260 * 130 / 212) : ResponsiveText.scaleWidth(context, 260),
                  height: MediaQuery.of(context).size.height < 650 ? ResponsiveText.scaleHeight(context, 130) : ResponsiveText.scaleHeight(context, 212),
              ),
              ResponsiveText.customText(
                context,
                'Zakup wersję UNLIMITED!',
                Palette().white,
                TextAlign.center,
                ResponsiveText.scaleHeight(context, 20),
              ),
              _gap,
              SvgPicture.asset(
                  'assets/time_to_party_assets/banner_cards_advert_linear.svg',
                  width: ResponsiveText.scaleWidth(context, 77),
                  height: ResponsiveText.scaleHeight(context, 40)),
              _gap,
              ResponsiveText.customText(
                context,
                'Odkryj pełen potencjał gry z niesamowitymi bonusami!',
                Palette().pink,
                TextAlign.center,
                ResponsiveText.scaleHeight(context, 18),
              ),
              Padding(
                padding: EdgeInsets.only( left: ResponsiveText.scaleWidth(context,90)), // Dodaje wypełnienie górne i dolne
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
                        ResponsiveText.customText(
                          context,
                          'Więcej zabawy!',
                          Palette().white,
                          TextAlign.center,
                          ResponsiveText.scaleHeight(context, 14),
                        ),
                      ],
                    ),
                    _gap,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          'assets/time_to_party_assets/banner_random_icon_advert.svg', // Podmień na ścieżkę do swojego obrazka SVG
                          height: ResponsiveText.scaleHeight(context, 24),
                          width: ResponsiveText.scaleWidth(context, 24),
                        ),
                        SizedBox(
                            width: ResponsiveText.scaleHeight(context, 10)),
                        ResponsiveText.customText(
                          context,
                          'Więcej losowych zdarzeń!',
                          Palette().white,
                          TextAlign.center,
                          ResponsiveText.scaleHeight(context, 14),
                        ),
                      ],
                    ),
                    _gap,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          'assets/time_to_party_assets/banner_timer_icon_advert.svg', // Podmień na ścieżkę do swojego obrazka SVG
                          height: ResponsiveText.scaleHeight(context, 24),
                          width: ResponsiveText.scaleWidth(context, 24),
                        ),
                        SizedBox(
                            width: ResponsiveText.scaleHeight(context,
                                10)),
                        ResponsiveText.customText(
                          context,
                          'Dłuższa i ciekawsza rozgrywka!',
                          Palette().white,
                          TextAlign.center,
                          ResponsiveText.scaleHeight(context, 14),
                        ),
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
                child: Text('8,99zł jednorazowo'),
              ),
              TextButton(
                onPressed: () async {
                  CustomAppDrawer.callPrivacyPolicyFunction(
                      context, customAppDrawer);
                },
                child:
                ResponsiveText.customText(
                  context,
                  'Polityka prywatności oraz regulamin danych osobowych',
                  Palette().white,
                  TextAlign.center,
                  ResponsiveText.scaleHeight(context, 14),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: ResponsiveText.customText(
                  context,
                  'Przywróć płatności',
                  Palette().white,
                  TextAlign.center,
                  ResponsiveText.scaleHeight(context, 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
