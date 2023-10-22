import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_svg/svg.dart';
import 'package:game_template/src/play_session/play_gameboard_card.dart';

import '../app_lifecycle/translated_text.dart';
import '../instruction_dialog/instruction_dialog.dart';
import '../style/palette.dart';

class NeumorphicTripleButton extends StatelessWidget {
  final AnimationController _controller;
  final VoidCallback showExitGameDialogCallback;

  NeumorphicTripleButton(this._controller, this.showExitGameDialogCallback);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF5E0EAD),
            Color(0xFF1E1E1F),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color(0xFF5E0EAD),
          width: 2.0,
        ), // Dodaj podwójną białą obwódkę
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            offset: Offset(4, 4),
            blurRadius: 10,
            spreadRadius: -3,
          ),
          BoxShadow(
            color: Colors.deepPurpleAccent.withOpacity(0.7),
            offset: Offset(-6, -4),
            blurRadius: 10,
            spreadRadius: -3,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButtonIcon(Icons.pause, showExitGameDialogCallback),
          _buildButtonIcon(Icons.info_outlined, () {
            Future.delayed(Duration(milliseconds: 150), () {
              showDialog<void>(
                context: context,
                builder: (context) {
                  return InstructionDialog();
                },
              );
            });
          }),
          _buildButtonIcon(Icons.highlight, () {
            _controller.forward(from: 0); // Obsłuż tapnięcie w prawy przycisk
          }),
        ],
      ),
    );
  }

  Widget _buildButtonIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 100,
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }
}

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
                      Color(0xFF1E1E1F),
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
                  buildFortuneItem('1', Palette().pink), //, Palette().white
                  buildFortuneItem('2', Palette().bluegrey),
                  buildFortuneItem('3', Palette().backgroundPlaySession),
                  buildFortuneItem('1', Palette().grey),
                  buildFortuneItem('2', Palette().pink),
                  buildFortuneItem('3', Palette().darkGrey),
                ],
              ),),
             Center(child:
               Icon(
                 Icons.expand_circle_down,
                 color: Colors.white,
                 size: 40.0,
               ),
             )
            ],
          );
        });
  }

  //kolo fortuny
  FortuneItem buildFortuneItem(String text, Color color ) {//Color color1, Color color2
    return FortuneItem(
      style: FortuneItemStyle(
       /* gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),*/
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

class AdditionalWidgets {
  void showTransferDeviceDialog(BuildContext context, String fieldValue,
      String currentTeamName, Color currentTeamColor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Palette().white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: translatedText(
              context, 'pass_the_device_to_the_person', 20, Palette().pink,
              textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SvgPicture.asset(
                    'assets/time_to_party_assets/line_instruction_screen.svg'),
              ),
              ResponsiveSizing.responsiveHeightGap(context, 10),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette().pink,
                    foregroundColor: Palette().white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    minimumSize: Size(MediaQuery.of(context).size.width * 0.5,
                        MediaQuery.of(context).size.height * 0.05),
                    textStyle: TextStyle(
                        fontFamily: 'HindMadurai',
                        fontSize: ResponsiveSizing.scaleHeight(context, 20)),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlayGameboardCard(
                          teamNames: [currentTeamName],
                          teamColors: [currentTeamColor],
                          currentField: [fieldValue],
                        ),
                      ),
                    );
                  },
                  child: translatedText(context, 'done', 20, Palette().white,
                      textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
