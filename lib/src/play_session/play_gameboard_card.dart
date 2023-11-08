import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:game_template/src/play_session/roll_slot_machine.dart';

// Zakładam, że importy z twojego drugiego fragmentu są nadal potrzebne
import '../app_lifecycle/translated_text.dart';
import '../play_session/play_gameboard_main.dart';
import '../style/palette.dart';
import 'package:flutter/services.dart';

import 'additional_widgets.dart';

class PlayGameboardCard extends StatefulWidget {
  final List<String> teamNames;
  final List<Color> teamColors;
  final List<String> currentField;

  PlayGameboardCard({required this.teamNames, required this.teamColors, required this.currentField});

  @override
  _PlayGameboardCardState createState() => _PlayGameboardCardState();
}

class _PlayGameboardCardState extends State<PlayGameboardCard> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _slideAnimationController;
  late AnimationController _timeUpAnimationController;
  late AnimationController _rotationAnimationController;
  late AnimationController _opacityController;

  late Animation<double> _rotationAnimation;
  late Animation<double> _timeUpFadeAnimation;
  late Animation<double> _timeUpScaleAnimation;
  late Animation<double> _timeUpFadeOutAnimation;

  bool hasShownAlertDialog = false;
  late Timer _timer;
  double _opacity = 0;
  double _offsetX = 0;
  int remainingTime = 30;
  late int initialTime;
  int currentCardIndex = 0; // Początkowy indeks karty
  int totalCards = 8;       // Łączna liczba kart
  int skipCount = 2;        // Początkowa liczba pominięć
  late List<Color> starsColors;
  bool _isButtonXDisabled = false;
  bool _isButtonTickDisabled = false;
  bool _isButtonSkipDisabled = false;
  late String generatedCardTypeWithNumber;

  @override
  void initState() {
    super.initState();
    _setTimerDuration();
    initialTime = remainingTime;
    _slideAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _opacityController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _opacityController.addListener(() {
      setState(() {
        _opacity = _opacityController.value;
      });
    });
    _generateCardTypeAndNumber();

    _rotationAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _timeUpAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _timeUpFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _timeUpAnimationController,
        curve: Interval(0.0, 0.5, curve: Curves.easeInOut), // Pierwsza połowa czasu
      ),
    );

    _timeUpScaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _timeUpAnimationController,
        curve: Interval(0.0, 0.5, curve: Curves.easeInOut), // Pierwsza połowa czasu
      ),
    );

    _timeUpFadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _timeUpAnimationController,
        curve: Interval(0.5, 1.0, curve: Curves.easeInOut), // Ostatnia połowa czasu
      ),
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0, // Początkowy kąt obrotu ustawiony na 0
    ).animate(
      CurvedAnimation(
        parent: _rotationAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _showCard(); // By karta pojawiła się na początku
    _startTimer();
    determineTotalCards(); // Funkcja, która ustali liczbę kart
  }

  void _onButtonXPressed() {
    if (_isButtonXDisabled) {
      // Jeśli przycisk jest nieaktywny, nie rób nic
      return;
    }

    // Zablokuj przycisk
    setState(() {
      _isButtonXDisabled = true;
      _isButtonTickDisabled = true;
      _isButtonSkipDisabled = true;
    });

    // Opóźnij działanie przycisku
    Future.delayed(Duration(milliseconds: 200), () {
      _updateCardTypeAndNumber();
      _dismissCardToLeft();
      _nextStarRed();
    });

    // Odblokuj przycisk po 300 milisekundach
    Future.delayed(Duration(milliseconds: 800), () {
      setState(() {
        _isButtonXDisabled = false;
        _isButtonTickDisabled = false;
        _isButtonSkipDisabled = false;
      });
    });
  }

  void _onButtonTickPressed() {
    if (_isButtonXDisabled) {
      // Jeśli przycisk jest nieaktywny, nie rób nic
      return;
    }

    // Zablokuj przycisk
    setState(() {
      _isButtonXDisabled = true;
      _isButtonTickDisabled = true;
      _isButtonSkipDisabled = true;
    });

    // Opóźnij działanie przycisku
    Future.delayed(Duration(milliseconds: 200), () {
      _updateCardTypeAndNumber();
      _dismissCardToRight();
      _nextStarGreen();
    });

    // Odblokuj przycisk po 300 milisekundach
    Future.delayed(Duration(milliseconds: 800), () {
      setState(() {
        _isButtonXDisabled = false;
        _isButtonTickDisabled = false;
        _isButtonSkipDisabled = false;
      });
    });
  }

  void _onSkipButtonPressed() {
    if (_isButtonSkipDisabled) {
      // Jeśli przycisk jest nieaktywny, nie rób nic
      return;
    }

    // Zablokuj przycisk
    setState(() {
      _isButtonXDisabled = true;
      _isButtonTickDisabled = true;
      _isButtonSkipDisabled = true;
    });

    if (skipCount > 0) {
      // Wykonanie opóźnienia
      Future.delayed(Duration(milliseconds: 200), () {
        _updateCardTypeAndNumber();
        _dismissCardToLeft();
        _skipCard(); // Ta funkcja zmniejszy skipCount
      });
    } else {
      _showAnimatedDialogNoCards();
    }

    // Odblokuj przycisk po 300 milisekundach
    Future.delayed(Duration(milliseconds: 800), () {
      setState(() {
        _isButtonXDisabled = false;
        _isButtonTickDisabled = false;
        _isButtonSkipDisabled = false;
      });
    });
  }

  void determineTotalCards() {
    int cardNumbers;
    switch (widget.currentField[0]) {
      case 'field_sheet':
        cardNumbers = 5;
        break;
      case 'field_letters':
        cardNumbers = 1;
        break;
      case 'field_pantomime':
        cardNumbers = 2;
        break;
      case 'field_microphone':
        cardNumbers = 5;
        break;
      case 'field_taboo':
        cardNumbers = 5;
        break;
      case 'field_star_blue_dark':
        cardNumbers = 1;
        break;
      case 'field_star_pink':
        cardNumbers = 2;
        break;
      case 'field_star_green':
        cardNumbers = 1;
        break;
      case 'field_star_yellow':
        cardNumbers = 1;
        break;
      default:
        cardNumbers = 1; // Domyślna wartość cardType, jeśli currentField nie pasuje do żadnego przypadku
    }
    setState(() {
      totalCards = cardNumbers; // Ustal odpowiednią wartość dla totalCards
      starsColors = List.generate(totalCards, (index) => Colors.grey);
      // Ustawienie pierwszej gwiazdki na żółto, zakładając że zaczynamy od pierwszej karty
      if (totalCards > 0) {
      starsColors[0] = Colors.yellow;
      }
    });
  }

  void _dismissCardToLeft() {
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: -pi / 12, // -15 stopni w radianach
    ).animate(
      CurvedAnimation(
        parent: _rotationAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    setState(() {
      _offsetX = -MediaQuery.of(context).size.width;
    });
    Future.delayed(Duration(milliseconds: 50), () {
      _rotationAnimationController.forward();
    });
    // Czekamy aż karta opuści ekran
    Future.delayed(Duration(milliseconds: 300), () {
      // Teraz karta jest poza ekranem, możemy ją "ukryć"
      setState(() {
        _opacity = 0;
      });
      //_animationController.stop();
      _animationController.reset();

      //_slideAnimationController.stop();
      _slideAnimationController.reset();

      //_rotationAnimationController.stop();
      _rotationAnimationController.reset();
      // Dodajemy opóźnienie przed zresetowaniem stanu, aby upewnić się, że karta zniknęła
      _showCard();
    });
  }

  void _showCard() {
    // Ustawiamy opóźnienie, aby dać czas na zniknięcie karty
    Future.delayed(Duration(milliseconds:0), () {
      setState(() {
        _opacity = 1; // Karta staje się widoczna
        _offsetX = 0; // Reset pozycji
      });

      // Dodajemy dodatkowe opóźnienie przed rozpoczęciem animacji wyskoku
      Future.delayed(Duration(milliseconds: 250), () {
        _animationController.forward();
        _slideAnimationController.forward();
      });
    });
  }

  void _dismissCardToRight() {
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: pi / 12, // 15 stopni w radianach
    ).animate(
      CurvedAnimation(
        parent: _rotationAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    setState(() {
      _offsetX = MediaQuery.of(context).size.width;
    });
    Future.delayed(Duration(milliseconds: 50), () {
      _rotationAnimationController.forward();
    });

    // Czekamy aż karta opuści ekran
    Future.delayed(Duration(milliseconds: 250), () {
      // Teraz karta jest poza ekranem, możemy ją "ukryć"
      setState(() {
        _opacity = 0;
      });
      _animationController.reset();
      _slideAnimationController.reset();
      _rotationAnimationController.reset();
      // Opóźnienie nie jest tutaj potrzebne, ponieważ zresetowanie stanu jest wystarczające, aby upewnić się, że karta zniknęła
      _showCard();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          _showTimeUpAnimation();
          _timer.cancel();
        }
      });
    });
  }

  void _showTimeUpAnimation() {
    _timeUpAnimationController.forward().then((value) => {
      //Navigator.of(context).pop('response')
    });
  }

  void _setTimerDuration() { //TODO do ustalenia konkretne czasy dla danych kart
    String cardType = widget.currentField[0];
    switch (cardType) {
      case "field_sheet":
        remainingTime = 10;
        break;
      case "field_letters":
        remainingTime = 15;
        break;
      case "field_pantomime":
        remainingTime = 20;
        break;
      case "field_microphone":
        remainingTime = 20;
        break;
      case "field_taboo":
        remainingTime = 20;
        break;
      default:
        remainingTime = 5; // Domyślny czas, jeśli cardType nie pasuje do żadnego przypadku
        break;
    }
  }

  void _generateCardTypeAndNumber() {
    // Przydzielenie wyniku do zmiennej stanu
    generatedCardTypeWithNumber = generateCardTypeWithNumber(widget.currentField[0]);
  }

  void _updateCardTypeAndNumber() {
    setState(() {
      generatedCardTypeWithNumber = generateCardTypeWithNumber(widget.currentField[0]);
    });
  }

  String generateCardTypeWithNumber(String currentField) {
    Random random = Random();
    int maxNumber = 1;

    String cardType;
    switch (currentField) {
      case 'field_sheet':
        cardType = 'rymes';
        maxNumber = 119;
        break;
      case 'field_letters':
        cardType = 'alphabet';
        break;
      case 'field_pantomime':
        cardType = 'pantomimes';
        maxNumber = 135;
        break;
      case 'field_microphone':
        cardType = 'peoples';
        maxNumber = 138;
        break;
      case 'field_taboo':
        cardType = 'taboo';
        maxNumber = 220;
        break;
      case 'field_star_blue_dark':
        cardType = 'phisycal';
        break;
      case 'field_star_pink':
        cardType = 'antonimes';
        maxNumber = 113;
        break;
      case 'field_star_green':
        cardType = 'draw_movie';
        maxNumber = 100;
        break;
      case 'field_star_yellow':
        cardType = 'compare_question';
        maxNumber = 250;
        break;
      default:
        cardType = 'default'; // Domyślna wartość cardType, jeśli currentField nie pasuje do żadnego przypadku
    }
    int randomNumber = random.nextInt(maxNumber) + 1; // Losuje liczbę od 1 do maxNumber

    return '$cardType$randomNumber'; // Zwraca połączony ciąg znaków
  }

  void _nextStarRed(){
    if (currentCardIndex < totalCards - 1) {
      // Jest więcej kart do wyświetlenia
      setState(() {
        // Ustaw obecną gwiazdkę na zielono
        starsColors[currentCardIndex] = Colors.red;
        // Inkrementuj currentCardIndex, aby przejść do następnej karty
        // Ustaw nową obecną gwiazdkę na żółto
        starsColors[currentCardIndex+1] = Colors.yellow;
        currentCardIndex++;
      });
    } else if (currentCardIndex == totalCards - 1) {
      starsColors[currentCardIndex] = Colors.red;
      Navigator.of(context).pop('response');
      showPointsDialog(context, starsColors, totalCards);
    }
  }

  void _nextStarGreen() {
    if (currentCardIndex < totalCards - 1) {
      // Jest więcej kart do wyświetlenia
      setState(() {
        // Ustaw obecną gwiazdkę na zielono
        starsColors[currentCardIndex] = Colors.green;
        // Inkrementuj currentCardIndex, aby przejść do następnej karty
                // Ustaw nową obecną gwiazdkę na żółto
        starsColors[currentCardIndex+1] = Colors.yellow;
        currentCardIndex++;
      });
    } else if (currentCardIndex == totalCards - 1) {
      // Jeśli to była ostatnia karta
      starsColors[currentCardIndex] = Colors.green;
      Navigator.of(context).pop('response');
      showPointsDialog(context, starsColors, totalCards);
    }
  }

  void showPointsDialog(BuildContext context, List<Color> starsColors, int totalCards) {
    // Obliczenie punktów
    int greenCount = starsColors.where((color) => color == Colors.green).length;
    int redCount = starsColors.where((color) => color == Colors.red).length;
    int points;
    if (greenCount > totalCards / 2) {
      points = 2;
    } else if (greenCount == totalCards / 2) {
      points = 1;
    } else {
      points = 0;
    }
    // Wyświetlenie alert dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(backgroundColor: Colors.white,
          title: Text('Zdobywasz $points punktów!'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.red),
              Text('$redCount '),
              Icon(Icons.star, color: Colors.green),
              Text('$greenCount'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Zamknięcie dialogu
              },
            ),
          ],
        );
      },
    );
  }

  void _skipCard() {
    if (skipCount > 0) {
      setState(() {
        skipCount--;
        if (skipCount == 0) {
          // Logika deaktywacji przycisku, jeśli skipCount osiągnie 0
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: Palette().backgroundLoadingSessionGradient,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.pause, color: Colors.white, size: 30),
                    onPressed: () {
                      Navigator.of(context).pop('response');
                    },
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    // Odstępy wewnątrz prostokąta
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      // Przezroczysty czarny kolor
                      borderRadius: BorderRadius.circular(8.0), // Zaokrąglenie rogów
                    ),
                    child: Row(
                      children: [
                        ..._displayTeamNames(),
                        SizedBox(width: 20.0),
                        ..._displayTeamColors(),
                      ],
                    ),
                  ),
                  Spacer(),
                  Container(
                        child: CircleAvatar(
                          radius: 18,
                          // Dostosuj rozmiar w zależności od potrzeb
                          backgroundColor: Color(0xFF2899F3),
                          child: Text('?',
                              style: TextStyle(
                                  color: Palette().white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  fontFamily: 'HindMadurai')),
                        ),
                      ),
                ],
              ),
            ),
            SizedBox(height: 10.0),
            ..._displayCurrentField(),
            SizedBox(height: 15.0),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 60, // Dostosuj wysokość tak, aby pasowała do Twojego projektu
                  child: remainingTime > 0
                      ? CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.transparent,
                          child: SizedBox.expand(
                            child: CustomPaint(
                              painter: CircleProgressPainter(
                                  segments: initialTime, progress: 1 / initialTime * remainingTime),
                            ),
                          ),
                        )
                      : Center(
                          child: FadeTransition(
                            opacity: _timeUpFadeAnimation,
                            child: ScaleTransition(
                              scale: _timeUpScaleAnimation,
                              child: FadeTransition(
                                opacity: _timeUpFadeOutAnimation,
                                child: Text(
                                  "Koniec czasu!",
                                  style: TextStyle(fontSize: 20, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
                Positioned(
                  top: 15, // Pozycjonowanie tekstu w centrum SizedBox
                  child: remainingTime > 0
                      ? Text(
                          '$remainingTime',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        )
                      : Container(),
                ),
              ],
            ),

            SizedBox(height: 15.0),
            Stack(
              alignment: Alignment.center,
              children: [
                Center( //KARTA
                  child: CustomCard(
                    totalCards: totalCards,
                    starsColors: starsColors,
                    word: generatedCardTypeWithNumber,
                    skipCount: skipCount,
                    onSkipButtonPressed: _onSkipButtonPressed,
                    onButtonXPressed: _onButtonXPressed,
                    onButtonTickPressed: _onButtonTickPressed,
                    currentCardIndex: currentCardIndex,
                    slideAnimationController: _slideAnimationController,
                    rotationAnimation: _rotationAnimation,
                    opacity: _opacity,
                    offsetX: _offsetX,
                    cardType: widget.currentField[0]
                  )
                ),
              ],
            ),
            //SizedBox(height: 10),
            Text('Karta ${currentCardIndex + 1} z $totalCards',
                style: TextStyle(color: Palette().white, fontWeight: FontWeight.normal, fontFamily: 'HindMadurai')),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Spacer(),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgButton(
                      assetName: skipCount > 0
                          ? 'assets/time_to_party_assets/cards_screens/button_drop.svg'
                          : 'assets/time_to_party_assets/cards_screens/button_drop_disabled.svg', // zmień na ścieżkę do szarego przycisku
                      onPressed: _onSkipButtonPressed,
                    ),
                    Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: skipCount > 0 ? Palette().yellowIndBorder : Colors.grey.shade300, // Kolor obramowania
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: skipCount > 0 ? Palette().yellowInd : Colors.grey.shade600, // Tło licznika
                            child: Text(
                              '$skipCount',
                              style: TextStyle(
                                  color: skipCount > 0 ? Palette().darkGrey : Colors.grey.shade300, // Kolor tekstu
                                  fontWeight: FontWeight.normal,
                                  fontFamily: 'HindMadurai'
                              ),
                            ),
                          ),
                        )
                    ),
                  ],
                ),
                //SizedBox(width: 10),
                SvgButton(
                  assetName: 'assets/time_to_party_assets/cards_screens/button_declined.svg',
                  onPressed: _onButtonXPressed,
                ),
                SvgButton(
                  assetName: 'assets/time_to_party_assets/cards_screens/button_approved.svg',
                  onPressed:  _onButtonTickPressed,
                ),
                Spacer(),
              ],
            )
          ],
        ),
      ),
    );
  }

  void showRollSlotMachine(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Scaffold(body: RollSlotMachine())),
    );
  }

  void _showAnimatedDialogNoCards() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
        return Center(
            child: AlertDialog(
                backgroundColor: Palette().white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title:
                letsText(context, 'Nie możesz już pominąć karty!', 20, Palette().pink, textAlign: TextAlign.center)));
      },
      transitionBuilder:
          (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
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
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _opacityController.dispose();
    _timeUpAnimationController.dispose();
    _animationController.dispose();
    _slideAnimationController.dispose();
    _rotationAnimationController.dispose();
    super.dispose();
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
      String flagColorHex = 'FF' + flag.split('/').last.split('.').first.substring(5); //zmiana z 4 na 5
      Color flagColor = Color(int.parse(flagColorHex, radix: 16));
      if (color.value == flagColor.value) {
        return flag;
      }
    }
    return 'assets/time_to_party_assets/main_board/flags/kolko00A2AC.svg';
  }

  List<Widget> _displayTeamColors() {
    List<Widget> displayWidgets = [];

    for (Color color in widget.teamColors) {
      String flagAsset = getFlagAssetFromColor(color);
      displayWidgets.add(SvgPicture.asset(flagAsset));
      displayWidgets.add(SizedBox(height: 20.0));
    }

    return displayWidgets;
  }

  List<Widget> _displayTeamNames() {
    List<Widget> displayWidgets = [];

    for (String name in widget.teamNames) {
      displayWidgets.add(Text(
        name,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
      displayWidgets.add(SizedBox(height: 20.0));
    }

    return displayWidgets;
  }

  final Map<String, String> fieldTypeTranslations = {
    'field_arrows': 'Wybór',
    'field_sheet': 'Rymowanie',
    'field_letters': 'Alfabet',
    'field_pantomime': 'Pantomimy',
    'field_microphone': 'Sławne osoby',
    'field_taboo': 'Taboo',
    'field_star_blue_dark': 'Trochę ruchu',
    'field_star_pink': 'Antonimy',
    'field_star_green': 'Rysowanie',
    'field_star_yellow': 'Pytania',
  };

  final Map<String, String> fieldTypeImagePaths = {
    'field_arrows': 'assets/time_to_party_assets/cards_screens/change_card_arrows_icon_color.svg',
    'field_sheet': 'assets/time_to_party_assets/cards_screens/rymes_icon_color.svg',
    'field_letters': 'assets/time_to_party_assets/cards_screens/letters_icon_color.svg',
    'field_pantomime': 'assets/time_to_party_assets/cards_screens/pantomime_icon_color.svg',
    'field_microphone': 'assets/time_to_party_assets/cards_screens/microphone_icon_color.svg',
    'field_taboo': 'assets/time_to_party_assets/cards_screens/taboo_icon_color.svg',
    'field_star_blue_dark': 'assets/time_to_party_assets/cards_screens/star_blue_icon_color.svg',
    'field_star_pink': 'assets/time_to_party_assets/cards_screens/star_pink_icon_color.svg',
    'field_star_green': 'assets/time_to_party_assets/cards_screens/star_green_icon_color.svg',
    'field_star_yellow': 'assets/time_to_party_assets/cards_screens/star_yellow_icon_color.svg'
  };

  List<Widget> _displayCurrentField() {
    List<Widget> displayWidgets = [];

    for (String fieldType in widget.currentField) {
      String currentTitle = fieldTypeTranslations[fieldType] ?? fieldType;
      String? currentImagePath = fieldTypeImagePaths[fieldType];

      List<Widget> rowItems = [];

      rowItems.add(
        Text(
          currentTitle,
          style: TextStyle(
            fontFamily: 'HindMadurai',
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(1.0, 4.0),
                blurRadius: 15.0,
                color: Color.fromARGB(255, 0, 0, 0), // Kolor cienia, w tym przypadku czarny
              ),
            ],
          ),
        ),
      );
      if (currentImagePath != null) {
        rowItems.add(
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: SvgPicture.asset(
              currentImagePath,
              height: 30.0, // Możesz dostosować wysokość według potrzeb
              fit: BoxFit.contain,
            ),
          ),
        );
      }
      displayWidgets.add(
        Row(
          mainAxisSize: MainAxisSize.min, // Dopasowuje wielkość wiersza do zawartości
          children: rowItems,
        ),
      );
    }
    return displayWidgets;
  }
}

// klasa svg przycisk
class SvgButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String assetName; // Ścieżka do pliku SVG

  SvgButton({
    required this.onPressed,
    required this.assetName,
  });

  @override
  _SvgButtonState createState() => _SvgButtonState();
}

class _SvgButtonState extends State<SvgButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _animation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.forward();
        widget.onPressed();
      },
      child: ScaleTransition(
        scale: _animation,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
          ),
          child: SvgPicture.asset(widget.assetName,
              height: ResponsiveSizing.scaleHeight(context, 75), width: double.maxFinite),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// ... poza klasą widgetu: rysowanie kolka progresu
class CircleProgressPainter extends CustomPainter {
  final int segments;
  final double progress;

  CircleProgressPainter({required this.segments, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paintBackground = Paint()
      ..color = Color(0xFFE0E0E0)
      ..strokeWidth = 9
      ..style = PaintingStyle.stroke;

    final Paint paintProgress = Paint()
      ..color = Color(0xFF4FD5AA)
      ..strokeWidth = 9
      ..style = PaintingStyle.stroke;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2;

    double segmentAngle = 2 * pi / segments;
    double gapAngle = segmentAngle * 0.1; // 10% gap, you can adjust
    double fillAngle = segmentAngle - gapAngle;

    // Rysowanie tła
    for (int i = 0; i < segments; i++) {
      double start = i * segmentAngle - pi / 2;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, fillAngle, false, paintBackground);
    }

    // Rysowanie postępu
    double filledSegments = segments * progress;
    for (int i = 0; i < filledSegments; i++) {
      double start = i * segmentAngle - pi / 2;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, fillAngle, false, paintProgress);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CustomCard extends StatelessWidget {
  final int totalCards;
  final List<Color> starsColors;
  final String word;
  final int skipCount;
  final Function() onSkipButtonPressed;
  final Function() onButtonXPressed;
  final Function() onButtonTickPressed;
  final int currentCardIndex;
  final AnimationController slideAnimationController;
  final Animation<double> rotationAnimation;
  final double opacity;
  final double offsetX;
  final String cardType; // Dodatkowy parametr określający typ karty

  const CustomCard({
    Key? key,
    required this.totalCards,
    required this.starsColors,
    required this.word,
    required this.skipCount,
    required this.onSkipButtonPressed,
    required this.onButtonXPressed,
    required this.onButtonTickPressed,
    required this.currentCardIndex,
    required this.slideAnimationController,
    required this.rotationAnimation,
    required this.opacity,
    required this.offsetX,
    required this.cardType, // Przekazanie typu karty jako parametru
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    switch (cardType) {
      case 'field_sheet':
        return buildSheetCard(totalCards, starsColors, slideAnimationController, rotationAnimation, opacity, offsetX, word); // Możesz tutaj zdefiniować wygląd karty dla 'field_sheet'
    // ... inne przypadki dla różnych typów kart
      default:
        return buildSheetCard(totalCards, starsColors, slideAnimationController, rotationAnimation, opacity, offsetX, word); // Możesz tutaj zdefiniować wygląd karty dla 'field_sheet'
    }
  }
  Widget buildSheetCard(int totalCards, List<Color> starsColors, AnimationController slideAnimationController, Animation<double> rotationAnimation, double opacity, double offsetX, String word) {
     return TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: offsetX),
        duration: Duration(milliseconds: 250),
        builder: (BuildContext context, double value, Widget? child) {
          return Transform.translate(
            offset: Offset(value, 0),
            child: Transform.rotate(
              angle: rotationAnimation.value, // Używanie wartości animacji obrotu tutaj
              child: FractionallySizedBox(
                widthFactor: 0.7, //szerokosc karty
                child: AnimatedOpacity(
                  opacity: opacity,
                  duration: Duration(milliseconds: 250),
                  child: ScaleTransition(
                    scale: slideAnimationController, // Kontroler animacji skali
                    child: Container(
                      height: 400.0,
                      padding: EdgeInsets.all(13.0),
                      child: Card(
                        color: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          side: BorderSide(color: Palette().white, width: 13.0),
                        ),
                        elevation: 0.0,
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(totalCards, (index) {
                                // Bezpośrednio używaj starsColors[index] dla każdej gwiazdki
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  child: Icon(
                                    Icons.star,
                                    color: starsColors[index], // Bezpośrednio ustaw kolor z listy starsColors
                                    size: 20,
                                  ),
                                );
                              }),
                            ),
                            SizedBox(height: 15),
                            Container(
                              padding: const EdgeInsets.all(20.0),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xffB46BDF), Color(0xff6625FF), Color(0xff211753)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [wordText(context, word, 24, Colors.white, index: 0)],
                              ),
                            ),
                            wordText(context, word, 24, Colors.white, index: 1),
                            wordText(context, word, 24, Colors.white, index: 2),
                            wordText(context, word, 24, Colors.white, index: 3),
                            wordText(context, word, 24, Colors.white, index: 4),
                            wordText(context, word, 24, Colors.white, index: 5),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(totalCards, (index) {
                                // Bezpośrednio używaj starsColors[index] dla każdej gwiazdki
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  child: Icon(
                                    Icons.star,
                                    color: starsColors[index], // Bezpośrednio ustaw kolor z listy starsColors
                                    size: 20,
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

  Widget buildDefaultCard() {
    return Card(
      // ... szczegóły konstrukcji karty
    );
  }

}

class CardAnimation extends StatelessWidget {
  final Widget child;
  final AnimationController slideAnimationController;
  final Animation<double> rotationAnimation;
  final double opacity;
  final double offsetX;

  const CardAnimation({
    Key? key,
    required this.child,
    required this.slideAnimationController,
    required this.rotationAnimation,
    required this.opacity,
    required this.offsetX,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: offsetX),
      duration: Duration(milliseconds: 250),
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.translate(
          offset: Offset(value, 0),
          child: Transform.rotate(
            angle: rotationAnimation.value,
            child: FractionallySizedBox(
              widthFactor: 0.7,
              child: AnimatedOpacity(
                opacity: opacity,
                duration: Duration(milliseconds: 250),
                child: ScaleTransition(
                  scale: slideAnimationController,
                  child: child, // Tutaj podstawiamy naszą kartę
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
