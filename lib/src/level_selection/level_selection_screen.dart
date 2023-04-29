// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../customAppBar/customAppBar.dart';
import '../drawer/drawer.dart';
import '../style/palette.dart';

class LevelSelectionScreen extends StatefulWidget {
  final int numberOfTeams;

  const LevelSelectionScreen({required this.numberOfTeams, Key? key})
      : super(key: key);

  @override
  _LevelSelectionScreenState createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  List<String> teamNames = [];

  late List<Color> teamColors;

  @override
  void initState() {
    super.initState();
    teamNames = List<String>.filled(widget.numberOfTeams, '');
    teamColors = List.generate(widget.numberOfTeams, (_) => Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return Container(
      decoration: BoxDecoration(
        gradient: Palette().backgroundLoadingSessionGradient,
      ),
      child: Scaffold(
          drawer: CustomAppDrawer(),
          key: scaffoldKey,
          appBar: CustomAppBar(
            title: 'Wprowadź nazwy drużyn',
            onMenuButtonPressed: () {
              scaffoldKey.currentState?.openDrawer();
            },
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Positioned.fill(
              child: Column(children: [
                Container(
                  height: 100, // Określ wysokość wg własnego uznania
                  child: LogoWidget_notitle(),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.numberOfTeams,
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          Expanded(
                            child: TextField(
                                decoration: InputDecoration(
                                labelText: 'Team ${index + 1}',
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              Color newColor =
                                  teamColors[index]; // Dodaj tę linię
                              await showDialog<Color>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Wybierz kolor'),
                                  content: SingleChildScrollView(
                                    child: BlockPicker(
                                      pickerColor: teamColors[index],
                                      onColorChanged: (Color color) {
                                        newColor = color; // Dodaj tę linię
                                      },
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Anuluj'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context,
                                          newColor), // Zmodyfikuj tę linię
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                              // Jeśli wybrano nowy kolor, zaktualizuj listę
                              if (newColor != teamColors[index]) {
                                // Zmodyfikuj tę linię
                                setState(() {
                                  teamColors[index] = newColor;
                                });
                              }
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: teamColors[index],
                                border: Border.all(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              Container(
                height: 200,
                child: Center(// Określ wysokość wg własnego uznania
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFCB48EF), // color
                    foregroundColor: Colors.white, // textColor
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    minimumSize: Size(
                        MediaQuery.of(context).size.width * 0.5,
                        MediaQuery.of(context).size.height * 0.05),
                    textStyle:
                    TextStyle(fontFamily: 'HindMadurai', fontSize: 20),
                  ),
                  icon: Icon(Icons.play_arrow_rounded, size: 32),
                  onPressed: () {},
                  label: const Text('Zagraj teraz!'),
                ),
              ),
              ),
              ]),
            ),
          )),
    );
  }
}

class LogoWidget_notitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final mediaQueryData = MediaQuery.of(context);
    final screenHeight = mediaQueryData.size.height;
    final screenWidth = mediaQueryData.size.width;
    final StarBoxWidth = 60 / screenWidth * mediaQueryData.size.width;
    final StarBoxHeight = 60 / screenHeight * mediaQueryData.size.height;
    return Container(
      child: Stack(children: <Widget>[
        // blue star
        Positioned(
          top: 54 / screenHeight * mediaQueryData.size.height,
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
          top: 25 / screenHeight * mediaQueryData.size.height,
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
          top: 28 / screenHeight * mediaQueryData.size.height,
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
          top: 11 / screenHeight * mediaQueryData.size.height,
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
          top: 25 / screenHeight * mediaQueryData.size.height,
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
        // Loading bar slider
      ]),
    );
  }
}
