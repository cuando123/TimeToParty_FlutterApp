import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:game_template/src/app_lifecycle/responsive_sizing.dart';

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

  const MyFortuneWheel({super.key, required this.selected});

  @override
  _MyFortuneWheelState createState() => _MyFortuneWheelState();
}

enum AnimationPhase { movingForward, movingBackward }

class _MyFortuneWheelState extends State<MyFortuneWheel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int? _highlightedStripe = -1; // Start z -1, aby na początku nic nie było podświetlone
  AnimationPhase _currentPhase = AnimationPhase.movingForward;
  Timer? _phaseTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _startNextPhase();
  }

  void _startNextPhase() {
    _phaseTimer?.cancel();
    var phaseDuration = Duration(seconds: 5); // Czas trwania dla ruchu do przodu i do tyłu
    if (mounted) {
      _controller.forward(from: 0);
    }
    _phaseTimer = Timer.periodic(Duration(milliseconds: 250), (t) {
      _updateAnimation();
    });

    Timer(phaseDuration, () {
      _nextPhase();
    });
  }

  void _nextPhase() {
    _currentPhase =
        (_currentPhase == AnimationPhase.movingForward) ? AnimationPhase.movingBackward : AnimationPhase.movingForward;
    _startNextPhase(); // Rozpocznij następną fazę
  }

  Future _updateAnimation() async {
    if (!mounted) return;
    setState(() {
      if (_currentPhase == AnimationPhase.movingForward) {
        _highlightedStripe = (_highlightedStripe! + 1) % 10;
      } else if (_currentPhase == AnimationPhase.movingBackward) {
        _highlightedStripe = (_highlightedStripe! > 0) ? _highlightedStripe! - 1 : 0;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _phaseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AspectRatio(
          aspectRatio: 1, // Zapewnia kwadratowy kontener
          child: FractionallySizedBox(
            widthFactor: 1,
            heightFactor: 1,
            child: Stack(
              children: [
                Container(
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
                      ],
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
                        child: CustomPaint(
                          painter: StripePainter(
                            numberOfDots: 10,
                            dotRadius: 3,
                            color: Colors.white70,
                            highlightDotRadius: 4,
                            highlightColor: Colors.yellow,
                            highlightedDot: _highlightedStripe,
                            padding: 6, //61.5
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(15.0),
                  child: FortuneWheel(
                    selected: widget.selected.stream,
                    animateFirst: false,
                    duration: Duration(seconds: 3),
                    indicators: <FortuneIndicator>[
                      FortuneIndicator(
                        alignment: Alignment.topCenter,
                        child: Stack(
                          children: [
                            Transform.translate(
                              offset: Offset(0, -10),
                              child: Transform.scale(
                                scaleX: 0.75,
                                scaleY: 0.65,
                                child: TriangleIndicator(
                                  color: Palette().borderSpinningWheel,
                                ),
                              ),
                            ),
                            Transform.translate(
                              offset: Offset(0, -10),
                              child: Transform.scale(
                                scaleX: 0.6,
                                scaleY: 0.5,
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
                      buildFortuneItem(context, '1', Palette().bluegrey),
                      buildFortuneItem(context, '2', Palette().pink),
                      buildFortuneItem(context, '3', Palette().backgroundPlaySession),
                      buildFortuneItem(context, '1', Palette().bluegrey),
                      buildFortuneItem(context, '2', Palette().pink),
                      buildFortuneItem(context, '3', Palette().backgroundPlaySession),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

//kolo fortuny
FortuneItem buildFortuneItem(BuildContext context, String text, Color color) {
  return FortuneItem(
    style: FortuneItemStyle(
      color: color,
      borderColor: Palette().borderSpinningWheel,
      borderWidth: 3,
    ),
    child: strokedText(context, text),
  );
}

//cieniowany tekst, obramowka kolo fortuny
Widget strokedText(BuildContext context, String text) {
  return Transform.rotate(
    angle: 90 * 3.14 / 180,
    child: Stack(
      children: <Widget>[
        Text(
          text,
          style: TextStyle(
            fontSize: ResponsiveSizing.scaleHeight(context, 40),
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
            fontSize: ResponsiveSizing.scaleHeight(context, 40),
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
      if (highlightedDot == 9) {
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
