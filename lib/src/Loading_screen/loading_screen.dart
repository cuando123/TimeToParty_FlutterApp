import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui';

import '../app_lifecycle/translated_text.dart';
import '../play_session/play_gameboard_main.dart';
import '../style/palette.dart';


class LoadingScreen extends StatefulWidget {
  final List<String> teamNames;
  final List<Color> teamColors;

  LoadingScreen({required this.teamNames, required this.teamColors});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PlayGameboard(
            teamNames: widget.teamNames,
            teamColors: widget.teamColors,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoaderWidget();
  }
}

class LoaderWidget extends StatelessWidget {
  const LoaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: Palette().backgroundLoadingSessionGradient,
      ),
      child: Align(
        alignment: Alignment(0, -0.4),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Zmieniamy na 'min'
          children: [
            LogoWidget(),
            ResponsiveSizing.responsiveHeightGap(context, 20),
            CircularProgressIndicator(color: Palette().pink),
          ],
        ),
      ),
    );
  }
}