import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../customAppBar/customAppBar.dart';
import '../drawer/drawer.dart';
import '../style/palette.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({Key? key, required this.scaffoldKey})
      : super(key: key);
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: Palette().backgroundLoadingSessionGradient,
      ),
      child: Scaffold(
        key: scaffoldKey,
        drawer: CustomAppDrawer(),
        appBar: CustomAppBar(
          title: 'Zmień język',
          onMenuButtonPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
        ),
        body: Column(
          children: [
            Container(
              height: ResponsiveText.scaleHeight(context, 155), // Określ wysokość wg własnego uznania
              child: LogoWidget_notitle(),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 3,
                children: [
                  languageButton(context, 'English',
                      'assets/time_to_party_assets/flags/united_kingdom.svg'),
                  languageButton(context, 'Deutsch',
                      'assets/time_to_party_assets/flags/germany.svg'),
                  languageButton(context, 'Italiano',
                      'assets/time_to_party_assets/flags/italy.svg'),
                  languageButton(context, 'Español',
                      'assets/time_to_party_assets/flags/spain.svg'),
                  languageButton(context,
                      'Polski', 'assets/time_to_party_assets/flags/poland.svg'),
                  languageButton(context, 'Français',
                      'assets/time_to_party_assets/flags/france.svg'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget languageButton(BuildContext context, String language, String path) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextButton.icon(
        onPressed: () {
          // Dodaj obsługę kliknięcia przycisku
        },
        icon: SvgPicture.asset(path),
        label: Text(language,
            style: TextStyle(
              color: Palette().bluegrey,
              fontFamily: 'HindMadurai',
              fontSize: ResponsiveText.scaleHeight(context, 16),
            )),
        style: TextButton.styleFrom(
          backgroundColor: Color(0xFF434347),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.0),
          ),
        ),
      ),
    );
  }
}

class LogoWidget_notitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height < 650
              ? 1
              : ResponsiveText.scaleHeight(context, 20)),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/time_to_party_assets/all_stars_title.svg',
            width: ResponsiveText.scaleWidth(context, 261),
            height: ResponsiveText.scaleHeight(context, 126),
          ),
        ],
      ),);
  }
}

