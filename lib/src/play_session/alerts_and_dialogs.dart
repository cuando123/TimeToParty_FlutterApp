import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../app_lifecycle/translated_text.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../settings/settings.dart';
import '../style/palette.dart';
import 'card_screens/svgbutton_enabled_dis.dart';
import 'custom_style_buttons.dart';

class AnimatedAlertDialog {
  //tapnij w kolo by zakrecic
  static void showAnimatedDialog(
      BuildContext context, String text, SfxType soundType, int delay, double textHeight, bool showBackground) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (buildContext, animation, secondaryAnimation) {
        Widget dialogContent = AlertDialog(
          backgroundColor: showBackground ? Colors.transparent : Palette().white,
          elevation: 0,
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: translatedText(context, text, textHeight, Palette().pink, textAlign: TextAlign.center),
        );

        if (showBackground) {
          dialogContent = Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset('assets/time_to_party_assets/tlo.svg'), // Załaduj tło
              Transform.rotate(
                angle: -pi / 180 * 5, // Obrót o kilka stopni
                child: dialogContent,
              ),
            ],
          );
        }

        return WillPopScope(
          onWillPop: () async => false, // Zablokowanie możliwości cofnięcia
          child: Center(child: dialogContent),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        if (animation.status == AnimationStatus.forward) {
          final audioController = context.watch<AudioController>();
          audioController.playSfx(soundType);
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

    Future.delayed(Duration(seconds: delay), () {
      Navigator.of(context).pop();
    });
  }

  // czy na pewno chcesz wyjsc

  static void showExitGameDialog(BuildContext context, bool hasShownAlertDialog, String response) {
    showDialog(
      context: context,
      builder: (context) {
        final settings = context.watch<SettingsController>();
        final settingsController = context.watch<SettingsController>();
        return WillPopScope(
          onWillPop: () async => false, // Zablokowanie możliwości cofnięcia
          child:
         AlertDialog(
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
                    final audioController = context.read<AudioController>();
                    audioController.playSfx(SfxType.button_back_exit);
                    Navigator.of(context).popUntil((route) => route.isFirst);

                    if (!settings.musicOn.value) {
                      settingsController.toggleMusicOn();
                    }
                    hasShownAlertDialog = false;
                  },
                  child: Text('OK'),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    final audioController = context.read<AudioController>();
                    audioController.playSfx(SfxType.button_back_exit);
                    Navigator.of(context).pop(response);
                  },
                  child: translatedText(context, 'cancel', 16, Palette().bluegrey, textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ),);
      },
    );
  }

  // punkty
 /* static void showPointsDialog(BuildContext context, List<Color> starsColors, int totalCards) {
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
      builder: (context) {
        return WillPopScope(
            onWillPop: () async => false, // Zablokowanie możliwości cofnięcia
        child:  AlertDialog(
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
                final audioController = context.read<AudioController>();
                audioController.playSfx(SfxType.button_back_exit);
                Navigator.of(context).pop(); // Zamknięcie dialogu
              },
            ),
          ],
        ),);
      },
    );
  }*/
  static void showPointsDialog(BuildContext context, List<Color> starsColors, String currentField) {
    print('Pole: $currentField');
    print('Lista: $starsColors');
    int greenCount = starsColors.where((color) => color == Colors.green).length;
    int redCount = starsColors.where((color) => color == Colors.red).length;
    double multiplier;
    switch (currentField) {
      case 'field_pantomime':
        multiplier = 2.5;
        break;
      case 'field_star_blue_dark':
        multiplier = 5;
        break;
      case 'field_star_green':
        multiplier = 5;
        break;
      case 'field_star_yellow':
        multiplier = 5;
        break;
      case 'field_letters':
        multiplier = 5;
        break;
      default:
        multiplier = 1;
    }

    print('Pole: $currentField, punktow: ${greenCount*multiplier}');
    showGeneralDialog(
      context: context,
      barrierDismissible: false, // Ustawienie na false, jeśli nie chcesz zamykać dialogu przez kliknięcie poza nim
      barrierColor: Colors.transparent, // Usunięcie przyciemnienia
      transitionDuration: Duration(milliseconds: 200),
      pageBuilder: (BuildContext context, Animation animation, Animation secondaryAnimation) {
        return PointsAnimationDialog(greenPoints: greenCount, redPoints: redCount);
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: child,
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
      pageBuilder: (buildContext, animation, secondaryAnimation) {
        return WillPopScope(
            onWillPop: () async => false, // Zablokowanie możliwości cofnięcia
        child:  Center(
          child: AlertDialog(
            backgroundColor: Palette().white, // Upewnij się, że klasa Palette jest dostępna
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title:
                translatedText(context, 'has_the_task_been_completed', 20, Palette().pink, textAlign: TextAlign.center),
            actions: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                SvgButton(
                  assetName: 'assets/time_to_party_assets/cards_screens/button_declined.svg',
                  onPressed: () {
                    final audioController = context.read<AudioController>();
                    audioController.playSfx(SfxType.card_x_sound);
                    Navigator.of(context).pop();
                    onButtonXPressed();
                  },
                ),
                SvgButton(
                  assetName: 'assets/time_to_party_assets/cards_screens/button_approved.svg',
                  onPressed: () {
                    final audioController = context.read<AudioController>();
                    audioController.playSfx(SfxType.card_tick_sound);
                    Navigator.of(context).pop();
                    onButtonTickPressed();
                  },
                ),
              ],

             ),
            ],
          ),
        ),);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
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

  static Future<void> showCardDescriptionDialog(BuildContext context, String cardIndex, AlertOrigin origin) async {
    final audioController = context.read<AudioController>();
    audioController.playSfx(SfxType.button_infos);
    final Map<String, Widget> fieldDescriptions = {
      'field_arrows':
          translatedText(context, 'instruction_dialog_choice', 16, Palette().menudark, textAlign: TextAlign.center),
      'field_sheet': translatedText(
          context,
          'instruction_dialog_rymes', //TO_DO to jest do pomyslenia jak to przetlumaczyc
          16,
          Palette().menudark,
          textAlign: TextAlign.center),
      'field_letters':
          translatedText(context, 'instruction_dialog_20_words', 16, Palette().menudark, textAlign: TextAlign.center),
      'field_pantomime':
          translatedText(context, 'instruction_dialog_pantomime', 16, Palette().menudark, textAlign: TextAlign.center),
      'field_microphone': translatedText(context, 'instruction_dialog_famous_people', 16, Palette().menudark,
          textAlign: TextAlign.center),
      'field_taboo': translatedText(context, 'instruction_dialog_taboo_fields', 16, Palette().menudark,
          textAlign: TextAlign.center),
      'field_star_blue_dark': translatedText(context, 'instruction_dialog_physical_challenge', 16, Palette().menudark,
          textAlign: TextAlign.center),
      'field_star_pink': translatedText(context, 'instruction_dialog_synonimes_antonimes', 16, Palette().menudark,
          textAlign: TextAlign.center),
      'field_star_green':
          translatedText(context, 'instruction_dialog_drawing', 16, Palette().menudark, textAlign: TextAlign.center),
      'field_star_yellow': translatedText(context, 'instruction_dialog_compare_questions', 16, Palette().menudark,
          textAlign: TextAlign.center),
    };

    final Map<String, String> fieldTitlesDb = {
      'field_arrows': "choose_card",
      'field_sheet': "rymes",
      'field_letters': "alphabet",
      'field_pantomime': "pantomime",
      'field_microphone': "famous_people",
      'field_taboo': "taboo_words",
      'field_star_blue_dark': "physical_challenge",
      'field_star_pink': "synonimes_antonimes",
      'field_star_green': "drawing",
      'field_star_yellow': "compare_questions"
    };
    String title = fieldTitlesDb[cardIndex] ?? "Default Title";
    Widget? description = fieldDescriptions[cardIndex];

    return showDialog<void>(
        context: context,
        builder: (context) {
          return WillPopScope(
              onWillPop: () async => false, // Zablokowanie możliwości cofnięcia
          child:  AlertDialog(
            backgroundColor: Palette().white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            content: SingleChildScrollView(
              // Add SingleChildScrollView to handle overflow
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  translatedText(context, title, 20, Palette().pink, textAlign: TextAlign.center),
                  ResponsiveSizing.responsiveHeightGap(context, 10),
                  Center(child: description),
                  ResponsiveSizing.responsiveHeightGap(context, 10),
                  SvgPicture.asset('assets/time_to_party_assets/line_instruction_screen.svg'),
                  ResponsiveSizing.responsiveHeightGap(context, 10),
                  CustomStyledButton(
                    icon: null,
                    onPressed: () {
                      final audioController = context.read<AudioController>();
                      audioController.playSfx(SfxType.button_back_exit);
                      Navigator.of(context).pop();
                    },
                    text: "OK",
                  ),
                  if (origin == AlertOrigin.otherScreen) ...[Container()],
                  if (origin == AlertOrigin.cardScreen) ...[
                    ResponsiveSizing.responsiveHeightGap(context, 10),
                    translatedText(context, 'found_a_mistake_report_it', 12, Palette().darkGrey,
                        textAlign: TextAlign.center),
                    CustomStyledButton(
                      icon: Icons.edit,
                      onPressed: () {
                        Navigator.of(context).pop();
                        showExitDialog(context);
                      },
                      text: getTranslatedString(context, 'report_a_bug'),
                    ),
                  ],
                ],
              ),
            ),
          ),);
        });
  }

  static void showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
            onWillPop: () async => false, // Zablokowanie możliwości cofnięcia
        child: AlertDialog(
          backgroundColor: Palette().white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: translatedText(context, 'would_you_like_exit', 20, Palette().pink, textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SvgPicture.asset('assets/time_to_party_assets/line_instruction_screen.svg'),
              ),
              ResponsiveSizing.responsiveHeightGap(context, 10),
              translatedText(context, 'redirected_to_the_website', 16, Palette().menudark, textAlign: TextAlign.center),
              ResponsiveSizing.responsiveHeightGap(context, 10),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette().pink, // color
                    foregroundColor: Palette().white, // textColor
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    minimumSize:
                        Size(MediaQuery.of(context).size.width * 0.5, MediaQuery.of(context).size.height * 0.05),
                    textStyle:
                        TextStyle(fontFamily: 'HindMadurai', fontSize: ResponsiveSizing.scaleHeight(context, 20)),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    String url = 'https://frydoapps.com/contact-apps';
                    if (await canLaunchUrlString(url)) {
                      await launchUrlString(url, mode: LaunchMode.externalApplication);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  child: Text('OK'),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: translatedText(context, 'cancel', 16, Palette().bluegrey, textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ),);
      },
    );
  }

  static void passTheDeviceNextPersonDialog(BuildContext context, String imageName, String text) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (buildContext, animation, secondaryAnimation) {
        return WillPopScope(
            onWillPop: () async => false, // Zablokowanie możliwości cofnięcia
        child:  Center(
          child: AlertDialog(
            backgroundColor: Palette().white, // Upewnij się, że klasa Palette jest dostępna
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: translatedText(context, text, 20, Palette().pink, textAlign: TextAlign.center),
            actions: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                child: Center(
                    child: Column(
                  children: [
                    Image.asset('assets/time_to_party_assets/activities/$imageName.png', height: 120),
                    SizedBox(height: 20),
                    CustomStyledButton(
                      icon: Icons.arrow_forward,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      text: getTranslatedString(context, 'done'),
                    ),
                  ],
                )),
              ),
            ],
          ),
        ),);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
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

  static void showResultDialog(
      BuildContext context, bool isMatch, String? selectedTextPerson1, String? selectedTextPerson2) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (buildContext, animation, secondaryAnimation) {
        List<Widget> dialogContent = [];
        List<Color> starsColors;
        if (isMatch) {
          starsColors = List.generate(2, (index) => index == 0 ? Colors.green : Colors.red);
          dialogContent.add(translatedText(context, 'compare_questions_result_ok', 20, Palette().pink,
              textAlign: TextAlign.center));
          dialogContent.add(SizedBox(height: 20));
          dialogContent.add(Center(
            child: Text('${getTranslatedString(context, 'answer')}: ${selectedTextPerson1}',
                style: TextStyle(
                    color: Palette().bluegrey, fontWeight: FontWeight.normal, fontFamily: 'HindMadurai', fontSize: 16),
                textAlign: TextAlign.center),
          ));
        } else {
          starsColors = List.generate(2, (index) => index == 0 ? Colors.red : Colors.grey);
          dialogContent.add(translatedText(context, 'compare_questions_result_nok', 20, Palette().pink,
              textAlign: TextAlign.center));
          dialogContent.add(SizedBox(height: 20));
          dialogContent.add(
            Column(
              children: [
                Image.asset('assets/time_to_party_assets/activities/man.png', height: 120),
                SizedBox(height: 10),
                Text(
                  '${getTranslatedString(context, 'answer')} 1: ${selectedTextPerson1}',
                  style: TextStyle(
                    color: Palette().bluegrey,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'HindMadurai',
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          );
          dialogContent.add(SizedBox(height: 20));
          dialogContent.add(
            Column(
              children: [
                Image.asset('assets/time_to_party_assets/activities/woman.png', height: 120),
                SizedBox(height: 10),
                Text('${getTranslatedString(context, 'answer')} 2: ${selectedTextPerson2}',
                    style: TextStyle(
                        color: Palette().bluegrey,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'HindMadurai',
                        fontSize: 16),
                    textAlign: TextAlign.center)
              ],
            ),
          );
        }
        return WillPopScope(
            onWillPop: () async => false, // Zablokowanie możliwości cofnięcia
        child:  Center(
          child: AlertDialog(
            backgroundColor: Palette().white, // Upewnij się, że klasa Palette jest dostępna
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            content: SingleChildScrollView(
              child: ListBody(children: dialogContent),
            ),
            actions: <Widget>[
               Center(
                  child: CustomStyledButton(
                    icon: Icons.arrow_forward,
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop('response');
                     AnimatedAlertDialog.showPointsDialog(context, starsColors, 'field_star_yellow');
                    },
                    text: getTranslatedString(context, 'done'),
                  ),
                ),
            ],
          ),
        ),);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
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
}

enum AlertOrigin { cardScreen, otherScreen }

class PointsAnimationDialog extends StatefulWidget {
  final int greenPoints;
  final int redPoints;

  PointsAnimationDialog({required this.greenPoints, required this.redPoints});

  @override
  _PointsAnimationDialogState createState() => _PointsAnimationDialogState();
}

class _PointsAnimationDialogState extends State<PointsAnimationDialog>
    with TickerProviderStateMixin {
  late AnimationController _greenStarController;
  late AnimationController _redStarController;
  late Animation<double> _greenStarScale;
  late Animation<double> _redStarScale;
  int _currentGreenPoints = 0;
  int _currentRedPoints = 0;

  @override
  void initState() {
    super.initState();

    _greenStarController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _redStarController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Scale animation for stars
    _greenStarScale = Tween<double>(begin: 1.0, end: 1.2)
        .animate(CurvedAnimation(parent: _greenStarController, curve: Curves.elasticOut))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _greenStarController.reverse();
        }
      });
    _redStarScale = Tween<double>(begin: 1.0, end: 1.2)
        .animate(CurvedAnimation(parent: _redStarController, curve: Curves.elasticOut))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _redStarController.reverse();
        }
      });

    _startAnimations();
  }

  void _startAnimations() async {
    // Scale up the stars for both colors at the beginning
    _greenStarController.forward();
    _redStarController.forward();

    for (var i = 0; i < widget.greenPoints; i++) {
      await Future.delayed(Duration(milliseconds: 200));
      setState(() {
        _currentGreenPoints++;
      });
      // Trigger scale animation each time the point increases
      _greenStarController.forward(from: 0);
    }

    for (var i = 0; i < widget.redPoints; i++) {
      await Future.delayed(Duration(milliseconds: 200));
      setState(() {
        _currentRedPoints++;
      });
      // Trigger scale animation each time the point increases
      _redStarController.forward(from: 0);
    }

    await Future.delayed(Duration(seconds: 2));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: FittedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _greenStarScale,
              child: _StarPoints(
                color: Colors.green,
                points: _currentGreenPoints,
              ),
            ),
            SizedBox(width: 16), // Space between the stars
            ScaleTransition(
              scale: _redStarScale,
              child: _StarPoints(
                color: Colors.red,
                points: _currentRedPoints,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _greenStarController.dispose();
    _redStarController.dispose();
    super.dispose();
  }
}

class _StarPoints extends StatelessWidget {
  final Color color;
  final int points;

  const _StarPoints({Key? key, required this.color, required this.points}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // Dodaj padding, aby zrobić miejsce na obramówkę
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        // Dodaj obramówkę
        shape: BoxShape.circle, // Kształt obramówki jako koło
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: IconTheme(
          data: IconThemeData(
            size: 24, // Dostosuj rozmiar gwiazdki
            color: color, // Kolor gwiazdki
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.star), // Używamy ikony gwiazdki
              Text(
                '$points',
                style: TextStyle(
                  fontSize: 12, // Dostosuj rozmiar tekstu dla czytelności
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

