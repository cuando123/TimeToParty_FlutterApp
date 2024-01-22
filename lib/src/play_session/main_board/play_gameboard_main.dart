import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:game_template/src/play_session/alerts_and_dialogs.dart';
import 'package:game_template/src/play_session/card_screens/play_gameboard_card.dart';
import 'package:game_template/src/play_session/extensions.dart';
import 'package:game_template/src/play_session/main_board/main_fortune_wheel.dart';
import 'package:game_template/src/play_session/main_board/ripple_effect_pionka.dart';
import 'package:game_template/src/play_session/main_board/triple_button.dart';
import 'package:provider/provider.dart';

import '../../app_lifecycle/responsive_sizing.dart';
import '../../app_lifecycle/translated_text.dart';
import '../../audio/audio_controller.dart';
import '../../audio/sounds.dart';
import '../../in_app_purchase/services/iap_service.dart';
import '../../style/palette.dart';
import '../../style/stars_animation.dart';
import '../../win_game/win_game_screen.dart';
import 'InstantTooltip.dart';
import 'animated_card/animated_card.dart';

class PlayGameboard extends StatefulWidget {
  final List<String> teamNames;
  final List<Color> teamColors;

  const PlayGameboard({super.key, required this.teamNames, required this.teamColors});

  @override
  _PlayGameboardState createState() => _PlayGameboardState();
}

class _PlayGameboardState extends State<PlayGameboard> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late StreamController<int> _selectedController = StreamController<int>.broadcast();
  late StreamSubscription<int> _subscription;
  late List<Offset> flagPositions;
  late List<int> flagSteps;
  final List<int> _wheelValues = [0, 1, 2, 0, 1, 2];
  bool hasShownAlertDialog = false;
  bool showGlow = true;
  late String currentFieldName = 'default';
  int selectedValue = 0;
  int currentTeamIndex = 0;
  int currentFlagIndex = 0;
  bool isAnimating = false;
  bool showCardAnimation = false;
  StreamController<int> selected = StreamController<int>();
  List<String> upRowFieldsSvg = [];
  List<String> downRowFieldsSvg = [];
  List<String> leftColumnFieldsSvg = [];
  List<String> rightColumnFieldsSvg = [];
  List<String> allFieldsSvg = [];
  List<String> newFieldsList = [];
  bool _showStarsAnimation = false;
  bool showAnimatedCard = true;
  Timer? _inactivityTimer;
  late List<String> mutableTeamNames;
  late List<Color> mutableTeamColors;
  late List<bool> pionekZaBurta;

  @override
  void initState() {
    super.initState();
    mutableTeamNames = List<String>.from(widget.teamNames);
    mutableTeamColors = List<Color>.from(widget.teamColors);
    pionekZaBurta = List.filled(mutableTeamColors.length, false);
    _controller = AnimationController(duration: const Duration(seconds: 1), vsync: this);
    allFieldsSvg = _getShuffledFields();
    upRowFieldsSvg = allFieldsSvg.sublist(0, 4);
    downRowFieldsSvg = allFieldsSvg.sublist(4, 8);
    leftColumnFieldsSvg = allFieldsSvg.sublist(8, 14);
    rightColumnFieldsSvg = allFieldsSvg.sublist(14, 20);
    newFieldsList = generateNewFieldsList(upRowFieldsSvg, downRowFieldsSvg, leftColumnFieldsSvg, rightColumnFieldsSvg);
    _selectedController = StreamController<int>.broadcast();
    flagPositions = List.generate(mutableTeamColors.length, (index) => Offset(0, 0));
    flagSteps = List.filled(mutableTeamColors.length, 0);
    _subscription = _selectedController.stream.listen((selectedIndex) {
      safeSetState(() {
        selectedValue = _wheelValues[selectedIndex] + 1; // Zaktualizuj wartość selectedValue
      });
    });
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.value = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!hasShownAlertDialog) {
        AnimatedAlertDialog.showAnimatedDialog(context, 'tap_the_wheel_to_spin', SfxType.correct_answer, 2, 20, false, false, true);
        safeSetState(() {
          _controller.forward(from: 0);
        });
        hasShownAlertDialog = true;
      }
    });
  }
  void onCardSelected(String selectedCardIndex) {
    // aktualizacja stanu na podstawie wybranej karty i przekazanie
    setState(() {
      this.currentFieldName = selectedCardIndex;
      Navigator.of(context).pop();
      navigateWithDelay(context, getCurrentTeamName(), mutableTeamColors[currentTeamIndex]);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: () async {
        await SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
        );
        AnimatedAlertDialog.showExitGameDialog(context, hasShownAlertDialog, '',mutableTeamNames, mutableTeamColors, false);
        return false; // return false to prevent the pop operation
      },
      child: CustomBackground(
        child: Scaffold(
          body: Stack(
            children: [
              LayoutBuilder(builder: (context, constraints) {
                double screenWidth = constraints.maxWidth;
                double screenHeight = constraints.maxHeight;
                double scale = min((screenHeight * 0.55) / screenWidth, 1.0);
                print("Widthscreen: $screenWidth");
                print("Heigtscreen: $screenHeight");
                print("Heigtscreen055: ${screenHeight * 0.55}");
                print("Scale: $scale");
                return Column(
                  children: <Widget>[
                    Container(
                      height: screenHeight * 0.55,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: Colors.white, width: 2.0), // To dodaje białą linię na dole kontenera.
                        ),
                      ),
                      child: Center(
                        child: Transform.scale(
                          scale: scale,
                          child: SizedBox(
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
                                        child: InstantTooltip(
                                            message: getTranslatedString(context, 'deck_of_cards'),
                                          child: SvgPicture.asset('assets/time_to_party_assets/center_main_board.svg'),
                                        ),
                                      ),
                                      downRowHorizontal(downRowFieldsSvg, screenWidth * scale),
                                    ],
                                  ),

                                  buildFlagsStack(widget.teamColors, flagPositions, screenWidth * scale, screenWidth * scale * 0.02768 -
                                      4 +
                                      screenWidth * scale * 0.1436),

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
                                  if (_showStarsAnimation) StarsAnimation(),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0), //
                                    child: Column(
                                      children: [
                                        IntrinsicWidth(
                                          child: Container(
                                            padding: EdgeInsets.all(
                                                8.0), // Dodaj margines wewnątrz prostokąta, jeśli potrzebujesz
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
                                                safeSetState(() {
                                                  _showStarsAnimation = true; //gwiazdki on
                                                });
                                                isAnimating = true;
                                                final randomIndex = Fortune.randomInt(0, _wheelValues.length);
                                                _selectedController = StreamController<int>.broadcast();
                                                final audioController = context.read<AudioController>();
                                                audioController.playSfx(SfxType.roulette_wheel); //sound kola fortuny
                                                selected.add(randomIndex);
                                                Future.delayed(Duration(seconds: 3), //czas krecenia kolem
                                                    () {
                                                  if (mounted) {
                                                    safeSetState(() {
                                                      selectedValue = _wheelValues[randomIndex] + 1;
                                                      _showStarsAnimation = false;
                                                      moveFlag(context,
                                                          selectedValue,
                                                          currentFlagIndex,
                                                          screenWidth * scale * 0.02768 -
                                                              4 +
                                                              screenWidth * scale * 0.1436);
                                                    });
                                                  }
                                                });
                                            },
                                            child: MyFortuneWheel(selected: selected),
                                          ),
                                        ),
                                        ResponsiveSizing.responsiveHeightGap(context, 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            TripleButton(
                                                _controller,
                                                () => AnimatedAlertDialog.showExitGameDialog(
                                                    context, hasShownAlertDialog, '',mutableTeamNames, mutableTeamColors, false)),
                                            //DO TESTOW -> PRZYCISK KTORYM OTWIERAM DANA KARTE KTORA CHCE, KARTA, TEST
                                            /*TextButton(
                                                onPressed: () {
                                                  safeSetState(() {
                                                    showAnimatedCard = true;
                                                    showCardAnimation = true;
                                                    currentFieldName = 'field_arrows';
                                                    /*moveFlag(context,
                                                        19,
                                                        0,
                                                        screenWidth * scale * 0.02768 -
                                                            4 +
                                                            screenWidth * scale * 0.1436);*/
                                                  });
                                                },
                                                child: Text('TEST')),*/
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
              if (showAnimatedCard && showCardAnimation)
                AnimatedCard(
                    showAnimatedCard: showAnimatedCard,
                    onCardTapped: () {
                      safeSetState(() {
                        showCardAnimation = false;
                        showAnimatedCard = true;
                      });
                      navigateWithDelay(context, getCurrentTeamName(), mutableTeamColors[currentTeamIndex]);
                    },
                    onArrowCardTapped: () {
                      // Dodajemy nowy callback
                      safeSetState(() {
                        showAnimatedCard = false; // Ukryj AnimatedCard
                      });
                      // Tutaj możesz również wywołać navigateWithDelay, jeśli to konieczne
                    },
                    onCardSelected: onCardSelected,
                    selectedCardIndex: currentFieldName,
                    parentContext: context,
                    currentTeamName: getCurrentTeamName(),
                    teamColor: mutableTeamColors[currentTeamIndex])
            ],
          ),
        ),
      ),
    );
  }



  List<String> generateNewFieldsList(
      List<String> upRow, List<String> downRow, List<String> leftColumn, List<String> rightColumn) {
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

  final Random rng = Random();

  // Mapowanie FieldType do nazwy pliku SVG
  final Map<FieldType, String> fieldTypesFree = {
    FieldType.arrow: 'field_arrows',
    FieldType.rhyme: 'field_sheet',
    FieldType.alphabet: 'field_letters',
    FieldType.pantomime: 'field_pantomime',
    FieldType.famousPeople: 'field_microphone',
    FieldType.starTaboo: 'field_taboo',
    FieldType.start: 'field_start',
  };
  final Map<FieldType, String> fieldTypesPremium = {
    FieldType.arrow: 'field_arrows',
    FieldType.rhyme: 'field_sheet',
    FieldType.alphabet: 'field_letters',
    FieldType.pantomime: 'field_pantomime',
    FieldType.famousPeople: 'field_microphone',
    FieldType.starTaboo: 'field_taboo',
    FieldType.start: 'field_start',
    FieldType.starBlueDark: 'field_star_blue_dark',
    FieldType.starPink: 'field_star_pink',
    FieldType.starGreen: 'field_star_green',
    FieldType.starYellow: 'field_star_yellow',
  };
  Map<FieldType, String> getFieldTypes(BuildContext context) {
    var purchaseController = Provider.of<IAPService>(context, listen: false);
    if (purchaseController.isPurchased) {
      return fieldTypesPremium; // Zwraca mapę premium
    } else {
      return fieldTypesFree; // Zwraca mapę darmową
    }
  }
  //mapowanie pol oraz ich ilosci

  final Map<FieldType, int> fieldCountFree = {
    FieldType.arrow: 4,
    FieldType.rhyme: 3,
    FieldType.alphabet: 3,
    FieldType.pantomime: 3,
    FieldType.famousPeople: 3,
    FieldType.starTaboo: 3,
    FieldType.start: 1,
  };
  final Map<FieldType, int> fieldCountPremium = {
    FieldType.arrow: 3,
    FieldType.rhyme: 3,
    FieldType.alphabet: 3,
    FieldType.pantomime: 2,
    FieldType.famousPeople: 2,
    FieldType.starTaboo: 2,
    FieldType.start: 1,
    FieldType.starBlueDark: 1,
    FieldType.starPink: 1,
    FieldType.starGreen: 1,
    FieldType.starYellow: 1,
  };
  Map<FieldType, int> getCountTypes(BuildContext context) {
    var purchaseController = Provider.of<IAPService>(context, listen: false);
    if (purchaseController.isPurchased) {
      return fieldCountPremium; // Zwraca mapę premium
    } else {
      return fieldCountFree; // Zwraca mapę darmową
    }
  }



  final Map<String, String> fieldDescriptions = {
    'field_arrows': 'field_arrows_description',
    'field_sheet': 'field_sheet_description',
    'field_letters': 'field_letters_description',
    'field_pantomime': 'field_pantomime_description',
    'field_microphone': 'field_microphone_description',
    'field_taboo': 'field_taboo_description',
    'field_start': 'field_start_description',
    'field_star_blue_dark': 'field_star_blue_dark_description',
    'field_star_pink': 'field_star_pink_description',
    'field_star_green': 'field_star_green_description',
    'field_star_yellow': 'field_star_yellow_description',
  };

  //tasowanie pol tak aby sie nie powtarzaly, za wyjatkiem ostatnich 3 na liscie, czasem wystepuja jak są obok siebie ale to moze odwrotnie bede wkladac(od tylu generowac te listy?)
  List<String> _getShuffledFields() {
    List<FieldType> fields = [];
    getCountTypes(context).forEach((field, count) {
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
    List<String> shuffledSvgFields = shuffledFields.map((field) => getFieldTypes(context)[field]!).toList();

    shuffledSvgFields.remove(getFieldTypes(context)[FieldType.start]);
    shuffledSvgFields.insert(13, getFieldTypes(context)[FieldType.start]!);

    return shuffledSvgFields;
  }

//generowanie widgetu row
  Widget generateRow(List<String> fields, double screenWidth) {
    List<Widget> children = [];

    for (String field in fields) {
      children.add(InstantTooltip(
        message: getTranslatedString(context, fieldDescriptions[field] ?? "default_key"),
        child: SvgPicture.asset('assets/time_to_party_assets/$field.svg', width: screenWidth * 0.1436),
      ));

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
      children.add(InstantTooltip(
        message: getTranslatedString(context, fieldDescriptions[field] ?? "default_key"),
        child: SvgPicture.asset('assets/time_to_party_assets/$field.svg', width: screenWidth * 0.1436),
      ));
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
  Widget buildFlagsStack(List<Color> teamColors, List<Offset> flagPositions, double screenWidth, double stepSize) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ...teamColors.asMap().entries.expand((entry) {
          int index = entry.key;
          Color color = entry.value;
          List<String> flagAssets = [
            'assets/time_to_party_assets/main_board/flags/kolko00A2AC.svg',
            'assets/time_to_party_assets/main_board/flags/kolko01B210.svg',
            'assets/time_to_party_assets/main_board/flags/kolko9400AC.svg',
            'assets/time_to_party_assets/main_board/flags/kolkoF50000.svg',
            'assets/time_to_party_assets/main_board/flags/kolkoFFD335.svg',
            'assets/time_to_party_assets/main_board/flags/kolko1C1AAA.svg',
          ];
          return flagAssets.where((flag) {
            String flagColorHex = 'FF${flag.split('/').last.split('.').first.substring(5)}'; //zmiana z 4 na 5
            Color flagColor = Color(int.parse(flagColorHex, radix: 16));
            if (color.value == flagColor.value) {
              return true;
            } else {
              return false;
            }
          }).map((flag) {
            return AnimatedPositioned(
              duration: Duration(milliseconds: 500),
              bottom: (teamColors.length == 2 || (teamColors.length == 3 && index != 1))
                  ? flagPositions[index].dy + stepSize * 0.2318
                  : (teamColors.length == 3 && index == 1)
                      ? flagPositions[index].dy + stepSize * 0.6760
                      : teamColors.length == 4
                          ? flagPositions[index].dy + stepSize * 0.1  + (index ~/ 2) * stepSize * 0.45 - stepSize * 0.1
                          : (teamColors.length == 5 && index == 1) // kula nr 2 dla 5 kulek
                              ? flagPositions[index].dy + stepSize * 0.01 + (index ~/ 3) * stepSize * 0.45 - stepSize * 0.2
                              : (teamColors.length == 5 && index == 4) // kula nr 5 dla 5 kulek
                                  ? flagPositions[index].dy + stepSize * 0.01 + (index ~/ 3) * stepSize * 0.45 + stepSize * 0.15
                                  : (teamColors.length == 6 && index == 1) // kula nr 2 dla 6 kulek
                                      ? flagPositions[index].dy + stepSize * 0.01 + (index ~/ 3) * stepSize * 0.45 - stepSize * 0.15
                                      : (teamColors.length == 6 && index == 4) // kula nr 5 dla 6 kulek
                                          ? flagPositions[index].dy + stepSize * 0.01 + (index ~/ 3) * stepSize * 0.45 + stepSize * 0.15
                                          : flagPositions[index].dy + stepSize * 0.01 + (index ~/ 3) * stepSize * 0.45,
              // ustalanie pozycji flagi gora/dol w zaleznosci od ilosci flag
              left: (teamColors.length == 2)
                  ? flagPositions[index].dx + (index % 2) * stepSize * 0.78 - stepSize * 0.15
                  : (teamColors.length == 4)
                      ? flagPositions[index].dx + (index % 2) * stepSize * 0.7 - stepSize * 0.1
                      : (teamColors.length == 5 || teamColors.length == 6 || teamColors.length == 3)
                          ? flagPositions[index].dx + (index % 3) * stepSize * 0.39 - stepSize * 0.15
                          : flagPositions[index].dx +
                              (index % 3) * stepSize * 0.4829 -
                  stepSize * 0.15, // ustalanie pozycji flag lewo/prawo w zaleznosci od ilosci flag
              child: PionekWithRipple(assetPath: flag, animation: _animation, screenWidth: screenWidth),
            );
          });
        }).toList(),
      ],
    );
  }

  String getFlagAssetFromColor(Color color) {
    List<String> flagAssets = [
      'assets/time_to_party_assets/main_board/flags/kolko00A2AC.svg',
      'assets/time_to_party_assets/main_board/flags/kolko01B210.svg',
      'assets/time_to_party_assets/main_board/flags/kolko9400AC.svg',
      'assets/time_to_party_assets/main_board/flags/kolkoF50000.svg',
      'assets/time_to_party_assets/main_board/flags/kolkoFFD335.svg',
      'assets/time_to_party_assets/main_board/flags/kolko1C1AAA.svg',
    ];
    for (String flag in flagAssets) {
      String flagColorHex = 'FF${flag.split('/').last.split('.').first.substring(5)}'; //zmiana z 4 na 5
      Color flagColor = Color(int.parse(flagColorHex, radix: 16));
      if (color.value == flagColor.value) {
        return flag;
      }
    }
    return 'assets/time_to_party_assets/main_board/flags/kolko00A2AC.svg';
  }

  //funkcja do wyswietlania koloru druzyny w app_barze
  Color colorFromString(String colorAsString) {
    String colorString = colorAsString.split('(0x')[1].split(')')[0]; // Extracting hex value from the string.
    int colorInt = int.parse(colorString, radix: 16); // Parsing hex string into an integer.
    return Color(colorInt); // Creating a new Color object.
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    _subscription.cancel();
    _controller.dispose();
    _selectedController.close();
    selected.close();
    super.dispose();
  }

  //funkcja przesuniecia pionka, kroki
  Future<void> moveFlag(BuildContext context, int steps, int flagIndex, double stepSize) async {
    print('Steps: $steps, flagIndex: $flagIndex, flagSteps[]: $flagSteps');
    bool hasReachedEnd = false;
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
      }
      if (newPosition == Offset(0, 0)) {
        hasReachedEnd = true; // Pionek dotarł na metę
      }
      safeSetState(() {
        flagPositions[flagIndex] = newPosition;
        final audioController = context.read<AudioController>();
        audioController.playSfx(SfxType.ripple_sound);
      });

      if (!hasReachedEnd) {
        await Future.delayed(Duration(milliseconds: 800)); // Opóźnienie tylko gdy pionek nie dotarł na metę
      }
    }
    await Future.delayed(Duration(milliseconds: 500));

    if (flagSteps[flagIndex] > 19){
      pionekZaBurta[currentTeamIndex] = true;
      currentFieldName = 'field_start';
      if (pionekZaBurta.every((index) => index == true)) {
        await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => WinGameScreen(
              teamNames: widget.teamNames,
              teamColors: widget.teamColors,
            ),
        ));
        print("Wszystkie pionki na meciee!");
      } else {
      AnimatedAlertDialog.showEndGameDialog(
          context,
          currentTeamIndex,
          mutableTeamNames,
          mutableTeamColors,
              () {
                safeSetState(() {
                  currentFlagIndex = findNextActiveFlagIndex(currentFlagIndex, pionekZaBurta, mutableTeamColors.length);
                  currentTeamIndex = currentFlagIndex;
                  print('BURTA: $pionekZaBurta');
                });

              }
      );};
      isAnimating = false;
      return;
    } else {
      currentFieldName = newFieldsList[flagSteps[flagIndex]];
    }

      isAnimating = false;

      safeSetState(() {
        showCardAnimation = true;
        showAnimatedCard = true;
        final audioController = context.read<AudioController>();
        audioController.playSfx(SfxType.animationCardSound);
      });
    // navigateWithDelay(context);
  }

  void navigateWithDelay(BuildContext context, String currentTeamName, Color teamColor) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => PlayGameboardCard(
          teamNames: [getCurrentTeamName()],
          teamColors: [mutableTeamColors[currentTeamIndex]],
          currentField: [currentFieldName],
          allTeamNames: mutableTeamNames,
          allTeamColors: mutableTeamColors
        ),
      ),
    ).then((returnedData) {
      if (mounted && returnedData != null) {
        safeSetState(() {
          // Aktualizuj stan na podstawie zwróconych danych
          currentFlagIndex = findNextActiveFlagIndex(currentFlagIndex, pionekZaBurta, mutableTeamColors.length);
          currentTeamIndex = currentFlagIndex;
          print('currentFlagIndex po powrocie: $currentTeamIndex');
          // Teraz zresetuj wartość zwróconą do null
          returnedData = null;
        });
      }
    });
  }

  int findNextActiveFlagIndex(int currentFlagIndex, List<bool> pionekZaBurta, int totalTeams) {
    int nextFlagIndex = (currentFlagIndex + 1) % totalTeams;

    // Przeszukaj pionki, zaczynając od następnego po obecnym
    for (int i = 0; i < totalTeams; i++) {
      // Jeśli pionek nie jest jeszcze na mecie, zwróć jego indeks
      if (!pionekZaBurta[nextFlagIndex]) {
        return nextFlagIndex;
      }

      // Przejdź do następnego pionka
      nextFlagIndex = (nextFlagIndex + 1) % totalTeams;
    }

    // Jeśli wszystkie pionki są na mecie, zwróć obecny indeks lub inny odpowiedni indeks
    return currentFlagIndex;
  }

  String getCurrentTeamName() {
    return mutableTeamNames[currentTeamIndex].toString();
  }

  String getCurrentTeamColor() {
    return mutableTeamColors[currentTeamIndex].toString();
  }

  @override
  bool get wantKeepAlive => true;
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
  starPink,
  starGreen,
  starTaboo,
  starYellow
}
