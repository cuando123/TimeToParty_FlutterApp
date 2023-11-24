import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:game_template/src/play_session/card_screens/roll_slot_machine.dart';

import '../../app_lifecycle/translated_text.dart';
import '../../style/palette.dart';
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

  CustomCard(
      {Key? key,
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
      })
      : super(key: key);

  @override
  _CustomCardState createState() => _CustomCardState();

}

class CardData {
  int totalCards;
  List<Color> starsColors;
  String word;

  CardData({required this.totalCards, required this.starsColors, required this.word});
}

class _CustomCardState extends State<CustomCard> {
  late StreamController<int> _alphabetController;
  late String randomLetter;
  final controller = StreamController<int>();
  String textFromRollSlotMachine = "";
  bool _isDialogShown = false;

  @override
  void initState() {
    super.initState();
    _alphabetController = StreamController<int>();
    randomLetter = _getRandomLetter();
  }

  @override
  void dispose() {
    _alphabetController.close();
    super.dispose();
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
      case 'field_star_pink':
        return buildPinkCard(); // antonimy synonimy
      case 'field_star_green':
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

  Widget buildGreenCard() {
    List<String> cardTypes = ['draw_movie', 'draw_proverb', 'draw_love_pos'];
    String cardType = cardTypes[Random().nextInt(cardTypes.length)];

    int maxNumber;
    switch (cardType) {
      case 'draw_movie':
        maxNumber = 100;
        break;
      case 'draw_proverb':
        maxNumber = 88;
        break;
      case 'draw_love_pos':
        maxNumber = 44;
        break;
      default:
        maxNumber = 100;
    }

    int randomNumber = Random().nextInt(maxNumber) + 1;
    String cardText = '$cardType$randomNumber';

    String itemToShow = "";
    String key = 'lovePossibilities'; // lub inny klucz w zależności od potrzeb
    int index = randomNumber; // lub inny indeks w zależności od potrzeb
    if (widget.specificLists.containsKey(key) && index - 1 < widget.specificLists[key]!.length) {
      itemToShow = widget.specificLists[key]![index - 1];
    }
    print ('itemtoshow:$itemToShow, randomnumber: $randomNumber, cardtype: $cardType');
    // Tworzenie widoku karty
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => DrawingScreen()));
      }, child: FractionallySizedBox(
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
          child: Column(
            children: [
              SizedBox(height: 20),
              SizedBox(height: 15),
              Expanded(
                child: Text('$itemToShow: kliknij mnie', style: TextStyle(color: Colors.black)),
                //SlotMachinePage(title: 'tytul')
              ),
              FortuneBar(
                  physics: CircularPanPhysics(
                    duration: Duration(seconds: 1),
                    curve: Curves.decelerate,
                  ),
                  onFling: () {
                    controller.add(3);
                  },
                  selected: controller.stream,
                  styleStrategy: AlternatingStyleStrategy(),
                  visibleItemCount: 3,

                  items: const [
                    FortuneItem(child: Text('Filmy')),
                    FortuneItem(child: Text('Pozycje Miłosne')),
                    FortuneItem(child: Text('Powiedzenia')),
                  ]
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),),
    );
  }

  Widget buildPinkCard() {
    // Implementacja dla Pink Card
    return buildGeneralCard();
  }

  void _showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
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


  Widget buildBlueDarkCard() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: widget.offsetX),
      duration: Duration(milliseconds: 250),
      builder: (BuildContext context, double value, Widget? child) {
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
                          SizedBox(height: 15),
                          Expanded(
                            //child: PhysicalChallengeCard(),
                              child: Text(textFromRollSlotMachine, style: TextStyle(
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
                              ),)
                          ),
                          SizedBox(height: 10),
                          buildStarsRow(widget.totalCards, widget.starsColors),
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

  //compare questions
  Widget buildYellowCard() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: widget.offsetX),
      duration: Duration(milliseconds: 250),
      builder: (BuildContext context, double value, Widget? child) {
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
                          SizedBox(height: 15),
                          Expanded(
                            child: ListView.builder(
                              itemCount: widget.buildFortuneItemsList.length,
                              itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(widget.buildFortuneItemsList[index],
                                    style: TextStyle(color: Colors.white, fontSize: 24)),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          buildStarsRow(widget.totalCards, widget.starsColors),
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

  // pantomima, slawne osoby, rymowanie,
  Widget buildCustomCard(CardData cardData) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: widget.offsetX),
      duration: Duration(milliseconds: 250),
      builder: (BuildContext context, double value, Widget? child) {
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
                              children: [
                                Text(cardData.word, style: TextStyle(fontFamily: 'HindMadurai', color: Colors.white, fontSize: 24)),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          buildStarsRow(cardData.totalCards, cardData.starsColors),
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
}