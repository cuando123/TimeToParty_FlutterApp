import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:vibration/vibration.dart';

import '../app_lifecycle/responsive_sizing.dart';
import '../app_lifecycle/translated_text.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../games_services/score.dart';
import '../settings/settings.dart';
import '../style/palette.dart';
import '../win_game/win_game_screen.dart';
import 'card_screens/svgbutton_enabled_dis.dart';
import 'custom_style_buttons.dart';

class AnimatedAlertDialog {
  //tapnij w kolo by zakrecic
  static void showAnimatedDialog(BuildContext context, String text, SfxType soundType, int delay, double textHeight,
      bool showBackground, bool useShadows, bool useSounds) {
    final settingsController = Provider.of<SettingsController>(context, listen: false);

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
          title: translatedText(context, text, textHeight, Palette().pink,
              textAlign: TextAlign.center, useShadows: useShadows),
        );

        if (showBackground) {
          dialogContent = Stack(
            alignment: Alignment.center,
            children: [
              Image.asset('assets/time_to_party_assets/tlo.png'), // Załaduj tło
              Transform.rotate(
                angle: -pi / 180 * 5, // Obrót o kilka stopni
                child: dialogContent,
              ),
            ],
          );
          Future.delayed(Duration(milliseconds: 200), () {
            if (settingsController.vibrationsEnabled.value) {
              Vibration.vibrate(
                pattern: [0, 400],
                intensities: [0, 255],
              );
            }
          });
        }
        return WillPopScope(
          onWillPop: () async => false,
          child: Center(child: dialogContent),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        if (animation.status == AnimationStatus.forward) {
          if (useSounds) {
            final audioController = context.watch<AudioController>();
            audioController.playSfx(soundType);
          }
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
      if (!showBackground) {
        if (settingsController.vibrationsEnabled.value) {
          Vibration.vibrate(
            pattern: [0, 100, 100, 100], // [startDelay, vibrate, pause, vibrate]
            intensities: [0, 255, 0, 255], // Opcjonalnie, intensywności dla każdej części wzoru
          );
        }
      }
    });
    Future.delayed(Duration(seconds: delay), () {
      Navigator.of(context).pop();
    });
  }

  // czy na pewno chcesz wyjsc - przycisk wstecz i cofniecie w kazdym miejscu gry
  static void showExitGameDialog(BuildContext context, bool hasShownAlertDialog, String response,
      List<String> teamNames, List<Color> teamColors, bool isPurchasePurpose) {
    showDialog(
      context: context,
      builder: (context) {
        final settings = context.watch<SettingsController>();
        final settingsController = context.watch<SettingsController>();
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
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
                  child: Image.asset('assets/time_to_party_assets/line_instruction_screen.png'),
                ),
                ResponsiveSizing.responsiveHeightGap(context, 10),
                Center(
                  child: CustomStyledButton(
                    icon: null,
                    text: 'OK',
                    onPressed: () async {
                      if (!settings.musicOn.value) {
                        settingsController.toggleMusicOn();
                      }
                      hasShownAlertDialog = false;
                      if (isPurchasePurpose == false) {
                        final audioController = context.read<AudioController>();
                        audioController.playSfx(SfxType.buttonBackExit);
                        await Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => WinGameScreen(
                            teamNames: teamNames,
                            teamColors: teamColors,
                          ),
                        ));
                      } else {
                        await GoRouter.of(context).push('/card_advertisement');
                      }
                    },
                    backgroundColor: Palette().pink,
                    foregroundColor: Palette().white,
                    width: 200,
                    height: 45,
                    fontSize: ResponsiveSizing.scaleHeight(context, 20),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () {
                      final audioController = context.read<AudioController>();
                      audioController.playSfx(SfxType.buttonBackExit);
                      Navigator.of(context).pop(response);
                    },
                    child: translatedText(context, 'cancel', 16, Palette().bluegrey, textAlign: TextAlign.center),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

//animacja naliczania punktow - dialog
  static void showPointsDialog(BuildContext context, List<Color> starsColors, String currentField,
      List<String> teamNames, List<Color> teamColors) {
    int greenCount = starsColors.where((color) => color == Colors.green).length;
    int redCount = starsColors.where((color) => color == Colors.red).length;
    double multiplier;
    switch (currentField) {
      case 'field_pantomime':
        multiplier = 2.5;
        break;
      case 'field_star_blue_dark':
      case 'field_star_green':
      case 'field_star_yellow':
      case 'field_letters':
        multiplier = 5;
        break;
      default:
        multiplier = 1;
    }
    double points = greenCount * multiplier;
    double redPoints = redCount * multiplier;
    int greenPointsRounded = points.floor().toInt();
    int redPointsRounded = redPoints.floor().toInt();
    TeamScore.updateForNextRound(teamNames[0], teamColors[0], points);

    int currentRound = TeamScore.getRoundNumber(teamNames[0], teamColors[0]);
    double totalScore = TeamScore.getTeamScore(teamNames[0], teamColors[0]).getTotalScore();
    //print('Round: ${currentRound - 1}, Total Score for ${teamNames[0]}: $totalScore');

    showGeneralDialog(
      context: context,
      barrierDismissible: false, // Ustawienie na false, jeśli nie chcesz zamykać dialogu przez kliknięcie poza nim
      barrierColor: Colors.transparent, // Usunięcie przyciemnienia
      transitionDuration: Duration(milliseconds: 200),
      pageBuilder: (BuildContext context, Animation animation, Animation secondaryAnimation) {
        return PointsAnimationDialog(greenPoints: greenPointsRounded, redPoints: redPointsRounded);
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: child,
        );
      },
    );
  }

//czy zadanie zostalo ukonczone?
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
          child: Center(
            child: AlertDialog(
              backgroundColor: Palette().white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: translatedText(context, 'has_the_task_been_completed', 20, Palette().pink,
                  textAlign: TextAlign.center),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgButton(
                      assetName: 'assets/time_to_party_assets/cards_screens/button_declined.png',
                      onPressed: () {
                        final audioController = context.read<AudioController>();
                        audioController.playSfx(SfxType.card_x_sound);
                        Navigator.of(context).pop();
                        onButtonXPressed();
                      },
                    ),
                    SvgButton(
                      assetName: 'assets/time_to_party_assets/cards_screens/button_approved.png',
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
          ),
        );
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

//opis karty + zglos blad
  static Future<void> showCardDescriptionDialog(BuildContext context, String cardIndex, AlertOrigin origin) async {
    final audioController = context.read<AudioController>();
    audioController.playSfx(SfxType.button_infos);
    final Map<String, Widget> fieldDescriptions = {
      'field_arrows':
          translatedText(context, 'instruction_dialog_choice', 16, Palette().menudark, textAlign: TextAlign.center),
      'field_sheet':
          translatedText(context, 'instruction_dialog_rymes', 16, Palette().menudark, textAlign: TextAlign.center),
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
      'field_star_pink': "antonimes",
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
            child: AlertDialog(
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
                    Image.asset('assets/time_to_party_assets/line_instruction_screen.png'),
                    ResponsiveSizing.responsiveHeightGap(context, 10),
                    CustomStyledButton(
                      icon: null,
                      onPressed: () {
                        final audioController = context.read<AudioController>();
                        audioController.playSfx(SfxType.buttonBackExit);
                        Navigator.of(context).pop();
                      },
                      text: "OK",
                      backgroundColor: Palette().pink,
                      foregroundColor: Palette().white,
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
                        backgroundColor: Palette().pink,
                        foregroundColor: Palette().white,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        });
  }

//czy chcesz opuscic gre? zostaniesz przekierowany do strony
  static void showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final audioController = context.watch<AudioController>();
        return WillPopScope(
          onWillPop: () async => false,
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
                  child: Image.asset('assets/time_to_party_assets/line_instruction_screen.png'),
                ),
                ResponsiveSizing.responsiveHeightGap(context, 10),
                translatedText(context, 'redirected_to_the_website', 16, Palette().menudark,
                    textAlign: TextAlign.center),
                ResponsiveSizing.responsiveHeightGap(context, 10),
                Center(
                  child: CustomStyledButton(
                    icon: null,
                    text: 'OK',
                    onPressed: () async {
                      audioController.playSfx(SfxType.buttonBackExit);
                      Navigator.pop(context);
                      String url = 'https://frydoapps.com/contact-apps';
                      if (await canLaunchUrlString(url)) {
                        await launchUrlString(url, mode: LaunchMode.externalApplication);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    backgroundColor: Palette().pink,
                    foregroundColor: Palette().white,
                    width: 200,
                    height: 45,
                    fontSize: ResponsiveSizing.scaleHeight(context, 20),
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
          ),
        );
      },
    );
  }

//przekaz urzadzenie kolejnej osobie yellow card
  static void passTheDeviceNextPersonDialog(BuildContext context, String imageName, String text) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (buildContext, animation, secondaryAnimation) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: AlertDialog(
              backgroundColor: Palette().white,
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
                        backgroundColor: Palette().pink,
                        foregroundColor: Palette().white,
                      ),
                    ],
                  )),
                ),
              ],
            ),
          ),
        );
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

//myslicie tak samo lub nie myslicie tak samo - yellow star card
  static void showResultDialog(BuildContext context, bool isMatch, String? selectedTextPerson1,
      String? selectedTextPerson2, List<String> teamNames, List<Color> teamColors) {
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
          starsColors = List.generate(2, (index) => index == 0 ? Colors.green : Colors.grey);
          dialogContent.add(
              translatedText(context, 'compare_questions_result_ok', 20, Palette().pink, textAlign: TextAlign.center));
          dialogContent.add(SizedBox(height: 20));
          dialogContent.add(Center(
            child: Text('${getTranslatedString(context, 'answer')}: $selectedTextPerson1',
                style: TextStyle(
                    color: Palette().bluegrey, fontWeight: FontWeight.normal, fontFamily: 'HindMadurai', fontSize: 16),
                textAlign: TextAlign.center),
          ));
        } else {
          starsColors = List.generate(2, (index) => index == 0 ? Colors.red : Colors.grey);
          dialogContent.add(
              translatedText(context, 'compare_questions_result_nok', 20, Palette().pink, textAlign: TextAlign.center));
          dialogContent.add(SizedBox(height: 20));
          dialogContent.add(
            Column(
              children: [
                Image.asset('assets/time_to_party_assets/activities/man.png', height: 120),
                SizedBox(height: 10),
                Text(
                  '${getTranslatedString(context, 'answer')} 1: $selectedTextPerson1',
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
                Text('${getTranslatedString(context, 'answer')} 2: $selectedTextPerson2',
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
          onWillPop: () async => false,
          child: Center(
            child: AlertDialog(
              backgroundColor: Palette().white,
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
                      AnimatedAlertDialog.showPointsDialog(
                          context, starsColors, 'field_star_yellow', teamNames, teamColors);
                    },
                    text: getTranslatedString(context, 'done'),
                    backgroundColor: Palette().pink,
                    foregroundColor: Palette().white,
                  ),
                ),
              ],
            ),
          ),
        );
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

//ocen w google play
  static void showRateDialog(BuildContext context) {
    final audioController = context.read<AudioController>();
    final InAppReview inAppReview = InAppReview.instance;
    double userRating = 5;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Palette().white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: translatedText(context, 'your_opinion_matters', 20, Palette().pink, textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset('assets/time_to_party_assets/line_instruction_screen.png'),
              ),
              //Text('Jak podoba Ci się nasza aplikacja?'),
              ResponsiveSizing.responsiveHeightGap(context, 10),
              translatedText(context, 'rate_this_app', 16, Palette().menudark, textAlign: TextAlign.center),
              // textAlign: TextAlign.center,
              ResponsiveSizing.responsiveHeightGap(context, 10),
              Center(
                child: RatingBar.builder(itemSize: ResponsiveSizing.scaleWidth(context, 30),
                  initialRating: 5,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (rating) {
                    userRating = rating; // Aktualizacja oceny użytkownika
                  },
                ),
              ),
            ],
          ),
          actions: <Widget>[
            Center(
              child: CustomStyledButton(
                icon: null,
                text: getTranslatedString(context, 'rate_us_google_play'),
                onPressed: () async {
                  audioController.playSfx(SfxType.buttonBackExit);
                  if (userRating >= 4) {
                    // Użytkownik dał wysoką ocenę, zachęć do oficjalnej recenzji
                    if (await inAppReview.isAvailable()) {
                      await inAppReview.requestReview();
                    }
                  } else {
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: Palette().white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          title: letsText(
                              context,
                              "${getTranslatedString(context, "your_opinion_we_noticed_that")} $userRating ${getTranslatedString(context, "your_opinion_stars")}",
                              18,
                              Palette().pink,
                              textAlign: TextAlign.center),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Image.asset('assets/time_to_party_assets/line_instruction_screen.png'),
                              ),
                              ResponsiveSizing.responsiveHeightGap(context, 10),
                              translatedText(context, "your_opinion_matters_description", 16, Palette().menudark,
                                  textAlign: TextAlign.center),
                              // textAlign: TextAlign.center,
                            ],
                          ),
                          actions: <Widget>[
                            Center(
                              child: CustomStyledButton(
                                icon: null,
                                text: "OK",
                                onPressed: () async {
                                  String url = 'https://frydoapps.com/contact-apps';
                                  if (await canLaunchUrlString(url)) {
                                    await launchUrlString(url, mode: LaunchMode.externalApplication);
                                  } else {
                                    print('Could not launch $url');
                                  }
                                },
                                backgroundColor: Palette().pink,
                                foregroundColor: Palette().white,
                              ),
                            ),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  audioController.playSfx(SfxType.buttonBackExit);
                                  Navigator.of(context).pop();
                                },
                                child: translatedText(context, 'cancel', 16, Palette().bluegrey),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
                  Navigator.of(context).pop();
                },
                backgroundColor: Palette().pink,
                foregroundColor: Palette().white,
                width: 200,
                height: 45,
                fontSize: ResponsiveSizing.scaleHeight(context, 16),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  audioController.playSfx(SfxType.buttonBackExit);
                  Navigator.of(context).pop();
                },
                child: translatedText(context, 'cancel', 16, Palette().bluegrey),
              ),
            ),
          ],
        );
      },
    );
  }

  //pionek na mecie - czy chcesz kontynuowac?
  static void showEndGameDialog(
      BuildContext context, int currentTeamIndex, List<String> teamNames, List<Color> teamColors, Function callback) {
    final audioController = context.read<AudioController>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Palette().white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset('assets/time_to_party_assets/trophy_cup.png', height: ResponsiveSizing.scaleHeight(context, 50)),
              translatedText(context, 'congratulations', 20, Palette().pink, textAlign: TextAlign.center),
              Image.asset('assets/time_to_party_assets/trophy_cup.png', height: ResponsiveSizing.scaleHeight(context, 50)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              letsText(
                  context,
                  '${getTranslatedString(context, 'x_teams')}: \'${teamNames[currentTeamIndex]}\' ${getTranslatedString(context, 'already_reached_the_finish_line')}',
                  20,
                  Palette().pink,
                  textAlign: TextAlign.center),
              Center(
                child: Image.asset('assets/time_to_party_assets/finish_flag.png', height: ResponsiveSizing.scaleHeight(context, 50)),
              ),
              ResponsiveSizing.responsiveHeightGap(context, 10),
              letsText(context, getTranslatedString(context, 'do_you_want_cancel_turn'), 16, Palette().menudark,
                  textAlign: TextAlign.center),
              ResponsiveSizing.responsiveHeightGap(context, 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomStyledButton(
                    icon: null,
                    text: getTranslatedString(context, 'yes_confirm'),
                    onPressed: () {
                      audioController.playSfx(SfxType.buttonBackExit);
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => WinGameScreen(
                          teamNames: teamNames,
                          teamColors: teamColors,
                        ),
                      ));
                    },
                    backgroundColor: Palette().pink,
                    foregroundColor: Palette().white,
                    width: 100,
                    height: 45,
                    fontSize: ResponsiveSizing.scaleHeight(context, 16),
                  ),
                  CustomStyledButton(
                    icon: null,
                    text: getTranslatedString(context, 'no_rejection'),
                    onPressed: () {
                      audioController.playSfx(SfxType.buttonBackExit);
                      callback();
                      Navigator.of(context).pop();
                    },
                    backgroundColor: Palette().pink,
                    foregroundColor: Palette().white,
                    width: 100,
                    height: 45,
                    fontSize: ResponsiveSizing.scaleHeight(context, 16),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  //dziekujemy za zakup full wersji i inne error dialogi podczas zakupow
  static void showPurchaseDialogs(BuildContext context, String billingResponse) {
    if (billingResponse == "PurchaseStatus.canceled") {
      billingResponse = "BillingResponse.userCancelled";
    }
    final Widget defaultTitle = translatedText(context, 'billing_response_developer_error', 16, Palette().menudark,
        textAlign: TextAlign.center);
    final Widget defaultDescription =
        translatedText(context, 'billing_response_error', 16, Palette().menudark, textAlign: TextAlign.center);
    final Map<String, Widget> billingResponseTitles = {
      'PurchaseSuccess':
          translatedText(context, 'purchase_success', 16, Palette().menudark, textAlign: TextAlign.center),
      'PurchaseRestored':
          translatedText(context, 'purchase_restored', 16, Palette().menudark, textAlign: TextAlign.center),
      'BillingResponse.itemAlreadyOwned': translatedText(
          context, 'billing_response_item_already_owned', 16, Palette().menudark,
          textAlign: TextAlign.center),
      'BillingResponse.serviceUnavailable': translatedText(
          context, 'billing_response_service_unavailable', 16, Palette().menudark,
          textAlign: TextAlign.center),
      'BillingResponse.billingUnavailable': translatedText(
          context, 'billing_response_billing_unavailable', 16, Palette().menudark,
          textAlign: TextAlign.center),
      'BillingResponse.itemUnavailable': translatedText(
          context, 'billing_response_item_unavailable', 16, Palette().menudark,
          textAlign: TextAlign.center),
      'BillingResponse.developerError': translatedText(
          context, 'billing_response_developer_error', 16, Palette().menudark,
          textAlign: TextAlign.center),
      'BillingResponse.error':
          translatedText(context, 'billing_response_error', 16, Palette().menudark, textAlign: TextAlign.center),
      'BillingResponse.itemNotOwned': translatedText(context, 'billing_response_item_not_owned', 16, Palette().menudark,
          textAlign: TextAlign.center),
      'BillingResponse.userCancelled': translatedText(
          context, 'billing_response_user_cancelled', 16, Palette().menudark,
          textAlign: TextAlign.center),
      'BillingResponse.featureNotSupported': translatedText(
          context, 'billing_response_feature_not_supported', 16, Palette().menudark,
          textAlign: TextAlign.center),
      'BillingResponse.serviceDisconnected': translatedText(
          context, 'billing_response_service_disconnected', 16, Palette().menudark,
          textAlign: TextAlign.center),
      'BillingResponse.timeout':
          translatedText(context, 'billing_response_timeout', 16, Palette().menudark, textAlign: TextAlign.center),
      'NoInternetConnection': translatedText(context, 'billing_response_developer_error', 16, Palette().menudark,
          textAlign: TextAlign.center),
    };
    final Map<String, Widget> billingResponseDescriptions = {
      'PurchaseSuccess':
          translatedText(context, 'purchase_success_desc', 16, Palette().menudark, textAlign: TextAlign.center),
      'PurchaseRestored':
          translatedText(context, 'purchase_restored_desc', 16, Palette().menudark, textAlign: TextAlign.center),
      'BillingResponse.itemAlreadyOwned': translatedText(
          context, 'billing_response_item_already_owned_desc', 16, Palette().menudark,
          textAlign: TextAlign.center),
      'BillingResponse.serviceUnavailable': translatedText(
          context, 'billing_response_service_unavailable_desc', 16, Palette().menudark,
          textAlign: TextAlign.center),
      'BillingResponse.billingUnavailable': translatedText(
          context, 'billing_response_billing_unavailable_desc', 16, Palette().menudark,
          textAlign: TextAlign.center),
      'BillingResponse.itemUnavailable': translatedText(
          context, 'billing_response_item_unavailable_desc', 16, Palette().menudark,
          textAlign: TextAlign.center),
      'BillingResponse.developerError': translatedText(
          context, 'billing_response_developer_error_desc', 16, Palette().menudark,
          textAlign: TextAlign.center),
      'BillingResponse.error':
          translatedText(context, 'billing_response_error_desc', 16, Palette().menudark, textAlign: TextAlign.center),
      'BillingResponse.itemNotOwned': translatedText(
          context, 'billing_response_item_not_owned_desc', 16, Palette().menudark,
          textAlign: TextAlign.center),
      'BillingResponse.userCancelled': translatedText(
          context, 'billing_response_user_cancelled_desc', 16, Palette().menudark,
          textAlign: TextAlign.center),
      'BillingResponse.featureNotSupported': translatedText(
          context, 'billing_response_feature_not_supported_desc', 16, Palette().menudark,
          textAlign: TextAlign.center),
      'BillingResponse.serviceDisconnected': translatedText(
          context, 'billing_response_service_disconnected_desc', 16, Palette().menudark,
          textAlign: TextAlign.center),
      'BillingResponse.timeout':
          translatedText(context, 'billing_response_timeout_desc', 16, Palette().menudark, textAlign: TextAlign.center),
      'BillingResponse.offerExpired': translatedText(
          context, 'billing_response_offer_expired_desc', 16, Palette().menudark,
          textAlign: TextAlign.center),
      'NoInternetConnection':
          translatedText(context, 'no_internet_connection', 16, Palette().menudark, textAlign: TextAlign.center),
    };
    showDialog(
      context: context,
      builder: (context) {
        Widget title = billingResponseTitles[billingResponse] ?? defaultTitle;
        Widget description = billingResponseDescriptions[billingResponse] ?? defaultDescription;
        print("show dialog: BillingResponse: $billingResponse");
        if (!billingResponseTitles.containsKey(billingResponse)) {
          description = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              translatedText(context, 'billing_response_error', 16, Palette().menudark, textAlign: TextAlign.center),
              letsText(context, ' $billingResponse', 16, Palette().menudark),
            ],
          );
        }

        final audioController = context.watch<AudioController>();
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: Palette().white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: title,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset('assets/time_to_party_assets/line_instruction_screen.png'),
                ),
                ResponsiveSizing.responsiveHeightGap(context, 10),
                Center(child: description),
                ResponsiveSizing.responsiveHeightGap(context, 10),
                Center(
                  child: CustomStyledButton(
                    icon: null,
                    text: 'OK',
                    onPressed: () async {
                      audioController.playSfx(SfxType.buttonBackExit);
                      if (billingResponse == "PurchaseSuccess" || billingResponse == "PurchaseRestored") {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    backgroundColor: Palette().pink,
                    foregroundColor: Palette().white,
                    width: 200,
                    height: 45,
                    fontSize: ResponsiveSizing.scaleHeight(context, 20),
                  ),
                ),
                translatedText(context, 'do_you_need_help_contact_us', 16, Palette().menudark,
                    textAlign: TextAlign.center),
                Center(
                  child: CustomStyledButton(
                    icon: Icons.edit,
                    onPressed: () {
                      Navigator.of(context).pop();
                      showExitDialog(context);
                    },
                    text: getTranslatedString(context, 'contact_us'),
                    backgroundColor: Palette().pink,
                    foregroundColor: Palette().white,
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

enum AlertOrigin { cardScreen, otherScreen }

class PointsAnimationDialog extends StatefulWidget {
  final int greenPoints;
  final int redPoints;

  PointsAnimationDialog({required this.greenPoints, required this.redPoints});

  @override
  _PointsAnimationDialogState createState() => _PointsAnimationDialogState();
}

class _PointsAnimationDialogState extends State<PointsAnimationDialog> with TickerProviderStateMixin {
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
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _redStarController = AnimationController(
      duration: const Duration(milliseconds: 100),
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
    await _greenStarController.forward();
    await _redStarController.forward();

    for (var i = 0; i < widget.greenPoints; i++) {
      await Future.delayed(Duration(milliseconds: 100));
      setState(() {
        final audioController = context.read<AudioController>();
        audioController.playSfx(SfxType.score_sound_effect);
        _currentGreenPoints++;
      });
      // Trigger scale animation each time the point increases
      await _greenStarController.forward(from: 0);
    }

    for (var i = 0; i < widget.redPoints; i++) {
      await Future.delayed(Duration(milliseconds: 100));
      setState(() {
        _currentRedPoints++;
      });
      // Trigger scale animation each time the point increases
      await _redStarController.forward(from: 0);
    }

    await Future.delayed(Duration(seconds: 2));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white.withOpacity(0.3),
      elevation: 0,
      child: FittedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _greenStarScale,
              child: _StarPoints(
                color: Colors.lightGreen,
                points: _currentGreenPoints,
              ),
            ),
            SizedBox(width: 16), // Space between the stars
            ScaleTransition(
              scale: _redStarScale,
              child: _StarPoints(
                color: Colors.redAccent,
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
            color: color.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
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
            size: 22,
            color: color,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.star_rounded),
              Transform.translate(
                offset: Offset(0, 1),
                child: Text(
                  '$points',
                  style: TextStyle(
                    fontSize: 8,
                    color: Palette().white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
