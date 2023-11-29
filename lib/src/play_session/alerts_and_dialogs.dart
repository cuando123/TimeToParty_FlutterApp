import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../app_lifecycle/translated_text.dart';
import '../style/palette.dart';
import 'card_screens/svgbutton_enabled_dis.dart';

class AnimatedAlertDialog {
  //tapnij w kolo by zakrecic
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

  // nie mozesz juz pominac karty dialog
  static void showAnimatedDialogNoCards(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
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
    int greenCount = starsColors.where((color) => color == Colors.green).length;
    int redCount = starsColors.where((color) => color == Colors.red).length;
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

  static void showAnimatedDialogFinishedTask(
      BuildContext context, VoidCallback onButtonXPressed, VoidCallback onButtonTickPressed) {
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
    final Map<String, String> fieldDescriptions = {
      'field_arrows': 'Wybierz kartę i zaskocz wszystkich!',
      'field_sheet': 'Układaj rymy i baw się słowami!',
      'field_letters': 'Wymyśl 20 rzeczowników na daną literę!',
      'field_pantomime': 'Mów ciałem, nie słowami!',
      'field_microphone': 'Odgadnij sławne osobowości!',
      'field_taboo': 'Taboo - Opisuj, omijając zakazane słowa!',
      'field_star_blue_dark': 'Zadanie fizyczne? Zmierz się z czasem!',
      'field_star_pink': 'Baw się językiem! Twórz antonimy i synonimy.',
      'field_star_green': 'Ty rysujesz, oni zgadują. Gotowi?',
      'field_star_yellow': 'Porównaj, analizuj, odpowiadaj!',
    };

    // Wybierz tytuł i opis na podstawie cardIndex
    String title = "Tytuł karty"; // Możesz to zmienić na bardziej odpowiedni tytuł
    String description = fieldDescriptions[cardIndex] ?? 'Brak opisu';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Palette().white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: translatedText(context, title, 20, Palette().pink, textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SvgPicture.asset('assets/time_to_party_assets/line_instruction_screen.svg'),
              ),
              ResponsiveSizing.responsiveHeightGap(context, 10),
              Center(
                child: Text(description, textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
              ),
              // ... reszta Twojego UI
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Zamknięcie AlertDialog
              },
            ),
          ],
        );
      },
    );
  }


}
