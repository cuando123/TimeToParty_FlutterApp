import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../app_lifecycle/TranslationProvider.dart';
import '../app_lifecycle/responsive_sizing.dart';
import '../app_lifecycle/translated_text.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../customAppBar/customAppBar.dart';
import '../drawer/drawer.dart';
import '../play_session/custom_style_buttons.dart';
import '../style/palette.dart';

class LanguageSelector extends StatefulWidget {
  const LanguageSelector({super.key, required this.scaffoldKey});
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  _LanguageSelectorState createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  static final scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          final audioController = context.read<AudioController>();
          audioController.playSfx(SfxType.button_back_exit);
          GoRouter.of(context).go('/');
          return false;
        },
        child:
    Container(
      decoration: BoxDecoration(
        gradient: Palette().backgroundLoadingSessionGradient,
      ),
      child: Scaffold(
        drawer: CustomAppDrawer(),
        key: scaffoldKey,
        appBar: CustomAppBar(
          title: translatedText(context,'select_language', 14, Palette().white),
          onMenuButtonPressed: () {
            final audioController = context.read<AudioController>();
            audioController.playSfx(SfxType.button_back_exit);
            scaffoldKey.currentState?.openDrawer();
          },
        ),
        body:
        Padding(
          padding: EdgeInsets.fromLTRB(
          10.0, 10.0, 10.0, 2.0),
    child: Column(
          children: [
            LogoWidget_notitle(),
            translatedText(context, 'language_change_notification', 14, Palette().white, textAlign: TextAlign.center),
            ResponsiveSizing.responsiveHeightGap(context, 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 3,
                children: [
                  languageButton(context, 'English',
                      'assets/time_to_party_assets/flags/united_kingdom.svg', 'EN_en'),
                  languageButton(context, 'Deutsch',
                      'assets/time_to_party_assets/flags/germany.svg', 'DE_de'),
                  languageButton(context, 'Italiano',
                      'assets/time_to_party_assets/flags/italy.svg', 'IT_it'),
                  languageButton(context, 'Español',
                      'assets/time_to_party_assets/flags/spain.svg', 'ES_es'),
                  languageButton(context,
                      'Polski', 'assets/time_to_party_assets/flags/poland.svg', 'PL_pl'),
                  languageButton(context, 'Français',
                      'assets/time_to_party_assets/flags/france.svg', 'FR_fr'),
                ],
              ),
            ),
          ],),
        ),
      ),),
    );
  }

  Widget languageButton(BuildContext context, String language, String path, String langPrefix) {
    final audioController = context.read<AudioController>();

    return Padding(
      padding: EdgeInsets.all(8.0),
      child: CustomStyledButton(
        svgAsset: path, // Ścieżka do pliku SVG
        text: language,
        onPressed: () async {
          audioController.playSfx(SfxType.button_back_exit);
          await Provider.of<TranslationProvider>(context, listen: false)
              .changeLanguage(langPrefix);
          Navigator.of(context).popUntil((route) => route.isFirst);
          scaffoldKey.currentState?.openEndDrawer();
          showLanguageChangedSnackbar(context);
        },
        backgroundColor: Color(0xFF434347), // Dostosuj kolor tła
        foregroundColor: Palette().bluegrey, // Dostosuj kolor tekstu
        width: 200, // Dostosuj szerokość
        height: 45, // Dostosuj wysokość
        fontSize: ResponsiveSizing.scaleHeight(context, 16), // Dostosuj rozmiar czcionki
      ),
    );
  }


  void showLanguageChangedSnackbar(BuildContext context) {
    final snackBar = SnackBar(
      content: translatedText(context,'language_changed', 14, Palette().white, textAlign: TextAlign.center),
      duration: Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}


