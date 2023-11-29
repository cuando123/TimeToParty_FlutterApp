import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../app_lifecycle/translated_text.dart';
import '../style/palette.dart';
import 'card_screens/svgbutton_enabled_dis.dart';
import 'custom_style_buttons.dart';

class AnimatedAlertDialog {
  //tapnij w kolo by zakrecic
  static void showAnimatedDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations
          .of(context)
          .modalBarrierDismissLabel,
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
      transitionBuilder:
          (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
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

  // czy na pewno chcesz wyjsc

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
                    Size(MediaQuery
                        .of(context)
                        .size
                        .width * 0.5, MediaQuery
                        .of(context)
                        .size
                        .height * 0.05),
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

  // nie mozesz juz pominac karty dialog
  static void showAnimatedDialogNoCards(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations
          .of(context)
          .modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
        return Center(
            child: AlertDialog(
                backgroundColor: Palette().white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: letsText(context, 'Nie możesz już pominąć karty!', 20, Palette().pink,
                    textAlign: TextAlign.center)));
      },
      transitionBuilder:
          (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
        // Jeśli dialog się pojawia
        if (animation.status == AnimationStatus.forward) {
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
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }

  // punkty
  static void showPointsDialog(BuildContext context, List<Color> starsColors, int totalCards) {
    // Obliczenie punktów
    int greenCount = starsColors
        .where((color) => color == Colors.green)
        .length;
    int redCount = starsColors
        .where((color) => color == Colors.red)
        .length;
    int points;
    if (greenCount > totalCards / 2) {
      points = 2;
    } else if (greenCount == totalCards / 2) {
      points = 1;
    } else {
      points = 0;
    }
    // Wyświetlenie alert dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Zdobywasz $points punktów!'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.red),
              Text('$redCount '),
              Icon(Icons.star, color: Colors.green),
              Text('$greenCount'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Zamknięcie dialogu
              },
            ),
          ],
        );
      },
    );
  }

  static void showAnimatedDialogFinishedTask(BuildContext context, VoidCallback onButtonXPressed,
      VoidCallback onButtonTickPressed) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations
          .of(context)
          .modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
        return Center(
          child: AlertDialog(
            backgroundColor: Palette().white, // Upewnij się, że klasa Palette jest dostępna
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: letsText(context, 'Czy zadanie zostało wykonane?', 20, Palette().pink, textAlign: TextAlign.center),
            actions: <Widget>[
              SvgButton(
                assetName: 'assets/time_to_party_assets/cards_screens/button_declined.svg',
                onPressed: () {
                  Navigator.of(context).pop();
                  onButtonXPressed();
                },
              ),
              SvgButton(
                assetName: 'assets/time_to_party_assets/cards_screens/button_approved.svg',
                onPressed: () {
                  Navigator.of(context).pop();
                  onButtonTickPressed();
                },
              ),
            ],
          ),
        );
      },
      transitionBuilder:
          (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
        if (animation.status == AnimationStatus.forward) {
          return ScaleTransition(
            scale: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        }
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  static void showCardDescriptionDialog(BuildContext context, String cardIndex) {
    //TO_DO jezeli ekran karty bedzie to wtedy dodamy do tego dialogu mozliwosc zgloszenia bledu poprzez stronke
    final Map<String, Widget> fieldDescriptions = {
      'field_arrows': translatedText(context, 'instruction_dialog_choice',
          16, Palette().menudark),
      'field_sheet': translatedText(context, 'instruction_dialog_rymes',
          16, Palette().menudark),
      'field_letters': translatedText(context, 'instruction_dialog_20_words',
          16, Palette().menudark),
      'field_pantomime': translatedText(context, 'instruction_dialog_pantomime',
          16, Palette().menudark),
      'field_microphone': translatedText(context, 'instruction_dialog_famous_people',
          16, Palette().menudark),
      'field_taboo': translatedText(context, 'instruction_dialog_stars_fields',
          16, Palette().menudark),
      'field_star_blue_dark': translatedText(context, 'more_fun', //TO_DO to jest do zrobienai tez
          16, Palette().menudark),
      'field_star_pink': translatedText(context, 'more_fun',
          16, Palette().menudark),
      'field_star_green': translatedText(context, 'more_fun',
          16, Palette().menudark),
      'field_star_yellow': translatedText(context, 'more_fun',
          16, Palette().menudark),
    };

    final Map<String, String> fieldTitlesDb = {
      'field_arrows': "ok", //TO_DO do ustawienia w bazie tutaj beda jeszcze nazwy przy tlumaczeniach
      'field_sheet': "rymes",
      'field_letters': "alphabet",
      'field_pantomime': "pantomime",
      'field_microphone': "famous_people",
      'field_taboo': "taboo_words",
      'field_star_blue_dark': "ok",
      'field_star_pink': "ok",
      'field_star_green': "ok",
      'field_star_yellow': "ok"
    };
    String title = fieldTitlesDb[cardIndex] ?? "Default Title";
    Widget? description = fieldDescriptions[cardIndex];

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Palette().white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            content: SingleChildScrollView( // Add SingleChildScrollView to handle overflow
               child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  translatedText(context, title, 20, Palette().pink, textAlign: TextAlign.center),
                  ResponsiveSizing.responsiveHeightGap(context, 10),
                  Center (child: description),
                  ResponsiveSizing.responsiveHeightGap(context, 10),
                  SvgPicture.asset('assets/time_to_party_assets/line_instruction_screen.svg'),
                  ResponsiveSizing.responsiveHeightGap(context, 10),
                  CustomStyledButton(
                    icon: null,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    text: "OK",
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
}
