import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:game_template/src/app_lifecycle/translated_text.dart';
import 'package:game_template/src/play_session/alerts_and_dialogs.dart';
import 'package:game_template/src/win_game/triple_button_win.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../ads/ads_controller.dart';
import '../ads/banner_ad_widget.dart';
import '../app_lifecycle/responsive_sizing.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../customAppBar/customAppBar.dart';
import '../drawer/drawer.dart';
import '../games_services/score.dart';
import '../in_app_purchase/in_app_purchase.dart';
import '../style/palette.dart';

class WinGameScreen extends StatefulWidget {
  final List<String> teamNames;
  final List<Color> teamColors;

  const WinGameScreen({super.key, required this.teamNames, required this.teamColors});

  @override
  _WinGameScreenState createState() => _WinGameScreenState();
}

class _WinGameScreenState extends State<WinGameScreen> with SingleTickerProviderStateMixin{
  late AnimationController _animationController;
  late Animation<double> _scaleAnimationLeftButton;
  late Animation<double> _scaleAnimationCenterButton;
  late Animation<double> _scaleAnimationRightButton;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat();  // Powtarza animację w nieskończoność

    _scaleAnimationLeftButton = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.1),
          weight: 0.05
      ),
      TweenSequenceItem(
          tween: ConstantTween<double>(1.1),
          weight: 0.05
      ),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.1, end: 1.0),
          weight: 0.05
      ),
      TweenSequenceItem(
          tween: ConstantTween<double>(1.0),
          weight: 0.85
      ),
    ]).animate(_animationController);

    _scaleAnimationCenterButton = TweenSequence<double>([
      TweenSequenceItem(
          tween: ConstantTween<double>(1.0),
          weight: 0.4
      ),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.1),
          weight: 0.05
      ),
      TweenSequenceItem(
          tween: ConstantTween<double>(1.1),
          weight: 0.05
      ),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.1, end: 1.0),
          weight: 0.05
      ),
      TweenSequenceItem(
          tween: ConstantTween<double>(1.0),
          weight: 0.45
      ),
    ]).animate(_animationController);

    _scaleAnimationRightButton = TweenSequence<double>([
      TweenSequenceItem(
          tween: ConstantTween<double>(1.0),
          weight: 0.6
      ),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.1),
          weight: 0.05
      ),
      TweenSequenceItem(
          tween: ConstantTween<double>(1.1),
          weight: 0.05
      ),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.1, end: 1.0),
          weight: 0.05
      ),
      TweenSequenceItem(
          tween: ConstantTween<double>(1.0),
          weight: 0.25
      ),
    ]).animate(_animationController);
  }
  @override
  Widget build(BuildContext context) {
    final adsControllerAvailable = context.watch<AdsController?>() != null;
    final adsRemoved = context.watch<InAppPurchaseController?>()?.adRemoval.active ?? false;
    final palette = context.watch<Palette>();
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final audioController = context.watch<AudioController>();
    // Sortowanie drużyn według wyników
    final List<Map<String, dynamic>> sortedTeams = List.generate(
      widget.teamNames.length,
      (index) => {
        'name': widget.teamNames[index],
        'color': widget.teamColors[index],
        'score': TeamScore.getTeamScore(widget.teamNames[index], widget.teamColors[index]).getTotalScore(),
        'round': TeamScore.getRoundNumber(widget.teamNames[index], widget.teamColors[index])
        //
      },
    )..sort((a, b) => b['score'].compareTo(a['score']) as int);
    print('sortedTeams: $sortedTeams, sortedTeamslength: ${sortedTeams.length}');
    return WillPopScope(
      onWillPop: () async => false, // Zablokowanie możliwości cofnięcia
      child: Container(
        decoration: BoxDecoration(
          gradient: Palette().backgroundLoadingSessionGradient,
        ),
        child: Scaffold(
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
            title: translatedText(context, 'congratulations', 14, Palette().white),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/time_to_party_assets/win_screen/team_ranking_win.png',
                  height: ResponsiveSizing.scaleHeight(context, 150)),
              Padding(padding: EdgeInsets.all(5.0), child: translatedText(context, 'team_rankings', 28, Palette().white)),
              if (adsControllerAvailable && !adsRemoved) ...[
                const Expanded(
                  child: Center(
                    child: BannerAdWidget(),
                  ),
                ),
              ],

              Expanded(
                flex: 3,
                child: Container(
                  margin: EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                        color: Colors.deepPurpleAccent.withOpacity(0.3), width: 1), // Rozowa linia obramowania
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
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(getTranslatedString(context, 'color').toUpperCase(), style: columnTitleStyle),
                            ),
                            Expanded(
                              child: Text(getTranslatedString(context, 'x_teams').toUpperCase(), style: columnTitleStyle),
                            ),
                            Expanded(
                              child: Text(getTranslatedString(context, 'round').toUpperCase(), textAlign: TextAlign.center, style: columnTitleStyle),
                            ),
                            Expanded(
                              child: Text(getTranslatedString(context, 'points').toUpperCase(), textAlign: TextAlign.center, style: columnTitleStyle),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        flex: 4,
                        child: Scrollbar(
                          thumbVisibility: true,
                          trackVisibility: true,
                          thickness: -6.0,
                          radius: Radius.circular(10),
                          child: ListView.builder(
                            itemCount: sortedTeams.length,
                            itemBuilder: (context, index) {
                              return Container(
                                height: 50,
                                margin: EdgeInsets.symmetric(vertical: 3, horizontal: 21),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: Palette().pink, width: 1),
                                ),
                                child: Row(
                                  children: [
                                    Spacer(), // Zastępuje SizedBox(width: 10)
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: sortedTeams[index]['color'] as Color,
                                        ),
                                        width: 24,
                                        height: 24,
                                      ),
                                    ),
                                    Spacer(),
                                    Expanded(
                                      flex: 4,
                                      child:
                                          letsText(context, sortedTeams[index]['name'] as String, 14, Palette().white),
                                    ),
                                    Spacer(),
                                    Expanded(
                                      flex: 2,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          SvgPicture.asset(
                                              'assets/time_to_party_assets/win_screen/field_dark_empty.svg',
                                              height: 35,
                                              width: 35),
                                          Text('${sortedTeams[index]['round'] - 1}',
                                              textAlign: TextAlign.center, style: columnTitleStyle),
                                        ],
                                      ),
                                    ),
                                    Spacer(),
                                    Expanded(
                                      flex: 3, // Ustal proporcje dla punktów
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          SvgPicture.asset(
                                              'assets/time_to_party_assets/win_screen/field_blue_empty.svg',
                                              height: 35,
                                              width: 35),
                                          Text('${sortedTeams[index]['score']}',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Palette().yellowIndBorder,
                                                fontSize: 14,
                                                shadows: [
                                                  Shadow(
                                                    offset: Offset(1.0, 1.0),
                                                    blurRadius: 3.0,
                                                    color: Colors.black.withOpacity(0.5),
                                                  ),
                                                ],
                                              )),
                                        ],
                                      ),
                                    ),
                                    // Zastępuje ostatni SizedBox
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              //SizedBox(height: 100)
              Flexible(
                flex: 1,
                child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Container(
                      alignment: Alignment.topCenter,
                      margin: EdgeInsets.symmetric(vertical: 3, horizontal: 21),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _scaleAnimationLeftButton,
                            builder: (context, child) => Transform.scale(
                              scale: _scaleAnimationLeftButton.value,
                              child: child,
                            ), child:
                            TripleButtonWin(
                            svgAsset: 'assets/time_to_party_assets/premium_cards_icon.svg',
                            onPressed: () async {
                              await Future.delayed(Duration(milliseconds: 150));
                              GoRouter.of(context).push('/card_advertisement');
                            },
                          ),),
                          Spacer(),
                      AnimatedBuilder(
                        animation: _scaleAnimationCenterButton,
                        builder: (context, child) => Transform.scale(
                          scale: _scaleAnimationCenterButton.value,
                          child: child,
                        ), child:
                      TripleButtonWin(
                            // imageAsset: 'path/to/your/image.png',
                            iconData: Icons.play_arrow_rounded,
                            onPressed: () async {
                              await Future.delayed(Duration(milliseconds: 150));
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            },
                          ),),
                          Spacer(),
                      AnimatedBuilder(
                        animation: _scaleAnimationRightButton,
                        builder: (context, child) => Transform.scale(
                          scale: _scaleAnimationRightButton.value,
                          child: child,
                        ), child:
                          TripleButtonWin(
                            iconData: Icons.star,
                            onPressed: () async {
                              await Future.delayed(Duration(milliseconds: 150));
                              AnimatedAlertDialog.showRateDialog(context);
                            },
                          ),),
                        ],
                      ),
                    )),
              )
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
