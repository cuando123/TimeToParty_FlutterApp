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

class MyFortuneWheel extends StatelessWidget {
  final StreamController<int> selected;

  MyFortuneWheel({required this.selected});

  @override
  Widget build(BuildContext context) {
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
                      child: CustomPaint(
                        painter: StripePainter(
                          numberOfStripes: 20,
                          thickness: 100,
                          color: Colors.white70,
                          padding: constraints.maxWidth * 0.12,
                        ),
                      ),
                    ),
                  )

              ),
              Container(
                padding: EdgeInsets.all(15.0),
                child:
                FortuneWheel(
                  selected: selected.stream,
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
        });
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
}

class StripePainter extends CustomPainter {
  final int numberOfStripes;
  final double thickness;
  final Color color;
  final double padding;

  StripePainter({
    required this.numberOfStripes,
    required this.thickness,
    required this.color,
    this.padding = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double outerRadius = size.width / 2 - padding;
    final double innerRadius = outerRadius - thickness;

    final Paint paint = Paint()..color = color;

    for (int i = 0; i < numberOfStripes; i++) {
      final double angle = (2 * pi / numberOfStripes) * i;
      final double startX = centerX + innerRadius * cos(angle);
      final double startY = centerY + innerRadius * sin(angle);
      final double endX = centerX + outerRadius * cos(angle);
      final double endY = centerY + outerRadius * sin(angle);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
