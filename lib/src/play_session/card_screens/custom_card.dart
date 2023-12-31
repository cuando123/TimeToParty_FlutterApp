import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_svg/svg.dart';
import 'package:game_template/src/play_session/card_screens/roll_slot_machine.dart';
import 'package:game_template/src/play_session/card_screens/styles/custom_style_strategy_bar.dart';
import 'package:game_template/src/play_session/card_screens/styles/image_painter.dart';
import 'package:game_template/src/play_session/extensions.dart';

import '../../app_lifecycle/translated_text.dart';
import '../../style/palette.dart';
import '../alerts_and_dialogs.dart';
import '../custom_style_buttons.dart';
import 'drawing_screen.dart';

class CustomCard extends StatefulWidget {
  final int totalCards;
  final List<Color> starsColors;
  final AnimationController slideAnimationController;
  final Animation<double> rotationAnimation;
  final double opacity;
  final double offsetX;
  final String word;
  final String cardType;
  final List<String> buildFortuneItemsList;
  final Map<String, List<String>> specificLists;
  final List<String> teamNames;
  final List<Color> teamColors;
  final void Function(String result) onRollSlotMachineResult;
  final Function onImageSet;
  final Function(int?, String?) onSelectionMade;
  final int? resetSelection;
  final ImageType imageType;

  const CustomCard({
    super.key,
    required this.totalCards,
    required this.starsColors,
    required this.slideAnimationController,
    required this.rotationAnimation,
    required this.opacity,
    required this.offsetX,
    required this.word,
    required this.cardType,
    required this.buildFortuneItemsList,
    required this.onRollSlotMachineResult,
    required this.teamColors,
    required this.teamNames,
    required this.onImageSet,
    required this.onSelectionMade,
    required this.resetSelection,
    required this.imageType,
    this.specificLists = const {},
  });

  @override
  _CustomCardState createState() => _CustomCardState();
}

class CardData {
  int totalCards;
  List<Color> starsColors;
  String word;

  CardData({required this.totalCards, required this.starsColors, required this.word});
}

class _CustomCardState extends State<CustomCard> with SingleTickerProviderStateMixin {
  late StreamController<int> _alphabetController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;
  late String randomLetter;
  final controller = StreamController<int>();
  String textFromRollSlotMachine = "";
  bool _isDialogShown = false;
  ui.Image? image;
  String itemToShow = "";
  String category = "";
  String? selectedText;

  @override
  void initState() {
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..repeat(reverse: true); // Powtarzaj animację w kierunku przeciwnym

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    super.initState();
    _alphabetController = StreamController<int>();
    randomLetter = _getRandomLetter();
  }

  @override
  void dispose() {
    _alphabetController.close();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  List<String> splitText(String text) {
    if (text.length > 15) {
      int spaceIndex = text.indexOf(' ', 1);
      if (spaceIndex != -1) {
        return [text.substring(0, spaceIndex), text.substring(spaceIndex + 1)];
      }
    }
    return [text];
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.cardType) {
      case 'field_taboo':
        return buildTabooCard(widget.totalCards, widget.starsColors, widget.slideAnimationController,
            widget.rotationAnimation, widget.opacity, widget.offsetX, widget.word);
      case 'field_star_blue_dark':
        Future.microtask(() {
          if (!_isDialogShown) {
            _isDialogShown = true;
            _showCustomDialog(context);
          }
        });
        return buildBlueDarkCard();
      case 'field_star_green':
        Future.microtask(() {
          if (!_isDialogShown) {
            _isDialogShown = true;
            _showCustomDialogGreen(context);
          }
        });
        return buildGreenCard(); // rysowanie
      case 'field_star_yellow':
        return buildYellowCard(); //pytania porownujace
      default:
        return buildGeneralCard();
    }
  }

// random letter albo reszta kart
  Widget buildGeneralCard() {
    CardData cardData = CardData(
      totalCards: widget.totalCards,
      starsColors: widget.starsColors,
      word: widget.cardType == 'field_letters' ? randomLetter : widget.word,
    );
    return buildCustomCard(cardData);
  }

  //green card start
  void _showCustomDialogGreen(BuildContext context) {
    List<String> cardTypes = ['draw_movie', 'draw_love_pos', 'draw_proverb'];
    String cardType = cardTypes[Random().nextInt(cardTypes.length)];
    String key = "";
    int selectedFortuneItem;
    int maxNumber;

    switch (cardType) {
      case 'draw_movie':
        maxNumber = 100;
        key = 'movies';
        selectedFortuneItem = 0;
        break;
      case 'draw_proverb':
        maxNumber = 88;
        key = 'proverbs';
        selectedFortuneItem = 2;
        break;
      case 'draw_love_pos':
        maxNumber = 44;
        key = 'lovePossibilities';
        selectedFortuneItem = 1;
        break;
      default:
        maxNumber = 100;
        key = 'movies';
        selectedFortuneItem = 0;
    }
    int randomNumber = Random().nextInt(maxNumber) + 1; //losowanie z listy slow
    if (widget.specificLists.containsKey(key) && randomNumber - 1 < widget.specificLists[key]!.length) {
      itemToShow = widget.specificLists[key]![randomNumber - 1];
    }
    print('itemtoshow:$itemToShow, randomnumber: $randomNumber, cardtype: $cardType');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool showDelayedText = false;
        return StatefulBuilder(
          builder: (context, setState) {
            // Rozpoczęcie opóźnienia tylko raz, w momencie budowania dialogu
            if (!showDelayedText) {
              Future.delayed(Duration(seconds: 4), () {
                if (mounted) {
                  setState(() {
                    showDelayedText = true;
                  });
                }
              });
            }
            return WillPopScope(
              onWillPop: () async => false, // Zablokowanie możliwości cofnięcia
              child: AlertDialog(
                backgroundColor: Colors.white,
                content: SizedBox(
                  width: 300,
                  height: 400,
                  child: GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        // Sprawdź, czy możesz wyjść z obecnego kontekstu
                        Navigator.of(context).pop(); // Zamknij dialog
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DrawingScreen(
                                    itemToShow: itemToShow,
                                    category: cardType,
                                    teamColors: widget.teamColors,
                                    teamNames: widget.teamNames))); // Następnie przejdź do nowego ekranu
                      }
                    },
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        InkWell(
                          onTap: () {
                            AnimatedAlertDialog.showCardDescriptionDialog(
                                    context, 'field_star_green', AlertOrigin.cardScreen)
                                .then((_) {});
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
                        SizedBox(height: 20),
                        FortuneBar(
                            height: 70,
                            indicators: const <FortuneIndicator>[
                              FortuneIndicator(
                                alignment: Alignment.topCenter,
                                child: RectangleIndicator(
                                  color: Colors.transparent,
                                  borderColor: Colors.yellow,
                                  borderWidth: 3,
                                ),
                              ),
                            ],
                            physics: CircularPanPhysics(
                              duration: Duration(seconds: 1),
                              curve: Curves.decelerate,
                            ),
                            selected: Stream.value(
                                selectedFortuneItem), // 0-filmy, 1 -poz mil, 2 - powiedzenia - z wylosowanej tam wczesniej liczby
                            styleStrategy: CustomStyleStrategy(),
                            visibleItemCount: 3,
                            items: [
                              FortuneItem(
                                child: Column(
                                  children: [
                                    SizedBox(height: 5),
                                    Icon(Icons.movie, color: Palette().bluegrey),
                                    translatedText(
                                      context,
                                      'movies',
                                      14,
                                      Colors.white,
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                              ),
                              FortuneItem(
                                child: Column(
                                  children: [
                                    SizedBox(height: 5),
                                    Icon(Icons.man, color: Palette().bluegrey),
                                    translatedText(
                                      context,
                                      'love_positions',
                                      14,
                                      Colors.white,
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                              ),
                              FortuneItem(
                                child: Column(
                                  children: [
                                    SizedBox(height: 5),
                                    Icon(Icons.message, color: Palette().bluegrey),
                                    translatedText(
                                      context,
                                      'proverbs',
                                      14,
                                      Colors.white,
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                              ),
                            ]),
                        SizedBox(height: 50),
                        Expanded(
                            child: showDelayedText
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.center, // lub inny sposób wyrównania
                                    children: [
                                      letsText(context, itemToShow, 20, Palette().pink, textAlign: TextAlign.center),
                                      SizedBox(height: 50),
                                      ScaleTransition(
                                        scale: _pulseAnimation,
                                        child: CustomStyledButton(
                                          icon: Icons.play_arrow_rounded,
                                          text: getTranslatedString(
                                              context, 'start_the_task'), // Or use your translated text function
                                          onPressed: () {
                                            if (Navigator.canPop(context)) {
                                              // Sprawdź, czy możesz wyjść z obecnego kontekstu
                                              Navigator.of(context).pop(); // Zamknij dialog
                                              // Następnie przejdź do nowego ekranu i oczekuj na wynik
                                              Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                                builder: (context) => DrawingScreen(
                                                    itemToShow: itemToShow,
                                                    category: cardType,
                                                    teamColors: widget.teamColors,
                                                    teamNames: widget.teamNames),
                                              ))
                                                  .then((result) {
                                                if (result is DrawingResult) {
                                                  print('zwracam obraz');
                                                  safeSetState(() {
                                                    // Przechowywanie obrazu w stanie, aby można było go wyświetlić
                                                    image = result.image;
                                                    widget.onImageSet(); // Wywołanie callbacku
                                                    // Wypisanie itemToShow i category w konsoli
                                                    print("Category: ${result.category}");

                                                    // Możesz też przechować te wartości w stanie, jeśli będą używane w widgetach
                                                    category = result.category;
                                                  });
                                                }
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                    ],
                                  )
                                : translatedText(context, 'randomizing', 20, Palette().pink)),
                      ],
                    ),
                  ),
                ),
                actions: const <Widget>[],
              ),
            );
          },
        );
      },
    ).then((returnedValue) {
      if (returnedValue != null) {
        setState(() {
          print('maluski tescik');
        });
      }
    });
  }

  Widget buildGreenCard() {
    return FractionallySizedBox(
      widthFactor: 0.7,
      child: Stack(
        children: [
          Container(
            height: 400.0,
            padding: EdgeInsets.all(13.0),
            child: Card(
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: BorderSide(color: Palette().white, width: 13.0),
              ),
              elevation: 0.0,
              child: image != null //TO_DO tu musze wiedziec ze trzeba uruchomic timer
                  ? Column(
                      children: [
                        SizedBox(height: 30),
                        //letsText(context, itemToShow, 20, Colors.white),
                        translatedText(context, 'guess', 14, Colors.white, textAlign: TextAlign.center),
                        letsText(
                            context,
                            getTranslatedString(
                                context,
                                category == 'draw_movie'
                                    ? 'category_draw_movie'
                                    : category == 'draw_proverb'
                                        ? 'category_draw_proverbs'
                                        : category == 'draw_love_pos'
                                            ? 'category_love_positions'
                                            : 'default_category'),
                            14,
                            Palette().white),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(15.0),
                            child: CustomPaint(
                              painter: ImagePainter(image: image!),
                              child: SizedBox(
                                width: image!.width.toDouble(),
                                height: image!.height.toDouble(),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 40),
                      ],
                    )
                  : Center(child: Text("No images selected")),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 200),
              transitionBuilder: _transitionBuilder,
              child: widget.imageType != null ? buildImageWidget(widget.imageType) : SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
  //green card end

  //blue dark card start
  void _showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      //barrierColor: Colors.black.withOpacity(0.5), // Przyciemnienie tła
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent, // Tło kontenera powinno być przezroczyste
          child: Container(
            width: 300, // Szerokość dialogu
            height: 400, // Wysokość dialogu
            decoration: BoxDecoration(
              color: Colors.white, // kolor tła RollSlotMachine
              borderRadius: BorderRadius.circular(15), // Zaokrąglenie rogów
            ),
            child: RollSlotMachine(),
          ),
        );
      },
    ).then((returnedValue) {
      if (returnedValue != null) {
        setState(() {
          textFromRollSlotMachine = returnedValue as String;
          // Po zakończeniu działania Roll Slot Machine
          widget.onRollSlotMachineResult(textFromRollSlotMachine);
          print('Text $textFromRollSlotMachine');
        });
      }
    });
  }

  List<Widget> createWidgetsFromText(String text) {
    // Podziel tekst przy każdym wystąpieniu średnika
    List<String> parts = text.split(';');

    if (parts.length >= 3) {
      String person = parts[0].trim();
      String number = parts[1].trim();
      String activity = parts[2].trim();

      // Mapowanie tekstów na obrazki osób
      Map<String, String> personToImage = {
        'woman': 'assets/time_to_party_assets/activities/woman.png',
        'man': 'assets/time_to_party_assets/activities/man.png',
      };

      // Mapowanie aktywności na obrazki
      Map<String, String> activityToImage = {
        'jumping_jacks': 'assets/time_to_party_assets/activities/jumping_jacks.png',
        'sit-ups': 'assets/time_to_party_assets/activities/situps.png',
        'push-ups': 'assets/time_to_party_assets/activities/pushups.png',
        'squats': 'assets/time_to_party_assets/activities/squats.png',
      };

      return [
        _getTextWidget(person == 'woman' ? getTranslatedString(context, 'woman') : getTranslatedString(context, 'man')),
        _getImageWidget(personToImage[person] ?? ''),
        //_getTextWidget(getTranslatedString(context, 'does')),
        _getTextWidget(number),
        _getTextWidget(getTranslatedString(context, activity)),
        _getImageWidget(activityToImage[activity] ?? ''),
      ];
    }

    return [_getTextWidget('Wrong format!')];
  }

  Widget _getTextWidget(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'HindMadurai',
        fontSize: 30.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: const [
          Shadow(
            offset: Offset(1.0, 4.0),
            blurRadius: 15.0,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ],
      ),
    );
  }

  Widget _getImageWidget(String imagePath) {
    return Image.asset(imagePath,
        height: 70, errorBuilder: (context, error, stackTrace) => _getTextWidget('Brak obrazu'));
  }

  Widget buildBlueDarkCard() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: widget.offsetX),
      duration: Duration(milliseconds: 250),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value, 0),
          child: Transform.rotate(
            angle: widget.rotationAnimation.value,
            child: FractionallySizedBox(
              widthFactor: 0.7,
              child: AnimatedOpacity(
                opacity: widget.opacity,
                duration: Duration(milliseconds: 250),
                child: ScaleTransition(
                  scale: widget.slideAnimationController,
                  child: Stack(
                    children: [
                      Container(
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
                            children: [
                              SizedBox(height: 20),
                              buildStarsRow(widget.totalCards, widget.starsColors),
                              SizedBox(height: 5),
                              Expanded(
                                child: Column(
                                  children: createWidgetsFromText(textFromRollSlotMachine),
                                ),
                              ),
                              SizedBox(height: 5),
                              buildStarsRow(widget.totalCards, widget.starsColors),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 200),
                          transitionBuilder: _transitionBuilder,
                          child: widget.imageType != null ? buildImageWidget(widget.imageType) : SizedBox(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
// blue dark card end

  //compare questions

  int selectedValue = -1; // Początkowa wartość, wskazująca, że nic nie jest wybrane

  Widget buildYellowCard() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: widget.offsetX),
      duration: Duration(milliseconds: 250),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value, 0),
          child: Transform.rotate(
            angle: widget.rotationAnimation.value,
            child: FractionallySizedBox(
              widthFactor: 0.7,
              child: AnimatedOpacity(
                opacity: widget.opacity,
                duration: Duration(milliseconds: 250),
                child: ScaleTransition(
                  scale: widget.slideAnimationController,
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
                        children: [
                          SizedBox(height: 20),
                          buildStarsRow(widget.totalCards, widget.starsColors),
                          Expanded(
                            child: ListView.builder(
                              itemCount: widget.buildFortuneItemsList.length,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  // Dla pierwszego elementu wyświetl tylko tekst
                                  return Padding(
                                      padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                                      child: letsText(context, widget.buildFortuneItemsList[index], 14, Colors.white,
                                          textAlign: TextAlign.center));
                                } else {
                                  // Dla pozostałych elementów użyj RadioListTile
                                  return RadioListTile<int>(
                                    title: letsText(context, widget.buildFortuneItemsList[index], 14, Colors.white),
                                    value: index,
                                    groupValue: widget.resetSelection,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedValue = value!;
                                      });
                                      String selectedText = widget.buildFortuneItemsList[index];
                                      widget.onSelectionMade(value, selectedText);
                                    },
                                    activeColor: Colors.white,
                                  );
                                }
                              },
                            ),
                          ),
                          buildStarsRow(widget.totalCards, widget.starsColors),
                          SizedBox(height: 20),
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

  // pantomima, slawne osoby, rymowanie, literka - pobieraja z 1 rekordu
  Widget buildCustomCard(CardData cardData) {
    List<String> splitWords = splitText(cardData.word);
    EdgeInsets padding =
        splitWords.length > 1 ? const EdgeInsets.all(8.0) : const EdgeInsets.all(20.0); //padding do posplitowanych
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: widget.offsetX),
      duration: Duration(milliseconds: 250),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value, 0),
          child: Transform.rotate(
            angle: widget.rotationAnimation.value,
            child: FractionallySizedBox(
              widthFactor: 0.7,
              child: AnimatedOpacity(
                opacity: widget.opacity,
                duration: Duration(milliseconds: 250),
                child: ScaleTransition(
                  scale: widget.slideAnimationController,
                  child: Stack(
                    children: [
                      Container(
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
                            children: [
                              SizedBox(height: 20),
                              buildStarsRow(cardData.totalCards, cardData.starsColors),
                              SizedBox(height: 100),
                              Expanded(
                                child: Container(
                                  padding: padding,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: const [Color(0xffB46BDF), Color(0xff6625FF), Color(0xff211753)],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: splitWords
                                              .map((word) => Text(
                                                    word,
                                                    style: TextStyle(
                                                        fontFamily: 'HindMadurai',
                                                        color: Colors.white,
                                                        fontSize: word.length > 15 ? 20 : 24),
                                                    softWrap: true,
                                                  ))
                                              .toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 100),
                              buildStarsRow(cardData.totalCards, cardData.starsColors),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 200),
                          transitionBuilder: _transitionBuilder,
                          child: widget.imageType != null ? buildImageWidget(widget.imageType) : SizedBox(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildStarsRow(int totalCards, List<Color> starsColors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalCards, (index) => buildStarIcon(starsColors[index])),
    );
  }

  Widget buildStarIcon(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Icon(Icons.star, color: color, size: 20),
    );
  }

  String _getRandomLetter() {
    var randomIndex = Random().nextInt(widget.buildFortuneItemsList.length);
    return widget.buildFortuneItemsList[randomIndex];
  }

  // karta taboo
  Widget buildTabooCard(int totalCards, List<Color> starsColors, AnimationController slideAnimationController,
      Animation<double> rotationAnimation, double opacity, double offsetX, String word) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: offsetX),
      duration: Duration(milliseconds: 250),
      builder: (context, value, child) {
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
                  child: Stack(
                    children: [
                      Container(
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
                                    colors: const [Color(0xffB46BDF), Color(0xff6625FF), Color(0xff211753)],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [wordText(context, word, 24, Colors.white, index: 0)],
                                ),
                              ),
                              wordText(context, word, 20, Colors.white, index: 1),
                              wordText(context, word, 20, Colors.white, index: 2),
                              wordText(context, word, 20, Colors.white, index: 3),
                              wordText(context, word, 20, Colors.white, index: 4),
                              wordText(context, word, 20, Colors.white, index: 5),
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
                      Positioned(
                        top: 0,
                        right: 0,
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 200),
                          transitionBuilder: _transitionBuilder,
                          child: widget.imageType != null ? buildImageWidget(widget.imageType) : SizedBox(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void onSelectionMade(int selectedValue, String selectedText) {}

  Widget _transitionBuilder(Widget child, Animation<double> animation) {
    Animation<Offset> shakeAnimation = _shakeAnimation(animation);
    Animation<double> rotateAnimation = _rotateAnimation(animation);

    return ScaleTransition(
      scale: animation,
      child: FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: shakeAnimation,
          child: RotationTransition(
            turns: rotateAnimation,
            child: child,
          ),
        ),
      ),
    );
  }

  Widget buildImageWidget(ImageType? imageType) {
    switch (imageType) {
      case ImageType.declined:
        return SvgPicture.asset('assets/time_to_party_assets/cards_screens/button_declined.svg');
      case ImageType.approved:
        return SvgPicture.asset('assets/time_to_party_assets/cards_screens/button_approved.svg');
      case ImageType.skipped:
        return SvgPicture.asset('assets/time_to_party_assets/cards_screens/button_drop.svg');
      case ImageType.empty:
      default:
        return SizedBox(); // Pusty widget dla 'empty' lub 'null'
    }
  }

  Animation<Offset> _shakeAnimation(Animation<double> animation) {
    // Zakładamy, że "shake" zaczyna się w połowie naszej głównej animacji
    final shakeStart = 0.9;
    final shakeDuration = 0.1;

    return TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: Offset.zero, end: Offset(0.02, 0.0))
            .chain(CurveTween(curve: Interval(shakeStart, shakeStart + shakeDuration / 4))),
        weight: 1.0,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Offset(0.02, 0.0), end: Offset(-0.02, 0.0))
            .chain(CurveTween(curve: Interval(shakeStart + shakeDuration / 4, shakeStart + shakeDuration / 2))),
        weight: 1.0,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Offset(-0.02, 0.0), end: Offset(0.02, 0.0))
            .chain(CurveTween(curve: Interval(shakeStart + shakeDuration / 2, shakeStart + 3 * shakeDuration / 4))),
        weight: 1.0,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Offset(0.02, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: Interval(shakeStart + 3 * shakeDuration / 4, shakeStart + shakeDuration))),
        weight: 1.0,
      ),
    ]).animate(animation);
  }

  Animation<double> _rotateAnimation(Animation<double> animation) {
    final rotateStart = 0.9; // Rozpoczęcie obracania później
    final rotateDuration = 0.1; // Krótsza czas trwania obracania

    return TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -0.02) // Mniejszy zakres obrotu
            .chain(CurveTween(curve: Interval(rotateStart, rotateStart + rotateDuration / 4))),
        weight: 1.0,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -0.02, end: 0.02)
            .chain(CurveTween(curve: Interval(rotateStart + rotateDuration / 4, rotateStart + rotateDuration / 2))),
        weight: 1.0,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.02, end: -0.02)
            .chain(CurveTween(curve: Interval(rotateStart + rotateDuration / 2, rotateStart + 3 * rotateDuration / 4))),
        weight: 1.0,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -0.02, end: 0.0)
            .chain(CurveTween(curve: Interval(rotateStart + 3 * rotateDuration / 4, rotateStart + rotateDuration))),
        weight: 1.0,
      ),
    ]).animate(animation);
  }
}

enum ImageType {
  declined,
  approved,
  skipped,
  empty,
}
