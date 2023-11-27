import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';

import '../../style/palette.dart';

class CircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()..addOval(Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2));
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class MyFortuneWheel extends StatefulWidget {
  final StreamController<int> selected;

  MyFortuneWheel({required this.selected});

  @override
  _MyFortuneWheelState createState() => _MyFortuneWheelState();
}

enum AnimationPhase { movingForward, movingBackward, blinking, pausing }

class _MyFortuneWheelState extends State<MyFortuneWheel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int? _highlightedStripe = -1; // Start z -1, aby na początku nic nie było podświetlone
  AnimationPhase _currentPhase = AnimationPhase.movingForward;
  int _blinkCounter = 0;
  Timer? _pauseTimer;
  Timer? _phaseTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )..addListener(_updateAnimation);
    _startNextPhase();
  }

  void _startNextPhase() {
    if (_phaseTimer != null && _phaseTimer!.isActive) {
      _phaseTimer!.cancel();
    }
    _controller.forward(from: 0); // Zawsze zaczynamy od początku
    // Ustawienie timera dla aktualnej fazy
    var phaseDuration = Duration(seconds: 3); // Domyślny czas trwania fazy
    switch (_currentPhase) {
      case AnimationPhase.movingForward:
      case AnimationPhase.movingBackward:
        phaseDuration = Duration(seconds: 3); // Czas trwania dla tych faz
        break;
      case AnimationPhase.blinking:
        phaseDuration = Duration(seconds: 3); // Czas na mryganie
        break;
      case AnimationPhase.pausing:
      // Pausing ma swój własny timer
        _pauseTimer = Timer(Duration(seconds: 3), () {
          _highlightedStripe = -1;
          _currentPhase = AnimationPhase.movingForward;
          _startNextPhase();
        });
        return; // Wychodzimy, aby nie ustawić dodatkowego timera
    }
    _phaseTimer = Timer(phaseDuration, _nextPhase); // Ustawienie timera
  }

  void _nextPhase() {
    // Logika przejścia do następnej fazy
    switch (_currentPhase) {
      case AnimationPhase.movingForward:
        _currentPhase = AnimationPhase.movingBackward;
        break;
      case AnimationPhase.movingBackward:
        _currentPhase = AnimationPhase.blinking;
        break;
      case AnimationPhase.blinking:
        _currentPhase = AnimationPhase.pausing;
        break;
      case AnimationPhase.pausing:
        _currentPhase = AnimationPhase.movingForward;
        break;
    }
    _startNextPhase(); // Rozpocznij następną fazę
  }

  Future _updateAnimation() async {
    if (!mounted) return; // Sprawdzenie, czy widget jest nadal w drzewie

    setState(() {
      switch (_currentPhase) {
        case AnimationPhase.movingForward:
        // Przesunięcie podświetlenia do przodu
          _highlightedStripe = (_highlightedStripe! + 1) % 10;
          break;
        case AnimationPhase.movingBackward:
        // Przesunięcie podświetlenia do tyłu
          if (_highlightedStripe! > 0) {
            _highlightedStripe = _highlightedStripe! - 1;
          }
          break;
        case AnimationPhase.blinking:
        // Mryganie: przełączanie podświetlenia
          _highlightedStripe = _blinkCounter % 2 == 0 ? -1 : null;
          _blinkCounter++;
          if (_blinkCounter >= 8) {
            _blinkCounter = 0; // Resetowanie licznika mrygania
          }
          break;
        case AnimationPhase.pausing:
        // Faza pauzy - nie wymaga aktualizacji stanu, ponieważ jest zarządzana przez Timer
          break;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _pauseTimer?.cancel();
    _phaseTimer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // Twoje istniejące ustawienia UI i layout...
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              padding: EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 2.0,
                  color: Color(0xFF5E0EAD),
                ),
                gradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                  colors: [
                    Color(0xFF5E0EAD),
                    Palette().pink,
                  ], // Przykładowe kolory gradientu
                ),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(-4, -4),
                    blurRadius: 10,
                    color: Colors.white.withOpacity(0.25),
                  ),
                  BoxShadow(
                    offset: Offset(4, 4),
                    blurRadius: 10,
                    color: Colors.black.withOpacity(0.7),
                  ),
                ],
              ),
              child: ClipPath(
                clipper: CircleClipper(),
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: Transform.rotate(
        angle: -90 * 3.14 / 180,
        child:
        CustomPaint(
                    painter: StripePainter(
                        numberOfDots: 10,
                  dotRadius: 3,
                        color: Colors.white70,
                         highlightDotRadius: 4,
                         highlightColor: Colors.red,
                         highlightedDot: _highlightedStripe,
                         padding: constraints.maxWidth * 0.138,
                    ),
                  ),
                ),),
              ),
            ),
            Container(
              padding: EdgeInsets.all(15.0),
              child:
              FortuneWheel(
                selected: widget.selected.stream,
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
                  buildFortuneItem('1', Palette().bluegrey),
                  buildFortuneItem('2', Palette().pink),
                  buildFortuneItem('3', Palette().backgroundPlaySession),
                  buildFortuneItem('1', Palette().bluegrey),
                  buildFortuneItem('2', Palette().pink),
                  buildFortuneItem('3', Palette().backgroundPlaySession),
                ],
              ),),
          ],
        );
      },
    );
  }
}


  //kolo fortuny
  FortuneItem buildFortuneItem(String text, Color color) {
    return FortuneItem(
      style: FortuneItemStyle(
        color: color,
        borderColor: Palette().borderSpinningWheel,
        borderWidth: 3,
      ), child: strokedText(text),
    );
  }

  //cieniowany tekst, obramowka kolo fortuny
  Widget strokedText(String text) {
    return Transform.rotate(
      angle: 90 * 3.14 / 180,
      child: Stack(
        children: <Widget>[
          Text(
            text,
            style: TextStyle(
              fontSize: 40,
              fontFamily: 'HindMadurai',
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1
                ..color = Palette().borderSpinningWheel,
            ),
          ),
          // Tekst
          Text(
            text,
            style: TextStyle(
              fontFamily: 'HindMadurai',
              fontSize: 40,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
class StripePainter extends CustomPainter {
  final int numberOfDots;
  final double dotRadius;
  final Color color;
  final double highlightDotRadius;
  final Color highlightColor;
  final int? highlightedDot;
  final double padding;

  StripePainter({
    required this.numberOfDots,
    required this.dotRadius,
    required this.color,
    required this.highlightDotRadius,
    required this.highlightColor,
    this.highlightedDot,
    this.padding = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width / 2 - padding;

    final Paint paint = Paint();

    for (int i = 0; i < numberOfDots; i++) {
      final double angle = (2 * pi / numberOfDots) * i;
      final double dotX = centerX + radius * cos(angle);
      final double dotY = centerY + radius * sin(angle);

      // Jeśli highlightedDot jest null, wszystkie kółeczka powinny być podświetlone
      if (highlightedDot == null) {
        paint.color = highlightColor;
        canvas.drawCircle(
          Offset(dotX, dotY),
          highlightDotRadius,
          paint,
        );
      } else {
        paint.color = i == highlightedDot ? highlightColor : color;
        double currentDotRadius = i == highlightedDot ? highlightDotRadius : dotRadius;
        canvas.drawCircle(
          Offset(dotX, dotY),
          currentDotRadius,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}
