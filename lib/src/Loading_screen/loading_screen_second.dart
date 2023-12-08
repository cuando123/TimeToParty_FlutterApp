import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_lifecycle/translated_text.dart';
import '../play_session/main_board/play_gameboard_main.dart';
import '../settings/settings.dart';
import '../style/palette.dart';

class LoadingScreenSecond extends StatefulWidget {
  final List<String> teamNames;
  final List<Color> teamColors;

  const LoadingScreenSecond({super.key, required this.teamNames, required this.teamColors});

  @override
  _LoadingScreenSecondState createState() => _LoadingScreenSecondState();
}

class _LoadingScreenSecondState extends State<LoadingScreenSecond> {
  int countdown = 3; // Wartość początkowa odliczania
  Timer? countdownTimer;

  @override
  void initState() {
    super.initState();
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown == 1) {
        timer.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PlayGameboard(
              teamNames: widget
                  .teamNames,
              teamColors: widget.teamColors,
            ),
          ),
        );
      } else {
        setState(() {
          countdown--;
        });
      }
    });
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final settingsController = context.watch<SettingsController>();
    if (settings.musicOn.value) {
      settingsController.toggleMusicOn();
    }
    return WillPopScope(
      onWillPop: () async => false, // Zablokowanie możliwości cofnięcia
      child: LoaderWidgetSecond(countdown: countdown),
    );
  }
  }

class LoaderWidgetSecond extends StatelessWidget {
  final int countdown;

  const LoaderWidgetSecond({super.key, required this.countdown});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: Palette().backgroundLoadingSessionGradient,
        ),
        child: Center( // Center automatycznie wyśrodkowuje swój child na ekranie
          child: Column(
            children: [
              SizedBox(height: 50.0),
              LogoWidget(),
              SizedBox(height: 20.0),
              CircularProgressIndicator(color: Palette().pink),
              SizedBox(height: 50.0),
              letsText(context,'Gra rozpocznie się za $countdown', 16, Palette().bluegrey),
            ],
          ),
        ),
      ),
    );
  }
}