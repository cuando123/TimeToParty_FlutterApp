import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:game_template/src/app_lifecycle/translated_text.dart';
import 'package:game_template/src/play_session/alerts_and_dialogs.dart';
import 'package:game_template/src/play_session/custom_style_buttons.dart';
import 'package:game_template/src/win_game/triple_button_win.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../ads/ads_controller.dart';
import '../ads/banner_ad_widget.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../customAppBar/customAppBar.dart';
import '../customAppBar/customAppBar_notitle.dart';
import '../drawer/drawer.dart';
import '../games_services/score.dart';
import '../in_app_purchase/in_app_purchase.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';

class WinGameScreen extends StatelessWidget {
  final List<String> teamNames;
  final List<Color> teamColors;

  WinGameScreen({super.key, required this.teamNames, required this.teamColors});

  @override
  Widget build(BuildContext context) {
    final adsControllerAvailable = context.watch<AdsController?>() != null;
    final adsRemoved = context.watch<InAppPurchaseController?>()?.adRemoval.active ?? false;
    final palette = context.watch<Palette>();
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final audioController = context.watch<AudioController>();
    // Sortowanie drużyn według wyników
    final List<Map<String, dynamic>> sortedTeams = List.generate(
      teamNames.length,
      (index) => {
        'name': teamNames[index],
        'color': teamColors[index],
        'score': TeamScore.getTeamScore(teamNames[index], teamColors[index]).getTotalScore(),
        'round': TeamScore.getRoundNumber(teamNames[index], teamColors[index])
        //
      },
    )..sort((a, b) => b['score'].compareTo(a['score']) as int);
    return WillPopScope(
      onWillPop: () async => false, // Zablokowanie możliwości cofnięcia
      child: Container(
        decoration: BoxDecoration(
          gradient: Palette().backgroundLoadingSessionGradient,
        ),
        child:
     Scaffold(
       drawer: CustomAppDrawer(),
       key: scaffoldKey,
       appBar: CustomAppBar(
         onMenuButtonPressed: () {
           audioController.playSfx(SfxType.button_back_exit);
           scaffoldKey.currentState?.openDrawer();
         },
         onBackButtonPressed: () {
           audioController.playSfx(SfxType.button_back_exit);
           Navigator.of(context).popUntil((route) => route.isFirst);
         },
         title: letsText(context, 'Congratulations!', 14, Palette().white),
       ),
      body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/time_to_party_assets/win_screen/team_ranking_win.png',
                  height: ResponsiveSizing.scaleHeight(context, 150)),
              Padding(padding: EdgeInsets.all(5.0), child: letsText(context, 'TEAM RANKING', 28, Palette().white)),
              if (adsControllerAvailable && !adsRemoved) ...[
                const Expanded(
                  child: Center(
                    child: BannerAdWidget(),
                  ),
                ),
              ],
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.3), width: 1), // Rozowa linia obramowania
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.001, 1.0],
                      colors: [
                        Palette().pink.withOpacity(0.2), // Rozpoczyna się od rozowego
                        Colors.transparent, // Przechodzi w przezroczystość
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurpleAccent.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: Offset(-2, -2), // Cień wewnętrzny górny-lewy
                      ),
                      BoxShadow(
                        color: Colors.deepPurpleAccent.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: Offset(2, 2), // Cień wewnętrzny dolny-prawy
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8,horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(width: 10),
                            Expanded(
                              child: Text('COLOR', style: columnTitleStyle),
                            ),
                            Expanded(
                              child: Text('TEAM', style: columnTitleStyle),
                            ),
                            Expanded(
                              child: Text('ROULETTE', textAlign: TextAlign.center, style: columnTitleStyle),
                            ),
                            Expanded(
                              child: Text('POINTS', textAlign: TextAlign.center, style: columnTitleStyle),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: sortedTeams.length,
                          itemBuilder: (context, index) {
                            return Container(
                              height: 50,
                              margin: EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 21), // Margines dla każdego elementu listy
                              decoration: BoxDecoration(
                                color: Colors.transparent, // Różowe tło dla elementu listy
                                borderRadius: BorderRadius.circular(5), // Zaokrąglenie rogów dla elementu listy
                                border: Border.all(color: Palette().pink, width: 1),
                              ),
                              child: ListTile(
                                leading: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: sortedTeams[index]['color'] as Color,
                                  ),
                                  width: 24,
                                  height: 24,
                                ),
                                title: letsText(context, sortedTeams[index]['name'] as String, 14, Palette().white),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SvgPicture.asset('assets/time_to_party_assets/win_screen/field_dark_empty.svg',
                                            height: ResponsiveSizing.scaleHeight(context, 28), width: double.infinity),
                                        Text('${sortedTeams[index]['round'] - 1}', textAlign: TextAlign.center, style: columnTitleStyle),
                                      ],
                                    ),
                                    SizedBox(width: 40),
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SvgPicture.asset('assets/time_to_party_assets/win_screen/field_blue_empty.svg',
                                            height: ResponsiveSizing.scaleHeight(context, 28), width: double.infinity),
                                        Text('${sortedTeams[index]['score']}', textAlign: TextAlign.center, style: columnTitleStyle),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                          child: Container(alignment: Alignment.bottomCenter,
                        margin: EdgeInsets.symmetric(vertical: 3, horizontal: 21),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TripleButtonWin(
                              svgAsset: 'assets/time_to_party_assets/premium_cards_icon.svg',
                              onPressed: () {
                                GoRouter.of(context).push('/card_advertisement');
                              },
                            ),
                            Spacer(),
                            TripleButtonWin(
                             // imageAsset: 'path/to/your/image.png',
                              iconData: Icons.play_arrow_rounded,
                              onPressed: () {
                                Navigator.of(context).popUntil((route) => route.isFirst);
                              },
                            ),
                            Spacer(),
                            TripleButtonWin(
                              iconData: Icons.star,
                              onPressed: () {
                                AnimatedAlertDialog.showRateDialog(context);
                              },
                            ),
                          ],
                        ),
                      )),
                      SizedBox(height: 20)
                    ],
                  ),
                ),
              ),
              SizedBox(height: 100)
            ],
          ),
        ),
      ),
    );
  }

  TextStyle columnTitleStyle = TextStyle(
    fontWeight: FontWeight.bold,
    color: Palette().white,
    fontSize: 14,
    shadows: [
      Shadow(
        offset: Offset(1.0, 1.0),
        blurRadius: 3.0,
        color: Colors.black.withOpacity(0.5), // Cień dla tekstu
      ),
    ],
  );
}
