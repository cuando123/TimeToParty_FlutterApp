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
            Palette().pink,
            Color(0xFF5E0EAD),
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
          _buildButtonIcon(Icons.home_rounded, showExitGameDialogCallback),
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

class InstantTooltip extends StatefulWidget {
  final Widget child;
  final String message;

  InstantTooltip({required this.child, required this.message});

  @override
  _InstantTooltipState createState() => _InstantTooltipState();
}

class _InstantTooltipState extends State<InstantTooltip> {
  OverlayEntry? _overlayEntry;
  final GlobalKey _tooltipKey = GlobalKey();


  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  String formatMessage(String message) {
    final words = message.split(' ');
    final buffer = StringBuffer();
    for (int i = 0; i < words.length; i++) {
      buffer.write(words[i]);
      if ((i + 1) % 4 == 0 && i != words.length - 1) {
        buffer.write('\n');
      } else if (i != words.length - 1) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  void _showTooltip(TapDownDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(details.localPosition);

    var screen = MediaQuery.of(context).size;

    double tooltipWidth = 150;  // dostosowane wartości
    double tooltipHeight = 100;

    var left = offset.dx - tooltipWidth / 2;
    if (left < 0) left = 10;
    if (left + tooltipWidth > screen.width) left = screen.width - tooltipWidth - 10;

    var top = offset.dy - tooltipHeight;
    if (top < 0) top = offset.dy + size.height;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final tooltipRenderBox = _tooltipKey.currentContext?.findRenderObject() as RenderBox?;
        final tooltipWidth = tooltipRenderBox?.size.width ?? 150;

        var left = offset.dx - tooltipWidth / 2;
        const edgeMargin = 25.0; // Dodatkowy margines dla lewej i prawej krawędzi ekranu

        if (left < edgeMargin) left = edgeMargin;
        if (left + tooltipWidth > screen.width - edgeMargin) left = screen.width - tooltipWidth - edgeMargin;

        return Positioned(
        left: left,
        top: top,
        child: Material(
          color: Colors.transparent,
          child: Container(
            key: _tooltipKey,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
              ],
            ),
            child: Text(formatMessage(widget.message),
                style: TextStyle(fontSize: 14, fontFamily: 'HindMadurai'),
            ),
          ),
        ),
      );
      }
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _showTooltip,
      onTapUp: (details) => _hideTooltip(),
      onTapCancel: _hideTooltip,
      child: widget.child,
    );
  }
}

class AnimatedAlertDialog {

  static void showAnimatedDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
        return Center(
          child: AlertDialog(
            backgroundColor: Palette().white, // Upewnij się, że klasa Palette jest dostępna
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: letsText(context, 'Tapnij w koło by zakręcić', 20, Palette().pink, textAlign: TextAlign.center),
          ),
        );
      },
      transitionBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
        if (animation.status == AnimationStatus.forward) {
          // Jeśli dialog się pojawia
          return ScaleTransition(
            scale: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        }
        // Jeśli dialog znika
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );

    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }

  static void showExitGameDialog(BuildContext context, bool hasShownAlertDialog, String response) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Palette().white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: translatedText(context, 'are_you_sure_game_leave', 20, Palette().pink, textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SvgPicture.asset('assets/time_to_party_assets/line_instruction_screen.svg'),
              ),
              ResponsiveSizing.responsiveHeightGap(context, 10),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette().pink,
                    // color
                    foregroundColor: Palette().white,
                    // textColor
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    minimumSize:
                    Size(MediaQuery.of(context).size.width * 0.5, MediaQuery.of(context).size.height * 0.05),
                    textStyle:
                    TextStyle(fontFamily: 'HindMadurai', fontSize: ResponsiveSizing.scaleHeight(context, 20)),
                  ),
                  onPressed: () async {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    hasShownAlertDialog = false;
                  },
                  child: Text('OK'),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(response);
                  },
                  child: translatedText(context, 'cancel', 16, Palette().bluegrey, textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


