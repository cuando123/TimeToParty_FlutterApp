import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:game_template/src/play_session/play_gameboard_card.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import '../app_lifecycle/translated_text.dart';
import '../instruction_dialog/instruction_dialog.dart';
import '../settings/settings.dart';
import '../style/palette.dart';

class PlayGameboard extends StatefulWidget {
  final List<String> teamNames;
  final List<Color> teamColors;

  const PlayGameboard({super.key, required this.teamNames, required this.teamColors});

  @override
  _PlayGameboardState createState() => _PlayGameboardState();
}

class _PlayGameboardState extends State<PlayGameboard> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late StreamController<int> _selectedController = StreamController<int>.broadcast();
  late StreamSubscription<int> _subscription;
  late List<Offset> flagPositions;
  late List<int> flagSteps;
  final List<int> _wheelValues = [0, 1, 2, 0, 1, 2];
  bool hasShownAlertDialog = false;
  int selectedValue = 0;
  int currentTeamIndex = 0;
  int currentFlagIndex = 0;
  bool isAnimating = false;
  StreamController<int> selected = StreamController<int>();
  List<String> upRowFieldsSvg = [];
  List<String> downRowFieldsSvg = [];
  List<String> leftColumnFieldsSvg = [];
  List<String> rightColumnFieldsSvg = [];
  List<String> allFieldsSvg = [];
  List<String> newFieldsList = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this);
    allFieldsSvg = _getShuffledFields();
    upRowFieldsSvg = allFieldsSvg.sublist(0, 4);
    downRowFieldsSvg = allFieldsSvg.sublist(4, 8);
    leftColumnFieldsSvg = allFieldsSvg.sublist(8, 14);
    rightColumnFieldsSvg = allFieldsSvg.sublist(14, 20);
    newFieldsList = generateNewFieldsList(upRowFieldsSvg, downRowFieldsSvg, leftColumnFieldsSvg, rightColumnFieldsSvg);
    _selectedController = StreamController<int>.broadcast();
    flagPositions = List.generate(widget.teamColors.length, (index) => Offset(0, 0));
    flagSteps = List.filled(widget.teamColors.length, 0);
    _subscription = _selectedController.stream.listen((selectedIndex) {
      setState(() {
        selectedValue = _wheelValues[selectedIndex] + 1; // Zaktualizuj wartość selectedValue
      });
    });
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.value = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!hasShownAlertDialog) {
        _showAnimatedAlertDialog();
        _controller.forward(from: 0);
        hasShownAlertDialog = true;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    print('Wylosowana wartość: $selectedValue');
    return WillPopScope(
      onWillPop: () async {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        showExitGameDialog(context);
        return false; // return false to prevent the pop operation
      },
      child: CustomBackground(child: Scaffold(
        body: LayoutBuilder(builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;
          print('screenHeight: $screenHeight');
          print('screenWidth: $screenWidth');
          double scale = min((screenHeight * 0.55) / screenWidth, 1.0);
          return Column(
            children: <Widget>[
              Container(
                height: screenHeight * 0.55,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white, width: 2.0), // To dodaje białą linię na dole kontenera.
                  ),
                ),
                child: Center(
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: screenWidth * scale,
                      height: screenWidth * scale,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0), // left, top, right, bottom
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              left: 0,
                              top: 0,
                              child: leftColumnVertical(leftColumnFieldsSvg, screenWidth * scale),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: rightColumnVertical(rightColumnFieldsSvg, screenWidth * scale),
                            ),
                            Column(
                              children: [
                                upRowHorizontal(upRowFieldsSvg, screenWidth * scale),
                                ResponsiveSizing.responsiveHeightGap(context, screenWidth * scale * 0.02),
                                Expanded(
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      return SizedBox(
                                        height: constraints.maxHeight,
                                        child: FlipCard(
                                          card: mainCard,
                                          isFlipped: isMainCardFlipped,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                //ResponsiveSizing.responsiveHeightGap(context, screenWidth * scale * 0.02),
                                fourCardsCenter(screenWidth * scale, myCardList, isFlippedList), //obrotowe flagi
                                //ResponsiveSizing.responsiveHeightGap(context, screenWidth * scale * 0.02),
                                downRowHorizontal(downRowFieldsSvg, screenWidth * scale),
                              ],
                            ),
                            buildFlagsStack(widget.teamColors, flagPositions, screenWidth * scale),
                          ],
                        ),
                      ),
                    ),
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
                                  IntrinsicWidth(
                                    child: Container(
                                      padding:
                                      EdgeInsets.all(8.0), // Dodaj margines wewnątrz prostokąta, jeśli potrzebujesz
                                      decoration: BoxDecoration(
                                        color: Colors.black, // Tu ustalamy kolor tła na czarny
                                        borderRadius: BorderRadius.circular(3.0), // Jeśli chcesz zaokrąglone rogi
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            getFlagAssetFromColor(colorFromString(getCurrentTeamColor())),
                                            width: ResponsiveSizing.scaleWidth(context, 15),
                                            height: ResponsiveSizing.scaleWidth(context, 15),
                                          ),
                                          ResponsiveSizing.responsiveWidthGap(context, 10),
                                          Row(
                                            children: [
                                              Text(
                                                "${getCurrentTeamName()} - ",
                                                style: TextStyle(
                                                  color: Palette().white,
                                                  fontFamily: 'HindMadurai',
                                                  fontSize: ResponsiveSizing.scaleHeight(context, 14),
                                                ),
                                              ),
                                              translatedText(context, 'your_turn', 14, Palette().white),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  ResponsiveSizing.responsiveHeightGap(context, 10),
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
                                                screenWidth * scale * 0.02768 - 4 + screenWidth * scale * 0.1436);
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
                                  ResponsiveSizing.responsiveHeightGap(context, 10),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        child: Icon(Icons.pause),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Palette().bluegrey, // color
                                          foregroundColor: Palette().menudark, // textColor
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          minimumSize: Size(
                                              MediaQuery
                                                  .of(context)
                                                  .size
                                                  .width *
                                                  0.02,
                                              MediaQuery
                                                  .of(context)
                                                  .size
                                                  .height *
                                                  0.04),
                                        ),
                                        onPressed: () {
                                          showExitGameDialog(context);
                                        },
                                      ),
                                      ResponsiveSizing.responsiveWidthGap(context, 10),
                                      ElevatedButton(
                                        child: Icon(Icons.info_outlined),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Palette().bluegrey, // color
                                          foregroundColor: Palette().menudark, // textColor
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          minimumSize: Size(
                                              MediaQuery
                                                  .of(context)
                                                  .size
                                                  .width *
                                                  0.02,
                                              MediaQuery
                                                  .of(context)
                                                  .size
                                                  .height *
                                                  0.04),
                                        ),
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
                                      ),
                                      ResponsiveSizing.responsiveWidthGap(context, 10),
                                      ElevatedButton(
                                        child: Icon(Icons.highlight),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Palette().bluegrey, // color
                                          foregroundColor: Palette().menudark, // textColor
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          minimumSize: Size(
                                              MediaQuery
                                                  .of(context)
                                                  .size
                                                  .width *
                                                  0.02,
                                              MediaQuery
                                                  .of(context)
                                                  .size
                                                  .height *
                                                  0.04),
                                        ),
                                        onPressed: () {
                                          _controller.forward(from: 0);
                                        },
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      )),
    );
  }

  List<GameCard> myCardList = [
    GameCard('assets/time_to_party_assets/card_microphone.svg', 'assets/time_to_party_assets/card_star_green.svg'),
    GameCard('assets/time_to_party_assets/card_rymes.svg', 'assets/time_to_party_assets/card_star_blue_light.svg'),
    GameCard('assets/time_to_party_assets/card_letters.svg', 'assets/time_to_party_assets/card_star_yellow.svg'),
    GameCard('assets/time_to_party_assets/card_pantomime.svg', 'assets/time_to_party_assets/card_star_blue_dark.svg'),
  ];
  GameCard mainCard = GameCard(
      'assets/time_to_party_assets/card_arrows.svg', 'assets/time_to_party_assets/card_star_pink.svg');

  List<String> generateNewFieldsList(List<String> upRow, List<String> downRow, List<String> leftColumn,
      List<String> rightColumn) {
    List<String> newFields = [];

    // Dodaj elementy z leftColumn w odwrotnej kolejności, zaczynając od indeksu 14 do 8
    for (int i = leftColumn.length - 1; i >= 0; i--) {
      newFields.add(leftColumn[i]);
    }

    // Dodaj elementy z upRow
    newFields.addAll(upRow);

    // Dodaj elementy z rightColumn
    newFields.addAll(rightColumn);

    // Dodaj elementy z downRow w odwrotnej kolejności, zaczynając od indeksu 8 do 4
    for (int i = downRow.length - 1; i >= 0; i--) {
      newFields.add(downRow[i]);
    }

    return newFields;
  }

  List<bool> isFlippedList = [false, false, false, false]; // zakładam domyślnie, że karty są odwrócone
  bool isMainCardFlipped = false;


  Widget fourCardsCenter(double screenWidth, List<GameCard> cardList, List<bool> isFlippedList) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < cardList.length; i++) ...[
          SizedBox(width: screenWidth * 0.02768 - 4),
          SizedBox(
            width: screenWidth * 0.1436,
            child: FlipCard(
              card: cardList[i],
              isFlipped: isFlippedList[i],
            ),
          ),
        ],
        SizedBox(width: screenWidth * 0.02768 - 4), // dodatkowy SizedBox na końcu
      ],
    );
  }

  final Random rng = Random();

  // Mapowanie FieldType do nazwy pliku SVG
  final Map<FieldType, String> fieldTypes = {
    FieldType.arrow: 'field_arrows',
    FieldType.rhyme: 'field_sheet',
    FieldType.alphabet: 'field_letters',
    FieldType.pantomime: 'field_pantomime',
    FieldType.famousPeople: 'field_microphone',
    FieldType.start: 'field_start',
    FieldType.starBlueDark: 'field_star_blue_dark',
    FieldType.starBlueLight: 'field_star_blue_light',
    FieldType.starGreen: 'field_star_green',
    FieldType.starPink: 'field_star_pink',
    FieldType.starYellow: 'field_star_yellow',
  };

  //mapowanie pol oraz ich ilosci
  final Map<FieldType, int> fieldCount = {
    FieldType.arrow: 3,
    FieldType.rhyme: 3,
    FieldType.alphabet: 3,
    FieldType.pantomime: 3,
    FieldType.famousPeople: 3,
    FieldType.start: 1,
    FieldType.starBlueDark: 1,
    FieldType.starBlueLight: 1,
    FieldType.starGreen: 1,
    FieldType.starPink: 1,
    FieldType.starYellow: 1,
  };

  //tasowanie pol tak aby sie nie powtarzaly, za wyjatkiem ostatnich 3 na liscie, czasem wystepuja jak są obok siebie ale to moze odwrotnie bede wkladac(od tylu generowac te listy?)
  List<String> _getShuffledFields() {
    List<FieldType> fields = [];
    fieldCount.forEach((field, count) {
      for (int i = 0; i < count; i++) {
        fields.add(field);
      }
    });

    List<FieldType> shuffledFields = [];
    shuffledFields.add(fields.removeAt(fields.indexOf(FieldType.start)));

    while (fields.isNotEmpty) {
      var nextIndex = rng.nextInt(fields.length);
      FieldType nextField = fields.removeAt(nextIndex);

      if (shuffledFields.last != nextField &&
          (shuffledFields.length < 3 || shuffledFields[shuffledFields.length - 3] != nextField)) {
        shuffledFields.add(nextField);
      } else if (fields.length <= 3) {
        shuffledFields.add(nextField); // breaking the rule when there are less than 3 fields left
      } else {
        fields.add(nextField);
      }
    }
    // Zamieniamy FieldType na nazwy plików SVG
    List<String> shuffledSvgFields = shuffledFields.map((field) => fieldTypes[field]!).toList();

    shuffledSvgFields.remove(fieldTypes[FieldType.start]);
    shuffledSvgFields.insert(13, fieldTypes[FieldType.start]!);

    return shuffledSvgFields;
  }

  //generowanie widgetu row
  Widget generateRow(List<String> fields, double screenWidth) {
    List<Widget> children = [];

    for (String field in fields) {
      children.add(SvgPicture.asset('assets/time_to_party_assets/$field.svg', width: screenWidth * 0.1436));
      children.add(SizedBox(width: screenWidth * 0.02768 - 4));
    }
    // Usunięcie ostatniego SizedBox
    children.removeLast();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  //generowanie widgetu kolumny
  Widget generateColumn(List<String> fields, double screenWidth) {
    List<Widget> children = [];

    for (String field in fields) {
      children.add(SvgPicture.asset('assets/time_to_party_assets/$field.svg', width: screenWidth * 0.1436));
      children.add(SizedBox(height: screenWidth * 0.02768 - 4));
    }
    // Usunięcie ostatniego SizedBox
    children.removeLast();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  //tworzenie row gornej z listy pol itd..
  Widget upRowHorizontal(List<String> fields, double screenWidth) {
    return generateRow(fields, screenWidth);
  }

  Widget downRowHorizontal(List<String> fields, double screenWidth) {
    return generateRow(fields, screenWidth);
  }

  Widget leftColumnVertical(List<String> fields, double screenWidth) {
    return generateColumn(fields, screenWidth);
  }

  Widget rightColumnVertical(List<String> fields, double screenWidth) {
    return generateColumn(fields, screenWidth);
  }

  //budowanie widgetu flag i liczenie wszystkich przesuniec itp
  Widget buildFlagsStack(List<Color> teamColors, List<Offset> flagPositions, double screenWidth) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ...teamColors
            .asMap()
            .entries
            .expand((entry) {
          int index = entry.key;
          Color color = entry.value;
          /*
          List<String> flagAssets = [
            'assets/time_to_party_assets/main_board/flags/flag00A2AC.svg',
            'assets/time_to_party_assets/main_board/flags/flag01B210.svg',
            'assets/time_to_party_assets/main_board/flags/flag9400AC.svg',
            'assets/time_to_party_assets/main_board/flags/flagF50000.svg',
            'assets/time_to_party_assets/main_board/flags/flagFFD335.svg',
            'assets/time_to_party_assets/main_board/flags/flagFFFFFF.svg',
          ];*/
          // kolka
          List<String> flagAssets = [
            'assets/time_to_party_assets/main_board/flags/kolko00A2AC.svg',
            'assets/time_to_party_assets/main_board/flags/kolko01B210.svg',
            'assets/time_to_party_assets/main_board/flags/kolko9400AC.svg',
            'assets/time_to_party_assets/main_board/flags/kolkoF50000.svg',
            'assets/time_to_party_assets/main_board/flags/kolkoFFD335.svg',
            'assets/time_to_party_assets/main_board/flags/kolko1C1AAA.svg',
          ];
          return flagAssets.where((flag) {
            String flagColorHex = 'FF' + flag
                .split('/')
                .last
                .split('.')
                .first
                .substring(5); //zmiana z 4 na 5
            Color flagColor = Color(int.parse(flagColorHex, radix: 16));
            if (color.value == flagColor.value) {
              return true;
            } else {
              return false;
            }
          }).map((flag) {
            return AnimatedPositioned(
              duration: Duration(seconds: 1),
              bottom: (teamColors.length == 2 || (teamColors.length == 3 && index != 1))
                  ? flagPositions[index].dy + 23
                  : (teamColors.length == 3 && index == 1)
                  ? flagPositions[index].dy + 46
                  : teamColors.length == 4
                  ? flagPositions[index].dy + 10 + (index ~/ 2) * 40 - 4
                  : (teamColors.length == 5 && index == 1) // kula nr 2 dla 5 kulek
                  ? flagPositions[index].dy + 10 + (index ~/ 3) * 25 - 11
                  : (teamColors.length == 5 && index == 4) // kula nr 5 dla 5 kulek
                  ? flagPositions[index].dy + 10 + (index ~/ 3) * 25 + 11
                  : (teamColors.length == 6 && index == 1) // kula nr 2 dla 6 kulek
                  ? flagPositions[index].dy + 10 + (index ~/ 3) * 25 - 11
                  : (teamColors.length == 6 && index == 4) // kula nr 5 dla 6 kulek
                  ? flagPositions[index].dy + 10 + (index ~/ 3) * 25 + 11
                  : flagPositions[index].dy + 10 + (index ~/ 3) * 25,
              // ustalanie pozycji flagi gora/dol w zaleznosci od ilosci flag
              left: (teamColors.length == 2)
                  ? flagPositions[index].dx + (index % 2) * 45 - 8
                  : (teamColors.length == 4)
                  ? flagPositions[index].dx + (index % 2) * 35 - 3
                  : (teamColors.length == 5 || teamColors.length == 6 || teamColors.length == 3)
                  ? flagPositions[index].dx + (index % 3) * 25 - 8
                  : flagPositions[index].dx +
                  (index % 3) * 25 -
                  8, // ustalanie pozycji flag lewo/prawo w zaleznosci od ilosci flag
              child: PionekWithRipple(assetPath: flag, animation: _animation, screenWidth: screenWidth),
            );
          });
        }).toList(),
      ],
    );
  }

  String getFlagAssetFromColor(Color color) {
    /*
          List<String> flagAssets = [
            'assets/time_to_party_assets/main_board/flags/flag00A2AC.svg',
            'assets/time_to_party_assets/main_board/flags/flag01B210.svg',
            'assets/time_to_party_assets/main_board/flags/flag9400AC.svg',
            'assets/time_to_party_assets/main_board/flags/flagF50000.svg',
            'assets/time_to_party_assets/main_board/flags/flagFFD335.svg',
            'assets/time_to_party_assets/main_board/flags/flagFFFFFF.svg',
          ];*/
    // kolka
    List<String> flagAssets = [
      'assets/time_to_party_assets/main_board/flags/kolko00A2AC.svg',
      'assets/time_to_party_assets/main_board/flags/kolko01B210.svg',
      'assets/time_to_party_assets/main_board/flags/kolko9400AC.svg',
      'assets/time_to_party_assets/main_board/flags/kolkoF50000.svg',
      'assets/time_to_party_assets/main_board/flags/kolkoFFD335.svg',
      'assets/time_to_party_assets/main_board/flags/kolko1C1AAA.svg',
    ];
    for (String flag in flagAssets) {
      String flagColorHex = 'FF' + flag
          .split('/')
          .last
          .split('.')
          .first
          .substring(5); //zmiana z 4 na 5
      Color flagColor = Color(int.parse(flagColorHex, radix: 16));
      if (color.value == flagColor.value) {
        return flag;
      }
    }
    return 'assets/time_to_party_assets/main_board/flags/kolko00A2AC.svg';
  }

  //kolo fortuny
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

  //funkcja do wyswietlania koloru druzyny w app_barze
  Color colorFromString(String colorAsString) {
    String colorString = colorAsString.split('(0x')[1].split(')')[0]; // Extracting hex value from the string.
    int colorInt = int.parse(colorString, radix: 16); // Parsing hex string into an integer.
    return Color(colorInt); // Creating a new Color object.
  }

  @override
  void dispose() {
    _subscription.cancel();
    _controller.dispose();
    _selectedController.close();
    selected.close();
    super.dispose();
  }

  void _showAnimatedAlertDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations
          .of(context)
          .modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
        return Center(
            child: AlertDialog(
                backgroundColor: Palette().white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: letsText(context, 'Tapnij w koło by zakręcić', 20, Palette().pink, textAlign: TextAlign.center)
            )
        );
      },
      transitionBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation,
          Widget child) {
        // Jeśli dialog się pojawia
        if (animation.status == AnimationStatus.forward) {
          return ScaleTransition(
            scale: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        }
        // Jeśli dialog znika
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }

  //cieniowany tekst
  Widget strokedText(String text) {
    return Transform.rotate(
      angle: 90 * 3.14 / 180,
      child: Stack(
        children: <Widget>[
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

  //funkcja przesuniecia flagi, kroki
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

    isAnimating = false;

    if (newFieldsList[flagSteps[flagIndex]] == 'field_sheet' ||
        newFieldsList[flagSteps[flagIndex]] == 'field_letters' ||
        newFieldsList[flagSteps[flagIndex]] == 'field_microphone' ||
        newFieldsList[flagSteps[flagIndex]] == 'field_pantomime' ||
        newFieldsList[flagSteps[flagIndex]] == 'field_arrows'
    ) {
      setState(() {
        isFlippedList = [false, false, false, false];
        isMainCardFlipped = false;
      });
    } else {
      setState(() {
        isFlippedList = [true, true, true, true];
        isMainCardFlipped = true;
      });
    }
    await Future.delayed(Duration(seconds: 1));
    String currentTeamName = getCurrentTeamName();
    Color currentTeamColor = widget.teamColors[currentTeamIndex];

    showTransferDeviceDialog(context, newFieldsList[flagSteps[flagIndex]], currentTeamName, currentTeamColor);

    //showTransferDeviceDialog(context);
    //wyswietlanie w alert dialogu danego pola na którym stoi dana flaga :) - dziala niezaleznie od przetasowania pól :)
    //showDialogTest(context, [newFieldsList[flagSteps[flagIndex]]]);

    setState(() {
      currentFlagIndex = (currentFlagIndex + 1) % widget.teamColors.length;
    });
    currentTeamIndex = currentFlagIndex;
  }

  String getCurrentTeamName() {
    return widget.teamNames[currentTeamIndex].toString();
  }

  String getCurrentTeamColor() {
    return widget.teamColors[currentTeamIndex].toString();
  }

  void showExitGameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Palette().white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: translatedText(context, 'are_you_sure_game_leave', 20, Palette().pink, textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SvgPicture.asset('assets/time_to_party_assets/line_instruction_screen.svg'),
              ),
              ResponsiveSizing.responsiveHeightGap(context, 10),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette().pink,
                    // color
                    foregroundColor: Palette().white,
                    // textColor
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    minimumSize:
                    Size(MediaQuery
                        .of(context)
                        .size
                        .width * 0.5, MediaQuery
                        .of(context)
                        .size
                        .height * 0.05),
                    textStyle:
                    TextStyle(fontFamily: 'HindMadurai', fontSize: ResponsiveSizing.scaleHeight(context, 20)),
                  ),
                  onPressed: () async {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    hasShownAlertDialog = false;
                  },
                  child: Text('OK'),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: translatedText(context, 'cancel', 16, Palette().bluegrey, textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static void showDialogTest(BuildContext context, List<String> newFieldsList) {
    String allFieldsText = newFieldsList.join(", ");

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("My List"),
      content: Text(allFieldsText, style: TextStyle(color: Colors.white)),
      actions: [
        ElevatedButton(
          child: Text("OK"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showTransferDeviceDialog(BuildContext context, String fieldValue, String currentTeamName, Color currentTeamColor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Palette().white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title:
          translatedText(context, 'pass_the_device_to_the_person', 20, Palette().pink, textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SvgPicture.asset('assets/time_to_party_assets/line_instruction_screen.svg'),
              ),
              ResponsiveSizing.responsiveHeightGap(context, 10),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette().pink,
                    foregroundColor: Palette().white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    minimumSize:
                    Size(MediaQuery
                        .of(context)
                        .size
                        .width * 0.5, MediaQuery
                        .of(context)
                        .size
                        .height * 0.05),
                    textStyle:
                    TextStyle(fontFamily: 'HindMadurai', fontSize: ResponsiveSizing.scaleHeight(context, 20)),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PlayGameboardCard(
                              teamNames: [currentTeamName],
                              teamColors: [currentTeamColor],
                              currentField: [fieldValue],
                            ),
                      ),
                    );
                  },
                  child: translatedText(context, 'done', 20, Palette().white, textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

  enum FieldType {
  arrow,
  rhyme,
  alphabet,
  pantomime,
  famousPeople,
  charades,
  start,
  starBlueDark,
  starBlueLight,
  starGreen,
  starPink,
  starYellow
}

class GameCard {
  final String frontAsset;
  final String backAsset;

  GameCard(this.frontAsset, this.backAsset);
}

class FlipCard extends StatefulWidget {
  final GameCard card;
  final bool isFlipped;

  FlipCard({required this.card, required this.isFlipped});

  @override
  _FlipCardState createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 1));
    if (widget.isFlipped) {
      _controller.value = 0.5; // jeśli karta ma być odwrócona
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double value = _controller.value;
        bool isFaceUp = value < 0.5;
        final Matrix4 transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001) // punkt perspektywy
          ..rotateY(pi * value);
        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: Container(
            child: isFaceUp ? SvgPicture.asset(widget.card.frontAsset) : SvgPicture.asset(widget.card.backAsset),
          ),
        );
      },
    );
  }

  @override
  void didUpdateWidget(covariant FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}


class PionekWithRipple extends StatelessWidget {
  final String assetPath;
  final Animation<double> animation;

  double screenWidth;

  PionekWithRipple({required this.assetPath, required this.animation, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        SvgPicture.asset(assetPath, width: screenWidth / 15.09, height: screenWidth / 15.09),
        Positioned(
            left: -50,
            top: -50,
            right: -50,
            bottom: -50,
            child: RippleEffect(animation: animation)
        ),
      ],
    );
  }

}

class RippleEffect extends StatelessWidget {
  final Animation<double> animation;

  RippleEffect({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
            children: [
         Container(
          width: 20 + (animation.value * 100), // zakładając, że początkowa wielkość pionka to 50
          height: 20 + (animation.value * 100),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.yellow.withOpacity(1 - animation.value), // zakładając, że pionek jest niebieski
          ),
        )
        ],);
      },
    );
  }
}
