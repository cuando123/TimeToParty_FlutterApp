// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../customAppBar/customAppBar_notitle.dart';
import '../drawer/drawer.dart';
import '../games_services/games_services.dart';
import '../instruction_dialog/instruction_dialog.dart';
import '../settings/settings.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final gamesServicesController = context.watch<GamesServicesController?>();
    final settingsController = context.watch<SettingsController>();
    final audioController = context.watch<AudioController>();
    final scaffoldKey = GlobalKey<ScaffoldState>();
    ValueNotifier<int?> selectedNumberOfTeams = ValueNotifier<int?>(null);
    return Container(
      decoration: BoxDecoration(
        gradient: Palette().backgroundLoadingSessionGradient,
      ),
      child: Scaffold(
        drawer: CustomAppDrawer(),
        key: scaffoldKey,
        appBar: CustomAppBar_notitle(
          onMenuButtonPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
          title: '',
        ),
        backgroundColor: Colors.transparent,
        body: ResponsiveScreen(
          mainAreaProminence: 0.4,
          squarishMainArea: Center(
            child: LogoWidget(),
          ),
          rectangularMenuArea: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ValueListenableBuilder<int?>(
                valueListenable: selectedNumberOfTeams,
                builder: (BuildContext context, int? value, Widget? child) {
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    decoration: BoxDecoration(
                      color: Color(0xFFB0B5E9),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: DropdownButton<int?>(
                      value: value,
                      items: <int>[2, 3, 4, 5, 6]
                          .map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(
                            '                  $value',
                            style: TextStyle(
                                fontFamily: 'HindMadurai', fontSize: 20),
                          ),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          selectedNumberOfTeams.value = newValue;
                        }
                      },
                      dropdownColor: Color(0xFFB0B5E9),
                      style: TextStyle(
                        color: Color(0xFF221933),
                        fontSize: 20,
                        fontFamily: 'HindMadurai',
                      ),
                      hint: const Text('   Ile drużyn zagra?'),
                      isExpanded: true,
                    ),
                  );
                },
              ),
              _gap,
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFCB48EF), // color
                  foregroundColor: Colors.white, // textColor
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize: Size(MediaQuery.of(context).size.width * 0.5,
                      MediaQuery.of(context).size.height * 0.05),
                  textStyle: TextStyle(fontFamily: 'HindMadurai', fontSize: 20),
                ),
                icon: Icon(Icons.play_arrow_rounded, size: 32),
                onPressed: () {
                  audioController.playSfx(SfxType.buttonTap);
                  GoRouter.of(context).go('/play/${selectedNumberOfTeams.value}');
                },
                label: const Text('Zagraj teraz!'),
              ),
              _gap,
              if (gamesServicesController != null) ...[
                _hideUntilReady(
                  ready: gamesServicesController.signedIn,
                  child: FilledButton(
                    onPressed: () => gamesServicesController.showAchievements(),
                    child: const Text('Achievements'),
                  ),
                ),
                _gap,
                _hideUntilReady(
                  ready: gamesServicesController.signedIn,
                  child: FilledButton(
                    onPressed: () => gamesServicesController.showLeaderboard(),
                    child: const Text('Leaderboard'),
                  ),
                ),
                _gap,
              ],
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFB0B5E9), // color
                  foregroundColor: Color(0xFF221933), // textColor
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize: Size(MediaQuery.of(context).size.width * 0.5,
                      MediaQuery.of(context).size.height * 0.05),
                  textStyle: TextStyle(fontFamily: 'HindMadurai', fontSize: 20),
                ),
                icon: Icon(Icons.settings, size: 32),
                onPressed: () => GoRouter.of(context).go('/settings'),
                label: const Text('Ustawienia'),
              ),
              _gap,
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFB0B5E9), // color
                  foregroundColor: Color(0xFF221933), // textColor
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize: Size(MediaQuery.of(context).size.width * 0.5,
                      MediaQuery.of(context).size.height * 0.05),
                  textStyle: TextStyle(fontFamily: 'HindMadurai', fontSize: 20),
                ),
                icon: Icon(Icons.question_mark, size: 32),
                onPressed: () {
                  Future.delayed(Duration(milliseconds: 150), () {
                    showDialog<void>(
                      context: context,
                      builder: (context) {
                        return InstructionDialog();
                      },
                    );
                  });
                },
                label: const Text('Zasady gry'),
              ),
              _gap,
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFB0B5E9), // color
                  foregroundColor: Color(0xFF221933), // textColor
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize: Size(MediaQuery.of(context).size.width * 0.5,
                      MediaQuery.of(context).size.height * 0.05),
                  textStyle: TextStyle(fontFamily: 'HindMadurai', fontSize: 20),
                ),
                onPressed: () =>  SystemNavigator.pop(), //GoRouter.of(context).go('/loading'),
                child: const Text('Wyjście'),
              ),
              SizedBox(height:80)
            ],
          ),
        ),
      ),
    );
  }

  /// Prevents the game from showing game-services-related menu items
  /// until we're sure the player is signed in.
  ///
  /// This normally happens immediately after game start, so players will not
  /// see any flash. The exception is folks who decline to use Game Center
  /// or Google Play Game Services, or who haven't yet set it up.
  Widget _hideUntilReady({required Widget child, required Future<bool> ready}) {
    return FutureBuilder<bool>(
      future: ready,
      builder: (context, snapshot) {
        // Use Visibility here so that we have the space for the buttons
        // ready.
        return Visibility(
          visible: snapshot.data ?? false,
          maintainState: true,
          maintainSize: true,
          maintainAnimation: true,
          child: child,
        );
      },
    );
  }

  static const _gap = SizedBox(height: 10);
}

class LogoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final mediaQueryData = MediaQuery.of(context);
    final screenHeight = mediaQueryData.size.height;
    final screenWidth = mediaQueryData.size.width;
    print("Pixel Ratio: $pixelRatio");
    print("Screen Height: $screenHeight");
    print("Screen Width: $screenWidth");
    final StarBoxWidth = 60 / screenWidth * mediaQueryData.size.width;
    final StarBoxHeight = 60 / screenHeight * mediaQueryData.size.height;
    final TextBoxWidth = 281 / screenWidth * mediaQueryData.size.width;
    final TextBoxHeight = 146 / screenHeight * mediaQueryData.size.height;
    return Container(
      child: Stack(children: <Widget>[
        // blue star
        Positioned(
          top: 84 / screenHeight * mediaQueryData.size.height,
          left: 43 / screenWidth * mediaQueryData.size.width,
          child: Transform.rotate(
            angle: -20 * 3.14 / 180,
            child: Container(
              width: StarBoxWidth,
              height: StarBoxHeight,
              child: SvgPicture.asset(
                'assets/time_to_party_assets/blue_star.svg',
              ),
            ),
          ),
        ),
        // yellow star
        Positioned(
          top: 55 / screenHeight * mediaQueryData.size.height,
          left: 93 / screenWidth * mediaQueryData.size.width,
          child: Transform.rotate(
            angle: -20 * 3.14 / 180,
            child: Container(
              width: StarBoxWidth,
              height: StarBoxHeight,
              child: SvgPicture.asset(
                'assets/time_to_party_assets/yellow_star.svg',
              ),
            ),
          ),
        ),
        // grey star
        Positioned(
          top: 58 / screenHeight * mediaQueryData.size.height,
          left: 157 / screenWidth * mediaQueryData.size.width,
          child: Transform.rotate(
            angle: -20 * 3.14 / 180,
            child: Container(
              width: StarBoxWidth,
              height: StarBoxHeight,
              child: SvgPicture.asset(
                'assets/time_to_party_assets/grey_star.svg',
              ),
            ),
          ),
        ),
        // black star
        Positioned(
          top: 41 / screenHeight * mediaQueryData.size.height,
          left: 205 / screenWidth * mediaQueryData.size.width,
          child: Transform.rotate(
            angle: -20 * 3.14 / 180,
            child: Container(
              width: StarBoxWidth,
              height: StarBoxHeight,
              child: SvgPicture.asset(
                'assets/time_to_party_assets/black_star.svg',
              ),
            ),
          ),
        ),
        // pink star
        Positioned(
          top: 55 / screenHeight * mediaQueryData.size.height,
          left: 276 / screenWidth * mediaQueryData.size.width,
          child: Transform.rotate(
            angle: -20 * 3.14 / 180,
            child: Container(
              width: StarBoxWidth,
              height: StarBoxHeight,
              child: SvgPicture.asset(
                'assets/time_to_party_assets/pink_star.svg',
              ),
            ),
          ),
        ),
        // title logo
        Positioned(
          top: 135 / mediaQueryData.size.height * screenHeight,
          left: 49 / mediaQueryData.size.width * screenWidth,
          child: Container(
            width: TextBoxWidth,
            height: TextBoxHeight,
            child: SvgPicture.asset(
              'assets/time_to_party_assets/time_to_party_logo.svg',
            ),
          ),
        ),
        // Loading bar slider
      ]),
    );
  }
}
