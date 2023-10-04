import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui';

import '../app_lifecycle/translated_text.dart';
import '../play_session/play_gameboard_main.dart';
import '../style/palette.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class LoadingScreenSecond extends StatefulWidget {
  final List<String> teamNames;
  final List<Color> teamColors;

  LoadingScreenSecond({required this.teamNames, required this.teamColors});

  @override
  _LoadingScreenSecondState createState() => _LoadingScreenSecondState();
}

class _LoadingScreenSecondState extends State<LoadingScreenSecond> {
  int countdown = 3; // Wartość początkowa odliczania
  Timer? countdownTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    });

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
    return LoaderWidgetSecond(countdown: countdown); // Przesyłamy wartość odliczania do widgetu
  }
}

class LoaderWidgetSecond extends StatelessWidget {
  final int countdown;

  const LoaderWidgetSecond({Key? key, required this.countdown}) : super(key: key);

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