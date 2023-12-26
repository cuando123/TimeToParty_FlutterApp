import 'package:flutter/material.dart';
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
       //
      },
    );
  //..sort((a, b) => b['name'].compareTo(a['name']) as int)
    return Scaffold(
      backgroundColor: palette.backgroundPlaySession,
      body: ResponsiveScreen(
        squarishMainArea: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            LogoWidget(),
            if (adsControllerAvailable && !adsRemoved) ...[
              const Expanded(
                child: Center(
                  child: BannerAdWidget(),
                ),
              ),
            ],
            Expanded(
              child: ListView.builder(
                itemCount: sortedTeams.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Container(
                      width: 24,
                      height: 24,
                      color: sortedTeams[index]['color'] as Color,
                    ),
                    title: Text(sortedTeams[index]['name'] as String),
                    trailing: Text('${sortedTeams[index]['score']}'),
                  );
                },
              ),
            ),
          ],
        ),
        rectangularMenuArea: FilledButton(
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: const Text('Wyjscie do main menu'),
        ),
      ),
    );
  }
}
