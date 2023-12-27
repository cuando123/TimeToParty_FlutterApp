import 'package:flutter/material.dart';
import 'package:game_template/src/app_lifecycle/translated_text.dart';
import 'package:game_template/src/play_session/custom_style_buttons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../ads/ads_controller.dart';
import '../ads/banner_ad_widget.dart';
import '../games_services/score.dart';
import '../in_app_purchase/in_app_purchase.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';

class WinGameScreen extends StatelessWidget {
  final List<String> teamNames;
  final List<Color> teamColors;

  WinGameScreen({
    super.key,
    required this.teamNames,
    required this.teamColors
  });

  @override
  Widget build(BuildContext context) {
    final adsControllerAvailable = context.watch<AdsController?>() != null;
    final adsRemoved =
        context.watch<InAppPurchaseController?>()?.adRemoval.active ?? false;
    final palette = context.watch<Palette>();

    // Sortowanie drużyn według wyników
    final List<Map<String, dynamic>> sortedTeams = List.generate(
      teamNames.length,
          (index) => {
        'name': teamNames[index],
        'color': teamColors[index],
            'score' : TeamScore.getTeamScore(teamNames[index], teamColors[index]).getTotalScore(),
            'round' : TeamScore.getRoundNumber(teamNames[index], teamColors[index])
       //
      },
    )..sort((a, b) => b['score'].compareTo(a['score']) as int);
    return Scaffold(
      backgroundColor: palette.backgroundPlaySession,
      body: Container(
        decoration: BoxDecoration(
          gradient: Palette().backgroundLoadingSessionGradient,
        ), child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            LogoWidget_notitle(),

            if (adsControllerAvailable && !adsRemoved) ...[
              const Expanded(
                child: Center(
                  child: BannerAdWidget(),
                ),
              ),
            ],
                Expanded(
                child: Container(
                margin: EdgeInsets.all(16), // Margines od brzegów ekranu
                decoration: BoxDecoration(
                color: Colors.white, // Białe tło dla całego kontenera
                borderRadius: BorderRadius.circular(10), // Zaokrąglenie rogów kontenera
                ),
                child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: letsText(context, 'Ranking drużyn', 24, Palette().pink)
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('Drużyna', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: Text('Rzuty ruletką', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: Text('Zdobyte punkty', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
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
                          margin: EdgeInsets.symmetric(vertical: 3, horizontal: 21), // Margines dla każdego elementu listy
                          decoration: BoxDecoration(
                            color: Palette().pink, // Różowe tło dla elementu listy
                            borderRadius: BorderRadius.circular(5), // Zaokrąglenie rogów dla elementu listy
                          ),
                          child: ListTile(
                            leading: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: sortedTeams[index]['color'] as Color,),
                              width: 24,
                              height: 24,
                            ),
                            title: letsText(context, sortedTeams[index]['name'] as String, 14, Palette().white),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                letsText(context, '${sortedTeams[index]['round']-1}', 14, Palette().white),
                              SizedBox(width: 50),
                              letsText(context, '${sortedTeams[index]['score']}', 14, Palette().white),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(child:
                  Container(
                      height: 50,
                      margin: EdgeInsets.symmetric(vertical: 3, horizontal: 21),
                  child: Column(
                    children: [
                    CustomStyledButton(icon: Icons.card_giftcard, text: 'Karty premium!', onPressed: () {GoRouter.of(context).push('/card_advertisement');}),
    CustomStyledButton(icon: Icons.card_giftcard, text: 'Oceń tą apkę na 5 gwiazdek!', onPressed: () {}),
    CustomStyledButton(icon: Icons.card_giftcard, text: 'Zagraj ponownie!', onPressed: () {Navigator.of(context).popUntil((route) => route.isFirst);}),

    ],),
                  )
                  ),],
                ),
                ),
                ),
                SizedBox(height: 100)
          ],
        ),
    ),);
  }
}
