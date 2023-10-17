import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

// Zakładam, że importy z twojego drugiego fragmentu są nadal potrzebne
import '../app_lifecycle/translated_text.dart';
import '../play_session/play_gameboard_main.dart';
import '../style/palette.dart';
import 'package:flutter/services.dart';

class PlayGameboardCard extends StatefulWidget {
  final List<String> teamNames;
  final List<Color> teamColors;
  final List<String> currentField;

  PlayGameboardCard(
      {required this.teamNames,
      required this.teamColors,
      required this.currentField});

  @override
  _PlayGameboardCardState createState() => _PlayGameboardCardState();
}

class _PlayGameboardCardState extends State<PlayGameboardCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _slideAnimationController;

  double _opacity = 0;
  double _offsetX = 0;

  @override
  void initState() {
    super.initState();
    _slideAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animationController.addListener(() {
      setState(() {
        _opacity = _animationController.value;
      });
    });
    _showCard(); // By karta pojawiła się na początku
  }

  void _dismissCardToLeft() {
    setState(() {
      _offsetX = -MediaQuery.of(context).size.width;
    });
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _offsetX = 0; // Resetowanie pozycji karty do środka
        _animationController.reset(); // Resetowanie animacji skali
      });
      _showCard(); // Uruchamianie animacji "wyskoku"
    });
  }

  void _dismissCardToRight() {
    setState(() {
      _offsetX = MediaQuery.of(context).size.width;
    });
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _offsetX = 0; // Resetowanie pozycji karty do środka
        _animationController.reset(); // Resetowanie animacji skali
      });
      _showCard(); // Uruchamianie animacji "wyskoku"
    });
  }

  void _showCard() {
    _animationController.forward(from: 0);
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.pause,
                      color: Colors.white, size: 30), // Ikona pauzy
                  Spacer(),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    // Odstępy wewnątrz prostokąta
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      // Przezroczysty czarny kolor
                      borderRadius:
                          BorderRadius.circular(8.0), // Zaokrąglenie rogów
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
                  Icon(Icons.info_outlined,
                      color: Colors.white, size: 30), // Ikona zgłoś błąd
                ],
              ),
            ),
            SizedBox(height: 10.0),
            ..._displayCurrentField(),
            SizedBox(height: 15.0),
            Stack(
              alignment: Alignment.center,
              children: [
// Tło okrągłe
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.transparent,
                  child: SizedBox.expand(
                    child: CustomPaint(
                      painter: CircleProgressPainter(segments: 15, progress: 1/15*5),
                    ),
                  ),
                ),
// Tekst w środku
                Text(
                  '15',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
            SizedBox(height: 15.0),
            Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: _offsetX),
                    duration: Duration(milliseconds: 300),
                    builder: (BuildContext context, double value, Widget? child) {
                      return Transform.translate(
                        offset: Offset(value, 0),
                        child: child,
                      );
                    },
                    child: FractionallySizedBox(
                      widthFactor: 0.7,
                      child: AnimatedOpacity(
                        opacity: _opacity,
                        duration: Duration(milliseconds: 500),
                        child: ScaleTransition(
                          scale: _animationController,
                          child: Transform.translate(
                            offset: Offset(
                                _offsetX * _slideAnimationController.value, 0),
                            child: Container(
                              height: 400.0,
                              padding: EdgeInsets.all(13.0),
                              child: Card(
                                color: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  side: BorderSide(
                                      color: Palette().white, width: 13.0),
                                ),
                                elevation: 0.0,
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(5, (index) {
                                        return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 2),
                                            child: Icon(
                                              index < 2
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color: index == 0
                                                  ? Colors.green
                                                  : index == 1
                                                  ? Colors.red
                                                  : index == 2
                                                  ? Colors.yellow
                                                  : Colors.grey,
                                              size: 20,
                                              // Dla trzeciej gwiazdki (index == 2) dodajemy cień, aby uzyskać efekt podświetlenia na biało.
                                              //shadowColor: index == 2 ? Colors.white : null,
                                            ));
                                      }),
                                    ),
                                    SizedBox(height: 105),
                                    Container(
                                      padding: const EdgeInsets.all(20.0),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xffB46BDF),
                                            Color(0xff6625FF),
                                            Color(0xff211753)
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const <Widget>[
                                          Text('Taboo',
                                              style: TextStyle(
                                                fontFamily: 'HindMadurai',
                                                fontSize: 24.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                shadows: [
                                                  Shadow(
                                                    offset: Offset(1.0, 4.0),
                                                    blurRadius: 15.0,
                                                    color: Color.fromARGB(255, 0, 0,
                                                        0), // Kolor cienia, w tym przypadku czarny
                                                  ),
                                                ],
                                              ),
                                              textAlign: TextAlign.center),
                                          SizedBox(width: 10),
                                          Icon(Icons.favorite, color: Colors.white),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 105),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(5, (index) {
                                        return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 2),
                                            child: Icon(
                                              index < 2
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color: index == 0
                                                  ? Colors.green
                                                  : index == 1
                                                  ? Colors.red
                                                  : index == 2
                                                  ? Colors.yellow
                                                  : Colors.grey,
                                              size: 20,
                                              // Dla trzeciej gwiazdki (index == 2) dodajemy cień, aby uzyskać efekt podświetlenia na biało.
                                              //shadowColor: index == 2 ? Colors.white : null,
                                            ));
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
                  ),
                ),
                Positioned(
                    top: 0,
                    right: 40,
                    child: Container(
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
                    )),
              ],
            ),
            //SizedBox(height: 10),
            Text('Karta 1 z 8',
                style: TextStyle(
                    color: Palette().white,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'HindMadurai')),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Spacer(),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgButton(
                      assetName:
                          'assets/time_to_party_assets/cards_screens/button_drop.svg',
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: EdgeInsets.all(2), // Grubość obramowania
                          decoration: BoxDecoration(
                            color:
                                Palette().yellowIndBorder, // Kolor obramowania
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 12,
                            // Dostosuj rozmiar w zależności od potrzeb
                            backgroundColor: Palette().yellowInd,
                            child: Text('2',
                                style: TextStyle(
                                    color: Palette().darkGrey,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'HindMadurai')),
                          ),
                        )),
                  ],
                ),
                //SizedBox(width: 10),
                SvgButton(
                  assetName:
                      'assets/time_to_party_assets/cards_screens/button_declined.svg',
                  onPressed: () => _dismissCardToLeft(),
                ),
                //SizedBox(width: 10),
                SvgButton(
                  assetName:
                      'assets/time_to_party_assets/cards_screens/button_approved.svg',
                  onPressed: () {
                    _dismissCardToRight();
                  },
                ),
                Spacer(),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _slideAnimationController.dispose();
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
      String flagColorHex = 'FF' +
          flag.split('/').last.split('.').first.substring(5); //zmiana z 4 na 5
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
    'field_letters': 'Literki',
    'field_pantomime': 'Pantomimy',
    'field_microphone': 'Sławne osoby',
    'field_start': 'Pole startu',
    'field_star_blue_dark': 'Trochę ruchu',
    'field_star_blue_light': 'Antonimy',
    'field_star_green': 'Rysowanie',
    'field_star_pink': 'Taboo',
    'field_star_yellow': 'Pytania',
  };

  List<Widget> _displayCurrentField() {
    List<Widget> displayWidgets = [];

    for (String fieldType in widget.currentField) {
      String currentTitle = fieldTypeTranslations[fieldType] ?? fieldType;

      displayWidgets.add(
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
                color: Color.fromARGB(255, 0, 0,
                    0), // Kolor cienia, w tym przypadku czarny
              ),
            ],
          ),
        ),
      );
    }

    return displayWidgets;
  }
}

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

class _SvgButtonState extends State<SvgButton>
    with SingleTickerProviderStateMixin {
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
              height: ResponsiveSizing.scaleHeight(context, 75),
              width: double.maxFinite),
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



// ... poza klasą widgetu:
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
    double gapAngle = segmentAngle * 0.1;  // 10% gap, you can adjust
    double fillAngle = segmentAngle - gapAngle;

    // Rysowanie tła
    for (int i = 0; i < segments; i++) {
      double start = i * segmentAngle - pi / 2;
      canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          start,
          fillAngle,
          false,
          paintBackground);
    }

    // Rysowanie postępu
    double filledSegments = segments * progress;
    for (int i = 0; i < filledSegments; i++) {
      double start = i * segmentAngle - pi / 2;
      canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          start,
          fillAngle,
          false,
          paintProgress);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


