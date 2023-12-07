import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:game_template/src/play_session/card_screens/roll_slot_machine.dart';
import 'package:game_template/src/play_session/card_screens/svgbutton_enabled_dis.dart';
import 'package:game_template/src/play_session/extensions.dart';
import 'package:provider/provider.dart';

import '../../app_lifecycle/translated_text.dart';
import '../../audio/audio_controller.dart';
import '../../audio/sounds.dart';
import '../../style/palette.dart';
import '../alerts_and_dialogs.dart';
import '../custom_style_buttons.dart';
import 'circle_progress_painter.dart';
import 'custom_card.dart';

class PlayGameboardCard extends StatefulWidget {
  final List<String> teamNames;
  final List<Color> teamColors;
  final List<String> currentField;

  const PlayGameboardCard({super.key, required this.teamNames, required this.teamColors, required this.currentField});

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
  int totalCards = 8; // Łączna liczba kart
  late int skipCount; // Początkowa liczba pominięć
  late List<Color> starsColors;
  bool _isButtonXDisabled = false;
  bool _isButtonTickDisabled = false;
  bool _isButtonSkipDisabled = false;
  late String generatedCardTypeWithNumber = '';
  List<String> wordsList = [];
  int currentWordIndex = 0;
  bool isTabooCard = false;
  late String currentWordOrKey;
  late List<String> _fortuneItemsList;
  bool isAlertOpened = false;

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
      safeSetState(() {
        _opacity = _opacityController.value;
      });
    });
    _generateCardTypeAndNumber();
    _fortuneItemsList = buildFortuneItemsList(context);

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
    if (shouldStartTimerInitially()) {
      _startTimer();
    }
    determineTotalCards();
    _initializeCards();
  }

  bool shouldStartTimerInitially() {
    // Zwraca true, jeśli nie jest to ani 'field_star_blue_dark', ani 'field_star_green'
    return widget.currentField[0] != 'field_star_blue_dark' && widget.currentField[0] != 'field_star_green';
  }

  void _prepareCurrentWordOrKey() {
    if (isTabooCard) {
      currentWordOrKey = generateCardTypeWithNumber(widget.currentField[0]); // Dla kart 'taboo'
    } else {
      // Użyj istniejącej logiki do wybrania odpowiedniego słowa z listy
      currentWordOrKey = wordsList.isNotEmpty ? wordsList[currentWordIndex] : "";
    }
  }

  void _onButtonXPressed() {
    if (_isButtonXDisabled) {
      // Jeśli przycisk jest nieaktywny, nie rób nic
      return;
    }
    final audioController = context.read<AudioController>();
    audioController.playSfx(SfxType.card_x_sound);
    // Zablokuj przycisk
    safeSetState(() {
      _isButtonXDisabled = true;
      _isButtonTickDisabled = true;
      _isButtonSkipDisabled = true;
    });
    // Opóźnij działanie przycisku
    Future.delayed(Duration(milliseconds: 200), () {
      _dismissCardToLeft();
      _nextStarRed();
    });
    Future.delayed(Duration(milliseconds: 500), () {
      if (isTabooCard) {
        _updateCardTypeAndNumber(); // Regeneruj dla kart taboo
      } else {
        _nextWord(); // Przesuń do następnego słowa dla pozostałych kart
      }
      _prepareCurrentWordOrKey();
    });

    // Odblokuj przycisk po 300 milisekundach
    Future.delayed(Duration(milliseconds: 800), () {
      safeSetState(() {
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
    final audioController = context.read<AudioController>();
    audioController.playSfx(SfxType.card_tick_sound);
    // Zablokuj przycisk
    safeSetState(() {
      _isButtonXDisabled = true;
      _isButtonTickDisabled = true;
      _isButtonSkipDisabled = true;
    });

    // Opóźnij działanie przycisku
    Future.delayed(Duration(milliseconds: 200), () {
      _dismissCardToRight();
      _nextStarGreen();
    });
    Future.delayed(Duration(milliseconds: 500), () {
      if (isTabooCard) {
        _updateCardTypeAndNumber(); // Regeneruj dla kart taboo
      } else {
        _nextWord(); // Przesuń do następnego słowa dla pozostałych kart
      }
      _prepareCurrentWordOrKey();
    });
    // Odblokuj przycisk po 300 milisekundach
    Future.delayed(Duration(milliseconds: 800), () {
      safeSetState(() {
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
    final audioController = context.read<AudioController>();
    audioController.playSfx(SfxType.card_skip_sound);
    // Zablokuj przycisk
    safeSetState(() {
      _isButtonXDisabled = true;
      _isButtonTickDisabled = true;
      _isButtonSkipDisabled = true;
    });

    if (skipCount > 0) {
      // Wykonanie opóźnienia
      Future.delayed(Duration(milliseconds: 200), () {
        _dismissCardToLeft();
        _skipCard(); // Ta funkcja zmniejszy skipCount
      });

      Future.delayed(Duration(milliseconds: 500), () {
        if (isTabooCard) {
          _updateCardTypeAndNumber(); // Regeneruj dla kart taboo
        } else {
          _initializeCards(); // Przesuń do następnego słowa dla pozostałych kart
        }
        _prepareCurrentWordOrKey();
      });
    } else {
      AnimatedAlertDialog.showAnimatedDialogNoCards(context);
    }

    // Odblokuj przycisk po 300 milisekundach
    Future.delayed(Duration(milliseconds: 800), () {
      safeSetState(() {
        _isButtonXDisabled = false;
        _isButtonTickDisabled = false;
        _isButtonSkipDisabled = false;
      });
    });
  }

// ustal liczbe kart i pominiec dla danego rodzaju pola
  void determineTotalCards() {
    int cardNumbers;
    switch (widget.currentField[0]) {
      case 'field_sheet':
        cardNumbers = 5;
        skipCount = 2;
        break;
      case 'field_letters':
        cardNumbers = 1;
        skipCount = 1;
        break;
      case 'field_pantomime':
        cardNumbers = 2;
        skipCount = 1;
        break;
      case 'field_microphone':
        cardNumbers = 5;
        skipCount = 2;
        break;
      case 'field_taboo':
        cardNumbers = 5;
        skipCount = 2;
        break;
      case 'field_star_blue_dark':
        cardNumbers = 1;
        skipCount = 1;
        break;
      case 'field_star_pink':
        cardNumbers = 5;
        skipCount = 1;
        break;
      case 'field_star_green':
        cardNumbers = 1;
        skipCount = 1;
        break;
      case 'field_star_yellow':
        cardNumbers = 1;
        skipCount = 1;
        break;
      default:
        cardNumbers = 1; // Domyślna wartość cardType, jeśli currentField nie pasuje do żadnego przypadku
    }
    safeSetState(() {
      totalCards = cardNumbers; // Ustal odpowiednią wartość dla totalCards
      starsColors = List.generate(totalCards, (index) => Colors.grey);
      // Ustawienie pierwszej gwiazdki na żółto, zakładając że zaczynamy od pierwszej karty
      if (totalCards > 0) {
        starsColors[0] = Colors.yellow;
      }
    });
  }

// przesun karte w lewo i wyswietla następna karte (animacja)
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

    safeSetState(() {
      _offsetX = -MediaQuery.of(context).size.width;
    });
    Future.delayed(Duration(milliseconds: 50), () {
      _rotationAnimationController.forward();
    });
    // Czekamy aż karta opuści ekran
    Future.delayed(Duration(milliseconds: 300), () {
      // Teraz karta jest poza ekranem, możemy ją "ukryć"
      safeSetState(() {
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

// pokaz karte na środku
  void _showCard() {
    // Ustawiamy opóźnienie, aby dać czas na zniknięcie karty
    Future.delayed(Duration(milliseconds: 0), () {
      safeSetState(() {
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

// przesun karte w prawo i wyswietla następna karte (animacja)
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

    safeSetState(() {
      _offsetX = MediaQuery.of(context).size.width;
    });
    Future.delayed(Duration(milliseconds: 50), () {
      _rotationAnimationController.forward();
    });

    // Czekamy aż karta opuści ekran
    Future.delayed(Duration(milliseconds: 250), () {
      // Teraz karta jest poza ekranem, możemy ją "ukryć"
      safeSetState(() {
        _opacity = 0;
      });
      _animationController.reset();
      _slideAnimationController.reset();
      _rotationAnimationController.reset();
      // Opóźnienie nie jest tutaj potrzebne, ponieważ zresetowanie stanu jest wystarczające, aby upewnić się, że karta zniknęła
      _showCard();
    });
  }

// timer
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) return;
      safeSetState(() {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          _showTimeUpAnimation();
          _timer.cancel();
        }
      });
    });
  }
  void handleRollSlotMachineResult(String result) {
    safeSetState(() {
      var textFromRollSlotMachine = result;
      print('mam cie kolego xd $result');

      // Użyj wyrażenia regularnego do znalezienia wszystkich liczb w tekście
      RegExp regExp = RegExp(r'\d+');
      Iterable<RegExpMatch> matches = regExp.allMatches(result);

      if (matches.isNotEmpty) {
        // Pobierz pierwsze dopasowanie (liczbę) i przekształć je na int
        String numberString = matches.first.group(0) ?? '';
        int number = int.tryParse(numberString) ?? 0;

        print('Znaleziona liczba: $number');

        initialTime = remainingTime = number*2;
        _startTimer();
      }
    });
  }

// animacja time up
  void _showTimeUpAnimation() {
    _timeUpAnimationController.forward().then((value) => {

      if (widget.currentField[0]=='field_star_blue_dark'){
       AnimatedAlertDialog.showAnimatedDialogFinishedTask(context, _onButtonXPressed, _onButtonTickPressed)} else {
        if (isAlertOpened){
          Navigator.of(context).pop(),
          Navigator.of(context).pop('response'),
        } else
        Navigator.of(context).pop('response'),
      }
    });
  }

// ustalenie konkretnego czasu dla danej karty
  void _setTimerDuration() {
    //TO_DO do ustalenia konkretne czasy dla danych kart
    String cardType = widget.currentField[0];
    switch (cardType) {
      case "field_sheet":
        remainingTime = 50;
        break;
      case "field_letters":
        remainingTime = 50;
        break;
      case "field_pantomime":
        remainingTime = 40;
        break;
      case "field_microphone":
        remainingTime = 50;
        break;
      case "field_taboo":
        remainingTime = 40;
        break;
      default:
        remainingTime = 50; // Domyślny czas, jeśli cardType nie pasuje do żadnego przypadku
        break;
    }
  }

//icijalizuj karty: jesli taboo -> generuj co kliknięcie kartę i numer
  // jeśli inna od taboo -> generuj karty na podstawie slow z pobranej listy
  Future<void> _initializeCards() async {
    if (widget.currentField[0] == 'field_taboo') {
      isTabooCard = true;
      _generateCardTypeAndNumber(); // Dla kart taboo
    } else {
      isTabooCard = false;
      wordsList = getWordsList(context, generateCardTypeWithNumber(widget.currentField[0]));
    }
  }

// nastepne slowo
  void _nextWord() {
    if (wordsList.isNotEmpty) {
      safeSetState(() {
        currentWordIndex = (currentWordIndex + 1) % wordsList.length;
      });
    }
  }

// wygeneruj nowy string bazy danych do pobrania karty taboo
  void _generateCardTypeAndNumber() {
    // ustalanie tutaj żeby w set state to wywolywac i zeby byla pierwsza karta - tu pobieramy pole
    generatedCardTypeWithNumber = generateCardTypeWithNumber(widget.currentField[0]);
  }

//updatujemy zmienna w set state
  void _updateCardTypeAndNumber() {
    safeSetState(() {
      generatedCardTypeWithNumber = generateCardTypeWithNumber(widget.currentField[0]);
    });
  }

// generowanie stringa: typ+number dla bazy danych
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
        cardType = 'physical';
        break;
      case 'field_star_pink':
        cardType = 'antonimes';
        maxNumber = 113;
        break;
      case 'field_star_green':
        cardType = 'draw_movie'; //problem jest taki ze idzie lista, która definiowana jest z jednego pola np.: field_star_green
        // i wtedy generuje się np: field_star_green79 - i on na tej podstawie pobiera metodą: buildFortuneItemsList -> i tu dostaniemy listę słów,
        // wziętych po separatorach ';' i zamienioną na listę Stringów i następnie ta lista jest przekazywana..
        // w przypadku tej karty, musiałbym to robić w zupełnie inny sposób albo wysyłać 3 listy
        //możnaby zrobić tak: jeżeli cardType (ustawiony tu przeze mnie) np. jako ==draw.
        // to spróbować zrobić przekazanie 3 list:
        //getWordsList(context, generateCardTypeWithNumber('draw_movie')); - trzebaby zrobić to na sztywno, albo specjalną metode dla tej jednej karty?
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

// ustaw nastepna gwiazdke czerwona
  void _nextStarRed() {
    if (currentCardIndex < totalCards - 1) {
      // Jest więcej kart do wyświetlenia
      safeSetState(() {
        // Ustaw obecną gwiazdkę na zielono
        starsColors[currentCardIndex] = Colors.red;
        // Inkrementuj currentCardIndex, aby przejść do następnej karty
        // Ustaw nową obecną gwiazdkę na żółto
        starsColors[currentCardIndex + 1] = Colors.yellow;
        currentCardIndex++;
      });
    } else if (currentCardIndex == totalCards - 1) {
      starsColors[currentCardIndex] = Colors.red;
      Navigator.of(context).pop('response');
      AnimatedAlertDialog.showPointsDialog(context, starsColors, totalCards);
    }
  }

// ustaw nastepan gwiazdke zielona
  void _nextStarGreen() {
    if (currentCardIndex < totalCards - 1) {
      // Jest więcej kart do wyświetlenia
      safeSetState(() {
        // Ustaw obecną gwiazdkę na zielono
        starsColors[currentCardIndex] = Colors.green;
        // Inkrementuj currentCardIndex, aby przejść do następnej karty
        // Ustaw nową obecną gwiazdkę na żółto
        starsColors[currentCardIndex + 1] = Colors.yellow;
        currentCardIndex++;
      });
    } else if (currentCardIndex == totalCards - 1) {
      // Jeśli to była ostatnia karta
      starsColors[currentCardIndex] = Colors.green;
      Navigator.of(context).pop('response');
      AnimatedAlertDialog.showPointsDialog(context, starsColors, totalCards);
    }
  }

// pomin karte (dekrementacja ilosci skipow)
  void _skipCard() {
    if (skipCount > 0) {
      safeSetState(() {
        skipCount--;
        if (skipCount == 0) {
          // Logika deaktywacji przycisku, jeśli skipCount osiągnie 0
        }
      });
    }
  }

  List<String> buildFortuneItemsList(BuildContext context) {
    // Zwróć bezpośrednio listę słów, bez konwersji na obiekty FortuneItem
    return getWordsList(context, generateCardTypeWithNumber(widget.currentField[0]));
  }

  Map<String, List<String>> buildSpecificListsForStarGreen(BuildContext context, String cardType) {
    if (cardType == 'field_star_green') {
      Map<String, List<String>> lists = {
        'movies': [],
        'proverbs': [],
        'lovePossibilities': []
      };

      int maxMovies = 100;
      int maxProverbs = 88;
      int maxLovePossibilities = 44;

      for (int i = 1; i <= maxMovies; i++) {
        var words = getWordsList(context, 'draw_movie$i');
        if (words.isNotEmpty) {
          lists['movies']!.addAll(words);
        }
      }
      for (int i = 1; i <= maxProverbs; i++) {
        var words = getWordsList(context, 'draw_proverb$i');
        if (words.isNotEmpty) {
          lists['proverbs']!.addAll(words);
        }
      }
      for (int i = 1; i <= maxLovePossibilities; i++) {
        var words = getWordsList(context, 'draw_love_pos$i');
        if (words.isNotEmpty) {
          lists['lovePossibilities']!.addAll(words);
        }
      }

      return lists;
    } else {
      return {};
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
                    icon: Icon(Icons.home_rounded, color: Colors.white, size: 30),
                    onPressed: () {
                      AnimatedAlertDialog.showExitGameDialog(context, hasShownAlertDialog, '');
                      //Navigator.of(context).pop('response');
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
      InkWell(
        onTap: () {
          setState(() {
            isAlertOpened = true;
          });
          AnimatedAlertDialog.showCardDescriptionDialog(context, widget.currentField[0], AlertOrigin.cardScreen).then((_) {
            setState(() {
              isAlertOpened = false;
            });
          });
        },
      child: Container(
                      child: CircleAvatar(
                        radius: 18, // Dostosuj rozmiar w zależności od potrzeb
                        backgroundColor: Color(0xFF2899F3),
                        child: Text(
                          '?',
                          style: TextStyle(
                              color: Palette().white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              fontFamily: 'HindMadurai'),
                        ),
                      ),
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
                Center(
                    //KARTA
                    child: CustomCard(
                  totalCards: totalCards,
                  starsColors: starsColors,
                  word: isTabooCard
                      ? generatedCardTypeWithNumber
                      : (wordsList.isNotEmpty ? wordsList[currentWordIndex] : "defaultWord"),
                  slideAnimationController: _slideAnimationController,
                  rotationAnimation: _rotationAnimation,
                  opacity: _opacity,
                  offsetX: _offsetX,
                  cardType: widget.currentField[0],
                  onRollSlotMachineResult: handleRollSlotMachineResult,
                  buildFortuneItemsList:
                      _fortuneItemsList, //to glupio nazwalem ale to jest lista w przypadku card letters wszystkich indeksow rozdzielonych po srednikach
                      // tak samo to będzie dla compare_questions uzywane, skojarzenie z fortune items list po prostu
                      specificLists: buildSpecificListsForStarGreen(context, widget.currentField[0]),
                )),
              ],
            ),
            //SizedBox(height: 10),
            Text('Karta ${currentCardIndex + 1} z $totalCards',
                style: TextStyle(color: Palette().white, fontWeight: FontWeight.normal, fontFamily: 'HindMadurai')),
            SizedBox(height: 10),
            (widget.currentField[0] != "field_star_yellow")
            ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Spacer(),
                (widget.currentField[0] != 'field_letters' && widget.currentField[0] != 'field_star_blue_dark')
                    ? Stack(
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
                                  color: skipCount > 0
                                      ? Palette().yellowIndBorder
                                      : Colors.grey.shade300, // Kolor obramowania
                                  shape: BoxShape.circle,
                                ),
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor:
                                      skipCount > 0 ? Palette().yellowInd : Colors.grey.shade600, // Tło licznika
                                  child: Text(
                                    '$skipCount',
                                    style: TextStyle(
                                        color:
                                            skipCount > 0 ? Palette().darkGrey : Colors.grey.shade300, // Kolor tekstu
                                        fontWeight: FontWeight.normal,
                                        fontFamily: 'HindMadurai'),
                                  ),
                                ),
                              )),
                        ],
                      )
                    : Container(),
                //SizedBox(width: 10),
                SvgButton(
                  assetName: 'assets/time_to_party_assets/cards_screens/button_declined.svg',
                  onPressed: _onButtonXPressed,
                ),
                SvgButton(
                  assetName: 'assets/time_to_party_assets/cards_screens/button_approved.svg',
                  onPressed: _onButtonTickPressed,
                ),
                Spacer(),
              ],
            ) : CustomStyledButton(icon: Icons.arrow_forward_outlined, onPressed: () {

            }, text: "Kontynuuj"), //przejscie do nastepnej karty, button ekran czy cos


          ],
        ),
      ),
    );
  }

// dziwne rzeczy do testu
  void showRollSlotMachine(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Scaffold(body: RollSlotMachine())),
    );
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
      String flagColorHex = 'FF${flag.split('/').last.split('.').first.substring(5)}'; //zmiana z 4 na 5
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
            shadows: const [
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