import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_svg/svg.dart';
import 'package:game_template/src/play_session/play_gameboard_card.dart';

import '../app_lifecycle/translated_text.dart';
import '../style/palette.dart';

class MyFortuneWheel extends StatelessWidget {
  final StreamController<int> selected;

  MyFortuneWheel({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(0.0), // dodaj odpowiednią wartość paddingu
    decoration: BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(
    color: Colors.black, // ustaw odpowiedni kolor
    width: 15.0, // ustaw odpowiednią grubość ramki
    ),
    ), child:
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
        buildFortuneItem('1', Palette().pink),
        buildFortuneItem('2', Palette().bluegrey),
        buildFortuneItem('3', Palette().backgroundPlaySession),
        buildFortuneItem('1', Palette().grey),
        buildFortuneItem('2', Palette().pink),
        buildFortuneItem('3', Palette().darkGrey),
      ],
    ),);
  }

  //kolo fortuny
  FortuneItem buildFortuneItem(String text, Color color) {
    return FortuneItem(
      child: strokedText(text),
      style: FortuneItemStyle(
        color: color,
        borderColor: Palette().borderSpinningWheel,
        borderWidth: 3,
      ),
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
              fontFamily: 'Adamina',
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3
                ..color = Palette().borderSpinningWheel,
            ),
          ),
          // Tekst
          Text(
            text,
            style: TextStyle(
              fontSize: 40,
              fontFamily: 'Adamina',
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
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
