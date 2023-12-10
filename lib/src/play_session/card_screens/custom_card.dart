import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:game_template/src/play_session/card_screens/roll_slot_machine.dart';
import 'package:game_template/src/play_session/card_screens/styles/custom_style_strategy_bar.dart';
import 'package:game_template/src/play_session/card_screens/styles/image_painter.dart';
import 'package:game_template/src/play_session/extensions.dart';

import '../../app_lifecycle/translated_text.dart';
import '../../style/palette.dart';
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
  final void Function(String result) onRollSlotMachineResult;

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
            return AlertDialog(
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
                                  itemToShow: itemToShow, category: cardType))); // Następnie przejdź do nowego ekranu
                    }
                  },
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      FortuneBar(
                          physics: CircularPanPhysics(
                            duration: Duration(seconds: 1),
                            curve: Curves.decelerate,
                          ),
                          selected: Stream.value(
                              selectedFortuneItem), // 0-filmy, 1 -poz mil, 2 - powiedzenia - z wylosowanej tam wczesniej liczby
                          styleStrategy: CustomStyleStrategy(),
                          visibleItemCount: 3,
                          items: const [
                            FortuneItem(child:
                            Column(children: [
                              Icon(Icons.movie),
                              Text('Filmy', textAlign: TextAlign.center,)
                            ],),),
                            FortuneItem(child:
                            Column(children: [
                              Icon(Icons.man),
                              Text('Pozycje miłosne', textAlign: TextAlign.center,)
                            ],),),
                            FortuneItem(child:
                            Column(children: [
                              Icon(Icons.message),
                              Text('Powiedzenia', textAlign: TextAlign.center,)
                            ],),),
                          ]),
                      SizedBox(height: 20),
                      Expanded(
                          child: showDelayedText
                              ? Text(itemToShow, style: TextStyle(color: Colors.black))
                              : Text('Losuje...', style: TextStyle(color: Colors.black))),
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: CustomStyledButton(
                          icon: Icons.play_arrow_rounded,
                          text: 'Zacznij zadanie!', // Or use your translated text function
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
                                ),
                              ))
                                  .then((result) {
                                if (result is DrawingResult) {
                                  print('zwracam');
                                  safeSetState(() {
                                    // Przechowywanie obrazu w stanie, aby można było go wyświetlić
                                    image = result.image;

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
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              actions: const <Widget>[],
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
          child: image != null //TO_DO tu musze wiedziec ze trzeba uruchomic timer
              ? Column(
                  children: [
                    SizedBox(height: 30),
                    //letsText(context, itemToShow, 20, Colors.white),
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
                    Expanded( child:
                    Padding(
                      padding: EdgeInsets.all(15.0),
                      child: CustomPaint(
                        painter: ImagePainter(image: image!),
                        child: SizedBox(
                          width: image!.width.toDouble(),
                          height: image!.height.toDouble(),
                        ),
                      ),
                    ),),
                    SizedBox(height: 30),
                  ],
                )
              : Center(child: Text("No images selected")), // Tu możesz umieścić dowolny widget, gdy obraz jest null
        ),
      ),
    );
  }

  //blue dark card start
  void _showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: SizedBox(
            width: 300, // Szerokość dialogu
            height: 400, // Wysokość dialogu
            child: RollSlotMachine(),
          ),
          actions: const <Widget>[],
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
    RegExp regExp = RegExp(r'(\D+)(\d+)(\D+)');
    RegExpMatch? match = regExp.firstMatch(text);

    if (match != null) {
      String person = match.group(1) ?? '';
      String number = match.group(2) ?? '';
      String activity = match.group(3) ?? '';

      // Mapowanie tekstów na obrazki osób
      Map<String, String> personToImage = {
        'woman': 'assets/time_to_party_assets/activities/woman.png',
        'man': 'assets/time_to_party_assets/activities/man.png',
      };

      // Mapowanie aktywności na obrazki
      Map<String, String> activityToImage = {
        'pajacyki': 'assets/time_to_party_assets/activities/jumping_jacks.png',
        'brzuszki': 'assets/time_to_party_assets/activities/situps.png',
        'pompki': 'assets/time_to_party_assets/activities/pushups.png',
        'przysiady': 'assets/time_to_party_assets/activities/squats.png',
      };

      return [
        _getImageWidget(personToImage[person] ?? ''),
        _getTextWidget(person == 'woman' ? 'kobieta' : 'mężczyzna'),
        _getTextWidget('robi'),
        _getTextWidget(number),
        _getImageWidget(activityToImage[activity] ?? ''),
        _getTextWidget(activity)
      ];
    }

    return [_getTextWidget('Niepoprawny format')];
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
        height: 50, errorBuilder: (context, error, stackTrace) => _getTextWidget('Brak obrazu'));
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
                                    child: Text(widget.buildFortuneItemsList[index],
                                        style: TextStyle(color: Colors.white, fontSize: 14)),
                                  );
                                } else {
                                  // Dla pozostałych elementów użyj RadioListTile
                                  return RadioListTile<int>(
                                    title: Text(
                                      widget.buildFortuneItemsList[index],
                                      style: TextStyle(color: Colors.white, fontSize: 14),
                                    ),
                                    value: index,
                                    groupValue: selectedValue,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedValue = value!;
                                      });
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
                                                    fontFamily: 'HindMadurai', color: Colors.white, fontSize: 24),
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
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
