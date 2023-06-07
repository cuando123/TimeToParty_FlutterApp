import 'dart:async';
import 'dart:math';
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
  List<String> upRowFieldsSvg = [];
  List<String> downRowFieldsSvg = [];
  List<String> leftColumnFieldsSvg = [];
  List<String> rightColumnFieldsSvg = [];
  List<String> allFieldsSvg = [];
  List<String> newFieldsList = [];
  @override
  void initState() {
    super.initState();
    allFieldsSvg = _getShuffledFields();
    upRowFieldsSvg = allFieldsSvg.sublist(0, 4);
    downRowFieldsSvg = allFieldsSvg.sublist(4, 8);
    leftColumnFieldsSvg = allFieldsSvg.sublist(8, 14);
    rightColumnFieldsSvg = allFieldsSvg.sublist(14, 20);

    newFieldsList = generateNewFieldsList(upRowFieldsSvg, downRowFieldsSvg, leftColumnFieldsSvg, rightColumnFieldsSvg);

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
          title: Row(
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
                        child: leftColumnVertical(leftColumnFieldsSvg, screenWidth),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: rightColumnVertical(rightColumnFieldsSvg, screenWidth),
                      ),
                      Column(
                        children: [
                          Positioned(
                            top: 0,
                            child: upRowHorizontal(upRowFieldsSvg, screenWidth),
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
                          downRowHorizontal(downRowFieldsSvg, screenWidth),
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
                                  translatedText(context, 'game_rules', 20, Palette().white),
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
                                  int count = percentageScreen < 40
                                      ? 4
                                      : 2; // Załóżmy, że chcemy dwie kolumny na szerokich ekranach, a na węższych - tylko jedną.
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
                                  minimumSize: Size(ResponsiveSizing.scaleWidth(context, 220),
                                      ResponsiveSizing.responsiveHeightWithCondition(context, 51, 45, 650)),
                                  //textStyle: TextStyle(fontFamily: 'HindMadurai', fontSize: ResponsiveText.scaleHeight(context, 20)),
                                ),
                                icon: Icon(Icons.play_circle_rounded, size: ResponsiveSizing.scaleHeight(context, 32)),
                                onPressed: () {},
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

  List<String> generateNewFieldsList(List<String> upRow, List<String> downRow, List<String> leftColumn, List<String> rightColumn) {
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
  //mapowanie pol oraz ich ilosci - TODO cos z niebieska gwiazdka
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
                          : flagPositions[index].dy +
                              10 +
                              (index ~/ 3) * 25, // ustalanie pozycji flagi gora/dol w zaleznosci od ilosci flag
              left: (teamColors.length == 2 || teamColors.length == 4)
                  ? flagPositions[index].dx + (index % 2) * 25 + 5
                  : (teamColors.length == 5 || teamColors.length == 6 || teamColors.length == 3)
                      ? flagPositions[index].dx + (index % 3) * 25 - 8
                      : flagPositions[index].dx +
                          (index % 3) * 25 -
                          8, // ustalanie pozycji flag lewo/prawo w zaleznosci od ilosci flag
              child: Transform.rotate(
                angle: (teamColors.length == 4)
                    ? ((index % 2 == 0) ? -10 : 15) * (3.14 / 180)
                    : ((index % 3 == 0)
                            ? -10
                            : (index % 3 == 2)
                                ? 15
                                : 0) *
                        (3.14 / 180), //obroty flag dopasowane od ilosci
                child: Transform(
                  transform: Matrix4.identity()
                    ..scale(
                        (teamColors.length == 4)
                            ? ((index == 0 || index == 2) ? -1.0 : 1.0) // odbicia flag ustalone od ilosci
                            : ((index == 0 || index == 3) ? -1.0 : 1.0),
                        1.0),
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
    _animationController.dispose();
    _selectedController.close();
    selected.close();
    super.dispose();
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
    //przekaz urzadzenie osobie opisujacej TODO
    //showTransferDeviceDialog(context);
    //wyswietlanie w alert dialogu danego pola na którym stoi dana flaga :) - dziala niezaleznie od przetasowania pól :)
    showDialogTest(context, [newFieldsList[flagSteps[flagIndex]]]);
    print(flagSteps[flagIndex]);

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

  static void showDialogTest(BuildContext context, List<String> newFieldsList) {
    String allFieldsText = newFieldsList.join(", ");

      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: Text("My List"),
        content:Text(allFieldsText,style: TextStyle(color: Colors.white)),
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

  static void showTransferDeviceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Palette().white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: translatedText(context, 'would_you_like_exit', 20, Palette().pink, textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SvgPicture.asset('assets/time_to_party_assets/line_instruction_screen.svg'),
              ),
              ResponsiveSizing.responsiveHeightGap(context, 10),
              translatedText(context, 'redirected_to_the_website', 16, Palette().menudark, textAlign: TextAlign.center),
              ResponsiveSizing.responsiveHeightGap(context, 10),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette().pink, // color
                    foregroundColor: Palette().white, // textColor
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    minimumSize:
                        Size(MediaQuery.of(context).size.width * 0.5, MediaQuery.of(context).size.height * 0.05),
                    textStyle:
                        TextStyle(fontFamily: 'HindMadurai', fontSize: ResponsiveSizing.scaleHeight(context, 20)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
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
      lowerBound: 0.0,
      upperBound: 1.0, // Ustawiamy górną granicę na 2.0, co oznacza dwa obroty
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.linear);
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
            if (_controller.status == AnimationStatus.completed) {
              _controller.reverse();
            } else if (_controller.status == AnimationStatus.dismissed) {
              _controller.forward();
            }
          }
        },
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final rotationAngle = _animation.value * 2 * 3.14;
            final isSecondHalf = (_animation.value * 4) % 4 >= 2;
            final isFrontVisible = (_animation.value * 4) % 2 < 1;
            final isVisible = (isSecondHalf && !isFrontVisible) || (!isSecondHalf && isFrontVisible);

            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(rotationAngle),
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: isVisible ? 1.0 : 0.0,
                    child: SvgPicture.asset(
                      'assets/time_to_party_assets/card_microphone.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  Opacity(
                    opacity: isVisible ? 0.0 : 1.0,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(3.14),
                      child: SvgPicture.asset(
                        'assets/time_to_party_assets/card_pantomime.svg',
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
