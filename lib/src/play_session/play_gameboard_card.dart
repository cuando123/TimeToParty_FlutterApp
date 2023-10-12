import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
        _offsetX = 0;  // Resetowanie pozycji karty do środka
      });
      _animationController.reset();  // Resetowanie animacji skali
      _showCard();  // Uruchamianie animacji "wyskoku"
    });
  }

  void _dismissCardToRight() {
    setState(() {
      _offsetX = MediaQuery.of(context).size.width;
    });
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _offsetX = 0;  // Resetowanie pozycji karty do środka
      });
      _animationController.reset();  // Resetowanie animacji skali
      _showCard();  // Uruchamianie animacji "wyskoku"
    });
  }



  void _showCard() {
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Color(0xFF261853), // Kolor tła z pierwszego fragmentu
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Drużyna 1',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20.0),
            Center(child:
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: _offsetX),
                  duration: Duration(milliseconds: 300),
                  builder: (BuildContext context, double value, Widget? child) {
                    return Transform.translate(
                      offset: Offset(value, 0),
                      child: child,
                    );
                  },
                  child: FractionallySizedBox(
                widthFactor: 0.6,
                child: AnimatedOpacity(
                  opacity: _opacity,
                  duration: Duration(milliseconds: 500),
                  child: ScaleTransition(
                    scale: _animationController,
                    child: Transform.translate(
                      offset:
                          Offset(_offsetX * _slideAnimationController.value, 0),
                      child: FractionallySizedBox(
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            side: BorderSide(
                                color: Color(0xff6625FF), width: 1.0),
                          ),
                          elevation: 5.0,
                          child: Column(
                            children: <Widget>[
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
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: const <Widget>[
                                    Text('Taboo',
                                        style: TextStyle(
                                          fontFamily: 'HindMadurai',
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center),
                                    Icon(Icons.favorite, color: Colors.white),
                                  ],
                                ),
                              ),
                              Divider(height: 1.0, color: Color(0xff6625FF)),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.white38,
                                      Colors.black12
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(15),
                                    bottomRight: Radius.circular(15),
                                  ),
                                ),
                                //color: Colors.white,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      ListTile(
                                        title: Text('SŁOWO 1',
                                            textAlign: TextAlign.center),
                                      ),
                                      ListTile(
                                        title: Text('SŁOWO 2',
                                            textAlign: TextAlign.center),
                                      ),
                                      ListTile(
                                        title: Text('SŁOWO 3',
                                            textAlign: TextAlign.center),
                                      ),
                                      ListTile(
                                        title: Text('SŁOWO 4',
                                            textAlign: TextAlign.center),
                                      ),
                                      ListTile(
                                        title: Text('SŁOWO 5',
                                            textAlign: TextAlign.center),
                                      ),
                                    ],
                                  ),
                                ),
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
            ..._displayValues(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GradientButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  text: 'Pop Screen',
                  icon: Icons.recycling,
                  gradientColors: const [
                    Color(0xffB46BDF),
                    Color(0xff6625FF),
                    Color(0xff211753)
                  ],
                ),
                GradientButton(
                  onPressed: () => _dismissCardToLeft(),
                  text: 'Cancel card',
                  icon: Icons.close_outlined,
                  gradientColors: const [
                    Color(0xffB46BDF),
                    Color(0xff6625FF),
                    Color(0xff211753)
                  ],
                ),
                GradientButton(
                  onPressed: () => _dismissCardToRight(),
                  text: 'Good answer',
                  icon: Icons.check,
                  gradientColors: const [
                    Color(0xffB46BDF),
                    Color(0xff6625FF),
                    Color(0xff211753)
                  ],
                )
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

  List<Widget> _displayValues() {
    List<Widget> displayWidgets = [];

    for (String name in widget.teamNames) {
      displayWidgets.add(Text(
        name,
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
      displayWidgets.add(SizedBox(height: 20.0));
    }

    for (Color color in widget.teamColors) {
      displayWidgets.add(Container(
        width: 50,
        height: 50,
        color: color,
      ));
    }

    for (String field in widget.currentField) {
      displayWidgets.add(Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5.0,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListTile(title: Text(field)),
        ),
      ));
    }

    return displayWidgets;
  }
}

class GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData icon;
  final List<Color> gradientColors;

  GradientButton({
    required this.onPressed,
    required this.text,
    required this.icon,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        padding: MaterialStateProperty.all(
            EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
        backgroundColor: MaterialStateProperty.all(Colors
            .transparent), // Tło przezroczyste, ponieważ używamy gradientu w Ink
        shadowColor:
            MaterialStateProperty.all(Colors.transparent), // Brak cienia
        elevation: MaterialStateProperty.all(0),
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors, // Kolory gradientu
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black38, // Kolor cienia
              offset: Offset(2, 6), // Położenie cienia
              blurRadius: 5, // Rozmycie cienia
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 25.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 50),
              Text(
                text,
                style: TextStyle(
                  fontFamily: 'HindMadurai',
                  fontSize: ResponsiveSizing.scaleHeight(context, 12),
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
