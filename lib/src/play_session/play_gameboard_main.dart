import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import '../app_lifecycle/translated_text.dart';
import '../settings/settings.dart';
import '../style/palette.dart';

class PlayGameboard extends StatefulWidget {
  final List<String> teamNames;
  final List<Color> teamColors;

  const PlayGameboard({super.key, required this.teamNames, required this.teamColors});

  @override
  _PlayGameboardState createState() => _PlayGameboardState();
}

class _PlayGameboardState extends State<PlayGameboard> with SingleTickerProviderStateMixin {
  late StreamController<int> _selectedController = StreamController<int>.broadcast();
  late AnimationController _animationController;
  late StreamSubscription<int> _subscription;
  late List<Offset> flagPositions;
  late List<int> flagSteps;
  final List<int> _wheelValues = [0, 1, 2, 0, 1, 2];
  int selectedValue = 0;
  int currentTeamIndex = 0;
  int currentFlagIndex = 0;
  bool isAnimating = false;
  StreamController<int> selected = StreamController<int>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _animationController.stop();
    _selectedController = StreamController<int>.broadcast();
    flagPositions = List.generate(widget.teamColors.length, (index) => Offset(0, 0));
    flagSteps = List.filled(widget.teamColors.length, 0);
    _subscription = _selectedController.stream.listen((selectedIndex) {
      setState(() {
        selectedValue = _wheelValues[selectedIndex] + 1; // Zaktualizuj wartość selectedValue
      });
      print('Wylosowana wartość: $selectedValue, Wylosowany index: $selectedIndex');
    });
  }

  @override
  Widget build(BuildContext context) {
    print('scaleHeight: ${ResponsiveSizing.scaleHeight(context, 50).toString()}');
    print('height gap: ${ResponsiveSizing.responsiveHeightGap(context, 7).toString()}');
    print('width gap: ${ResponsiveSizing.responsiveWidthGap(context, 6).toString()}');

    return Container(
      decoration: BoxDecoration(
        gradient: Palette().backgroundLoadingSessionGradient,
      ),
      child: Scaffold(
        appBar: AppBar(
          title:
          Row(
            children: [
              Text("${getCurrentTeamName()} - wasza kolej!"),
              Container(
                width: 20,
                height: 20,
                color: colorFromString(getCurrentTeamColor()),
              ),
            ],
          ),
        ),
        body: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;
          double percentageScreen = ((screenHeight - screenWidth) / screenHeight) * 100;
          print('percentageScreen: $percentageScreen');
          return Column(
            children: <Widget>[
              Container(
                width: screenWidth,
                height: screenWidth,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white, width: 2.0), // To dodaje białą linię na dole kontenera.
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0), // left, top, right, bottom
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: leftColumnVertical(screenWidth),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: rightColumnVertical(screenWidth),
                      ),
                      Column(
                        children: [
                          Positioned(
                            top: 0,
                            child: upRowHorizontal(screenWidth),
                          ),
                          ResponsiveSizing.responsiveHeightGap(context, 10),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (BuildContext context, BoxConstraints constraints) {
                                return SvgPicture.asset(
                                  'assets/time_to_party_assets/card_arrows.svg',
                                  width: constraints.maxWidth,
                                  height: constraints.maxHeight,
                                  fit: BoxFit.contain,
                                );
                              },
                            ),
                          ),
                          ResponsiveSizing.responsiveHeightGap(context, 10),
                          fourCardsCenter(screenWidth),
                          ResponsiveSizing.responsiveHeightGap(context, 10),
                          downRowHorizontal(screenWidth),
                          ResponsiveSizing.responsiveHeightGap(context, 10),
                        ],
                      ),
                      buildFlagsStack(widget.teamColors, flagPositions, screenWidth),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0), //
                              child: Column(
                                children: [
                                  Text('Wylosowana wartość: $selectedValue'),
                                  translatedText(context,'game_rules', 20, Palette().white),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        if (isAnimating) {
                                          return;
                                        }
                                        isAnimating = true;
                                        final randomIndex = Fortune.randomInt(0, _wheelValues.length);
                                        _selectedController = StreamController<int>.broadcast();
                                        selected.add(randomIndex);
                                        Future.delayed(Duration(seconds: 5), () {
                                          setState(() {
                                            selectedValue = _wheelValues[randomIndex] + 1;

                                            moveFlag(selectedValue, currentFlagIndex,
                                                screenWidth * 0.02768 - 4 + screenWidth * 0.1436);

                                          });
                                        });
                                      },
                                      child: FortuneWheel(
                                        selected: selected.stream,
                                        animateFirst: false,
                                        indicators: <FortuneIndicator>[
                                          FortuneIndicator(
                                            alignment: Alignment.topCenter,
                                            child: Stack(
                                              children: [
                                                Transform.translate(
                                                  offset: Offset(0, -10),
                                                  child: Transform.scale(
                                                    scaleX: 0.75,
                                                    scaleY: 0.65, // zmniejsza wielkość o połowę
                                                    child: TriangleIndicator(
                                                      color: Palette().borderSpinningWheel,
                                                    ),
                                                  ),
                                                ),
                                                Transform.translate(
                                                  offset: Offset(0, -10),
                                                  child: Transform.scale(
                                                    scaleX: 0.6,
                                                    scaleY: 0.5, // zmniejsza wielkość o połowę
                                                    child: TriangleIndicator(
                                                      color: Color(0xFFFFC344),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                        items: [
                                          buildFortuneItem('1', Palette().pink),
                                          buildFortuneItem('2', Palette().bluegrey),
                                          buildFortuneItem('3', Palette().backgroundPlaySession),
                                          buildFortuneItem('1', Palette().grey),
                                          buildFortuneItem('2', Palette().pink),
                                          buildFortuneItem('3', Palette().darkGrey),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(10.0, 5.0, 5.0, 0.0), // left, top, right, bottom
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              LayoutBuilder(
                              builder: (context, constraints) {
                          // Oblicz liczbę kolumn na podstawie szerokości ekranu
                          int count = percentageScreen < 40 ? 4 : 2;  // Załóżmy, że chcemy dwie kolumny na szerokich ekranach, a na węższych - tylko jedną.
                          print('screen widsth: ${constraints.maxWidth}');
                        return GridView.count(
                        shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: count,
                          crossAxisSpacing: 0,
                          mainAxisSpacing: 10,
                          children: <Widget>[
                            CardAnimation(),
                            // SvgPicture.asset(
                            //   'assets/time_to_party_assets/card_star_green.svg',
                            //   fit: BoxFit.contain,
                            // ),
                            SvgPicture.asset(
                              'assets/time_to_party_assets/card_star_blue_light.svg',
                              fit: BoxFit.contain,
                            ),
                            SvgPicture.asset(
                              'assets/time_to_party_assets/card_star_yellow.svg',
                              fit: BoxFit.contain,
                            ),
                            SvgPicture.asset(
                              'assets/time_to_party_assets/card_star_pink.svg',
                              fit: BoxFit.contain,
                            ),
                          ],
                        );
                      },
                      ),
                              Container(
                                height: 2.0,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white, width: 2.0),
                                ),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Palette().pink, // color
                                  foregroundColor: Palette().white, // textColor
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  minimumSize: Size(
                                      ResponsiveSizing.scaleWidth(context, 220),
                                      ResponsiveSizing.responsiveHeightWithCondition(
                                          context, 51, 45, 650)),
                                  //textStyle: TextStyle(fontFamily: 'HindMadurai', fontSize: ResponsiveText.scaleHeight(context, 20)),
                                ),
                                icon: Icon(Icons.play_circle_rounded,
                                    size: ResponsiveSizing.scaleHeight(context, 32)),
                                onPressed: () {
                                },
                                label: Text('Zakręć kołem'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget fourCardsCenter(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: screenWidth * 0.02768 - 4),
        SvgPicture.asset('assets/time_to_party_assets/card_microphone.svg', width: screenWidth * 0.1436),
        SizedBox(width: screenWidth * 0.02768 - 4),
        SvgPicture.asset('assets/time_to_party_assets/card_rymes.svg', width: screenWidth * 0.1436),
        SizedBox(width: screenWidth * 0.02768 - 4),
        SvgPicture.asset('assets/time_to_party_assets/card_letters.svg', width: screenWidth * 0.1436),
        SizedBox(width: screenWidth * 0.02768 - 4),
        SvgPicture.asset('assets/time_to_party_assets/card_pantomime.svg', width: screenWidth * 0.1436),
        SizedBox(width: screenWidth * 0.02768 - 4),
      ],
    );
  }

  Widget upRowHorizontal(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ResponsiveSizing.responsiveWidthGap(context, 6),
        SvgPicture.asset('assets/time_to_party_assets/field_star_blue_light.svg', width: screenWidth * 0.1436),
        SizedBox(width: screenWidth * 0.02768 - 4),
        SvgPicture.asset('assets/time_to_party_assets/field_arrows.svg', width: screenWidth * 0.1436),
        SizedBox(width: screenWidth * 0.02768 - 4),
        SvgPicture.asset('assets/time_to_party_assets/field_microphone.svg', width: screenWidth * 0.1436),
        SizedBox(width: screenWidth * 0.02768 - 4),
        SvgPicture.asset('assets/time_to_party_assets/field_sheet.svg', width: screenWidth * 0.1436),
        SizedBox(width: screenWidth * 0.02768 - 4),
      ],
    );
  }

  Widget downRowHorizontal(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset('assets/time_to_party_assets/field_star_green.svg', width: screenWidth * 0.1436),
        SizedBox(width: ((screenWidth - (screenWidth * 0.1436 * 6)) - 20) / 5),
        SvgPicture.asset('assets/time_to_party_assets/field_letters.svg', width: screenWidth * 0.1436),
        SizedBox(width: ((screenWidth - (screenWidth * 0.1436 * 6)) - 20) / 5),
        SvgPicture.asset('assets/time_to_party_assets/field_pantomime.svg', width: screenWidth * 0.1436),
        SizedBox(width: ((screenWidth - (screenWidth * 0.1436 * 6)) - 20) / 5),
        SvgPicture.asset('assets/time_to_party_assets/field_microphone.svg', width: screenWidth * 0.1436),
      ],
    );
  }

  Widget leftColumnVertical(double screenWidth) {
    return Column(
      children: [
        SvgPicture.asset('assets/time_to_party_assets/field_sheet.svg', width: screenWidth * 0.1436),
        SizedBox(height: screenWidth * 0.02768 - 4),
        SvgPicture.asset('assets/time_to_party_assets/field_pantomime.svg', width: screenWidth * 0.1436),
        SizedBox(height: screenWidth * 0.02768 - 4),
        SvgPicture.asset('assets/time_to_party_assets/field_letters.svg', width: screenWidth * 0.1436),
        SizedBox(height: screenWidth * 0.02768 - 4),
        SvgPicture.asset('assets/time_to_party_assets/field_arrows.svg', width: screenWidth * 0.1436),
        SizedBox(height: screenWidth * 0.02768 - 4),
        SvgPicture.asset('assets/time_to_party_assets/field_sheet.svg', width: screenWidth * 0.1436),
        SizedBox(height: screenWidth * 0.02768 - 4),
        SvgPicture.asset('assets/time_to_party_assets/field_start.svg', width: screenWidth * 0.1436),
      ],
    );
  }

  Widget rightColumnVertical(double screenWidth) {
    return Column(
      children: [
        SvgPicture.asset('assets/time_to_party_assets/field_star_pink.svg', width: screenWidth * 0.1436),
        SizedBox(height: screenWidth * 0.02768 - 4),
        SvgPicture.asset('assets/time_to_party_assets/field_microphone.svg', width: screenWidth * 0.1436),
        SizedBox(height: screenWidth * 0.02768 - 4),
        SvgPicture.asset('assets/time_to_party_assets/field_arrows.svg', width: screenWidth * 0.1436),
        SizedBox(height: screenWidth * 0.02768 - 4),
        SvgPicture.asset('assets/time_to_party_assets/field_pantomime.svg', width: screenWidth * 0.1436),
        SizedBox(height: screenWidth * 0.02768 - 4),
        SvgPicture.asset('assets/time_to_party_assets/field_star_yellow.svg', width: screenWidth * 0.1436),
        SizedBox(height: screenWidth * 0.02768 - 4),
        SvgPicture.asset('assets/time_to_party_assets/field_letters.svg', width: screenWidth * 0.1436),
        SizedBox(height: screenWidth * 0.02768 - 4),
      ],
    );
  }

  Widget buildFlagsStack(List<Color> teamColors, List<Offset> flagPositions, double screenWidth) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ...teamColors.asMap().entries.expand((entry) {
          int index = entry.key;
          Color color = entry.value;
          List<String> flagAssets = [
            'assets/time_to_party_assets/main_board/flags/flag00A2AC.svg',
            'assets/time_to_party_assets/main_board/flags/flag01B210.svg',
            'assets/time_to_party_assets/main_board/flags/flag9400AC.svg',
            'assets/time_to_party_assets/main_board/flags/flagF50000.svg',
            'assets/time_to_party_assets/main_board/flags/flagFFD335.svg',
            'assets/time_to_party_assets/main_board/flags/flagFFFFFF.svg',
          ];
          return flagAssets.where((flag) {
            String flagColorHex = 'FF' + flag.split('/').last.split('.').first.substring(4);
            Color flagColor = Color(int.parse(flagColorHex, radix: 16));
            if (color.value == flagColor.value) {
              return true;
            } else {
              return false;
            }
          }).map((flag) {
            return AnimatedPositioned(
              duration: Duration(seconds: 1),
                bottom: (teamColors.length == 2 || teamColors.length == 3)
                    ? flagPositions[index].dy + 20
                    : teamColors.length == 4
                    ? flagPositions[index].dy + 10 + (index ~/ 2) * 25
                    : (teamColors.length == 5 || teamColors.length == 6)
                    ? flagPositions[index].dy + 10 + (index ~/ 3) * 25
                    : flagPositions[index].dy + 10 + (index ~/ 3) * 25, // ustalanie pozycji flagi gora/dol w zaleznosci od ilosci flag
              left: (teamColors.length == 2 || teamColors.length == 4)
                  ? flagPositions[index].dx + (index % 2) * 25 + 5
                  : (teamColors.length == 5 || teamColors.length == 6 || teamColors.length == 3)
                  ? flagPositions[index].dx + (index % 3) * 25-8
                  : flagPositions[index].dx + (index % 3) * 25-8, // ustalanie pozycji flag lewo/prawo w zaleznosci od ilosci flag
              child: Transform.rotate(
                angle:
                (teamColors.length == 4)
                    ? ((index % 2 == 0) ? -10 : 15) * (3.14 / 180)
                    : ((index % 3 == 0) ? -10 : (index % 3 == 2) ? 15 : 0) * (3.14 / 180), //obroty flag dopasowane od ilosci
                child: Transform(
                  transform: Matrix4.identity()..scale(
                      (teamColors.length == 4) ? ((index == 0 || index == 2) ? -1.0 : 1.0) // odbicia flag ustalone od ilosci
                          : ((index == 0 || index == 3) ? -1.0 : 1.0),
                      1.0
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    flag,
                    width: screenWidth / 13.09,
                    height: screenWidth / 13.09,
                  ),
                ),
              ),
            );
          });
        }).toList(),
      ],
    );
  }

  FortuneItem buildFortuneItem(String text, Color color) {
    return FortuneItem(
      child: strokedText(text),
      style: FortuneItemStyle(
        color: color,
        borderColor: Palette().borderSpinningWheel,
        borderWidth: 3,
      ),
    );
  }

  Color colorFromString(String colorAsString) {
    String colorString = colorAsString.split('(0x')[1].split(')')[0]; // Extracting hex value from the string.
    int colorInt = int.parse(colorString, radix: 16); // Parsing hex string into an integer.
    return Color(colorInt); // Creating a new Color object.
  }

  @override
  void dispose() {
    _subscription.cancel();
    _animationController.dispose();
    _selectedController.close();
    selected.close();
    super.dispose();
  }

  Widget strokedText(String text) {
    return Transform.rotate(
      angle: 90 * 3.14 / 180,
      child: Stack(
        children: <Widget>[
          // Cieniowany tekst
          Text(
            text,
            style: TextStyle(
              fontSize: 40,
              fontFamily: 'Adamina',
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3
                ..color = Palette().borderSpinningWheel,
            ),
          ),
          // Tekst
          Text(
            text,
            style: TextStyle(
              fontSize: 40,
              fontFamily: 'Adamina',
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> moveFlag(int steps, int flagIndex, double stepSize) async {
    for (int i = 0; i < steps; i++) {
      flagSteps[flagIndex]++;
      int totalSteps = flagSteps[flagIndex];
      Offset newPosition;

      if (totalSteps <= 5) {
        newPosition = Offset(0, totalSteps * stepSize);
      } else if (totalSteps <= 10) {
        newPosition = Offset((totalSteps - 5) * stepSize, 5 * stepSize);
      } else if (totalSteps <= 15) {
        newPosition = Offset(5 * stepSize, (15 - totalSteps) * stepSize);
      } else if (totalSteps <= 20) {
        newPosition = Offset((20 - totalSteps) * stepSize, 0);
      } else {
        newPosition = Offset(0, 0);
        flagSteps[flagIndex] = 0;
      }

      setState(() {
        flagPositions[flagIndex] = newPosition;
      });

      await Future.delayed(Duration(milliseconds: 1200));
    }
    setState(() {
      currentFlagIndex = (currentFlagIndex + 1) % widget.teamColors.length;
    });
    currentTeamIndex = currentFlagIndex;
    isAnimating = false;
  }

  String getCurrentTeamName() {
    return widget.teamNames[currentTeamIndex].toString();
  }

  String getCurrentTeamColor() {
    return widget.teamColors[currentTeamIndex].toString();
  }
}




class CardAnimation extends StatefulWidget {
  @override
  _CardAnimationState createState() => _CardAnimationState();
}

class _CardAnimationState extends State<CardAnimation> with SingleTickerProviderStateMixin<CardAnimation> {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          if (_controller.isAnimating) {
            _controller.stop();
          } else {
            _controller.repeat();
          }
        },
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final rotationAngle = _animation.value * 3.14;
            final isFrontVisible = _animation.value < 0.5;

            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(rotationAngle),
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: isFrontVisible ? 1.0 : 0.0,
                    child: SvgPicture.asset(
                      'assets/time_to_party_assets/card_microphone.svg', // Twoje SVG dla przedniej strony karty
                      fit: BoxFit.contain,
                    ),
                  ),
                  Opacity(
                    opacity: isFrontVisible ? 0.0 : 1.0,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(3.14),
                      child: SvgPicture.asset(
                        'assets/time_to_party_assets/card_pantomime.svg', // Twoje SVG dla tylnej strony karty
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
