import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui';

import '../app_lifecycle/translated_text.dart';
import '../play_session/play_gameboard_main.dart';
import '../style/palette.dart';
import 'package:flutter/services.dart';

class PlayGameboardCard extends StatefulWidget {
  final List<String> teamNames;
  final List<Color> teamColors;
  final List<String> currentField;

  PlayGameboardCard({required this.teamNames, required this.teamColors, required this.currentField});

  @override
  _PlayGameboardCardState createState() => _PlayGameboardCardState();
}

class _PlayGameboardCardState extends State<PlayGameboardCard> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ..._displayValues(),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // "pop" obecnego ekranu
              },
              child: Text('Pop Screen'),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _displayValues() {
    List<Widget> displayWidgets = [];

    // Wartości teamNames
    for (String name in widget.teamNames) {
      displayWidgets.add(Text(name));
    }

    // Wartości teamColors (jako kwadraty kolorów)
    for (Color color in widget.teamColors) {
      displayWidgets.add(Container(
        width: 50,
        height: 50,
        color: color,
      ));
    }

    // Wartości currentField
    for (String field in widget.currentField) {
      displayWidgets.add(Text(field));
    }

    return displayWidgets;
  }
}
