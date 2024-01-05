import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../app_lifecycle/responsive_sizing.dart';
import '../app_lifecycle/translated_text.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../play_session/alerts_and_dialogs.dart';
import '../play_session/custom_style_buttons.dart';
import '../style/palette.dart';
import '../win_game/triple_button_win.dart';
import '../in_app_purchase/in_app_purchase.dart';

class InstructionDialog extends StatefulWidget {
  bool isGameOpened = false;

  InstructionDialog({super.key, required this.isGameOpened});

  @override
  _InstructionDialogState createState() => _InstructionDialogState();
}
class _InstructionDialogState extends State<InstructionDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimationLeftButton;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _scaleAnimationLeftButton = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.1),
          weight: 0.05
      ),
      TweenSequenceItem(
          tween: ConstantTween<double>(1.1),
          weight: 0.05
      ),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.1, end: 1.0),
          weight: 0.05
      ),
      TweenSequenceItem(
          tween: ConstantTween<double>(1.0),
          weight: 0.85
      ),
    ]).animate(_animationController);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        textTheme: ThemeData().textTheme.copyWith(
              titleLarge: TextStyle(
                fontFamily: 'HindMadurai',
                color: Color(0xFFCB48EF),
                fontSize: ResponsiveSizing.scaleHeight(context, 24),
              ),
              bodyLarge:
                  TextStyle(fontSize: ResponsiveSizing.scaleHeight(context, 16)),
            ),
      ),
      child: Builder(
        builder: (context) {
          return AlertDialog(
            title: Center(
                child: translatedText(context, 'game_rules', 24, Palette().pink,
                    textAlign: TextAlign.center)),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                children: [
                  SvgPicture.asset(
                      'assets/time_to_party_assets/line_instruction_screen.svg'),
                  SizedBox(
                      height: ResponsiveSizing.scaleHeight(context, 16)), // gap
                  Expanded(
                    child: Scrollbar(
                        thumbVisibility: true,trackVisibility: true,
                        thickness: -6.0,
                        radius: Radius.circular(10),
                        child: ListView(
                      children: [
                        translatedText(
                            context, 'game_introduction', 24, Palette().pink),
                        ResponsiveSizing.responsiveWidthGap(context, 10),
                        translatedText(context, 'instruction_dialog_general',
                            16, Palette().menudark),
                        ResponsiveSizing.responsiveWidthGap(context, 10),
                        SvgPicture.asset(
                            'assets/time_to_party_assets/cards_instruction_linear.svg'),
                        ResponsiveSizing.responsiveWidthGap(context, 10),
                        translatedText(
                            context, 'game_purpose', 24, Palette().pink),
                        ResponsiveSizing.responsiveWidthGap(context, 10),
                        translatedText(context, 'instruction_dialog_players_teams',
                            16, Palette().menudark),
                        ResponsiveSizing.responsiveWidthGap(context, 10),
                        translatedText(
                            context, 'teams_and_roles', 24, Palette().pink),
                        ResponsiveSizing.responsiveWidthGap(context, 10),
                        translatedText(context, 'instruction_dialog_colors_flags',
                            16, Palette().menudark),
                        SvgPicture.asset(
                            'assets/time_to_party_assets/instruction_flags_field.svg'),
                        ResponsiveSizing.responsiveWidthGap(context, 10),
                        translatedText(
                            context, 'mechanics', 24, Palette().pink),
                        ResponsiveSizing.responsiveWidthGap(context, 10),
                        translatedText(context, 'instruction_dialog_random_team',
                            16, Palette().menudark),
                        translatedText(context, 'instruction_dialog_main_generals',
                            16, Palette().menudark),
                        translatedText(context, 'instruction_dialog_screen',
                            16, Palette().menudark),
                        ResponsiveSizing.responsiveWidthGap(context, 10),
                        translatedText(context, 'scoring', 24, Palette().pink),
                        ResponsiveSizing.responsiveWidthGap(context, 10),
                        translatedText(context, 'instruction_dialog_skip_words',
                            16, Palette().menudark),
                        translatedText(context, 'instruction_dialog_mistakes',
                            16, Palette().menudark),
                        ResponsiveSizing.responsiveWidthGap(context, 10),
                        SvgPicture.asset(
                            'assets/time_to_party_assets/instruction_cards_linear_2.svg'),
                        ResponsiveSizing.responsiveWidthGap(context, 10),
                        translatedText(context, 'instruction_dialog_device',
                            16, Palette().menudark),
                        translatedText(context, 'instruction_dialog_words_forms',
                            16, Palette().menudark),
                       ResponsiveSizing.responsiveWidthGap(context, 10),
                        Row(
                          children: [
                            translatedText(
                                context, 'taboo_words', 24, Palette().pink),
                            ResponsiveSizing.responsiveWidthGap(context, 10),
                            SvgPicture.asset(
                                'assets/time_to_party_assets/field_taboo.svg'),
                          ],
                        ),
                        ResponsiveSizing.responsiveWidthGap(context, 10),
                        translatedText(context, 'instruction_dialog_taboo_fields',
                            16, Palette().menudark),
                        ResponsiveSizing.responsiveWidthGap(context, 10),
                        Row(
                          children: [
                            translatedText(
                                context, 'rymes', 24, Palette().pink),
                            ResponsiveSizing.responsiveWidthGap(context, 10),
                            SvgPicture.asset(
                                'assets/time_to_party_assets/field_sheet.svg'),
                          ],
                        ),
                        ResponsiveSizing.responsiveWidthGap(context, 10),
                        translatedText(context, 'instruction_dialog_rymes',
                            16, Palette().menudark),
                         ResponsiveSizing.responsiveWidthGap(context, 10),
                        Row(
                          children: [
                            translatedText(
                                context, 'pantomime', 24, Palette().pink),
                            ResponsiveSizing.responsiveWidthGap(context, 10),
                            SvgPicture.asset(
                                'assets/time_to_party_assets/field_pantomime.svg'),
                          ],
                        ),
                        ResponsiveSizing.responsiveWidthGap(context, 10),
                        translatedText(context, 'instruction_dialog_pantomime',
                            16, Palette().menudark),
                        ResponsiveSizing.responsiveWidthGap(context, 10),
                        Row(
                          children: [
                            translatedText(
                                context, 'alphabet', 24, Palette().pink),
                            ResponsiveSizing.responsiveWidthGap(context, 10),
                            SvgPicture.asset(
                                'assets/time_to_party_assets/field_letters.svg'),
                          ],
                        ),
                        ResponsiveSizing.responsiveWidthGap(context, 10),
                        translatedText(context, 'instruction_dialog_20_words',
                            16, Palette().menudark),
                        ResponsiveSizing.responsiveWidthGap(context, 10),
                        Row(
                          children: [
                            translatedText(
                                context, 'famous_people', 24, Palette().pink),
                            ResponsiveSizing.responsiveWidthGap(context, 10),
                            SvgPicture.asset(
                                'assets/time_to_party_assets/field_microphone.svg'),
                          ],
                        ),
                        ResponsiveSizing.responsiveWidthGap(context, 10),
                        translatedText(context, 'instruction_dialog_famous_people',
                            16, Palette().menudark),                        ResponsiveSizing.responsiveWidthGap(context, 10),
                        Row(
                          children: [
                            translatedText(
                                context, 'checkbox', 24, Palette().pink),
                            ResponsiveSizing.responsiveWidthGap(context, 10),
                            SvgPicture.asset(
                                'assets/time_to_party_assets/field_arrows.svg'),
                          ],
                        ),
                        ResponsiveSizing.responsiveWidthGap(context, 10),
                        translatedText(context, 'instruction_dialog_choice',
                            16, Palette().menudark),
                        ResponsiveSizing.responsiveWidthGap(context, 10),
                        translatedText(context, 'summary', 24, Palette().pink),
                        ResponsiveSizing.responsiveWidthGap(context, 10),
                        translatedText(context, 'instruction_dialog_have_fun',
                            16, Palette().menudark),
                        Consumer<InAppPurchaseController?>(
                          builder: (context, purchaseController, child) {
                            if (purchaseController!.isPurchased) {
                              return Container(); // Zawartość dla użytkowników, którzy dokonali zakupu
                            } else {
                              return buildFreeContent(context); // Zawartość dla użytkowników bez zakupu
                            }
                          },
                        ),
                      ],
                    ),),
                  ), // Dodaj swoją linię SVG tutaj
                ],
              ),
            ),
            actionsPadding: EdgeInsets.symmetric(
                horizontal: 20), // Zmniejsz obramowanie przycisków
            actions: [
              Expanded(
                child: Center(
                  heightFactor: 1.5,
                  child:
                  CustomStyledButton(
                    icon: null,
                    text: 'OK',
                    onPressed: () {
                      final audioController = context.read<AudioController>();
                      audioController.playSfx(SfxType.button_back_exit);
                      Navigator.pop(context);
                    },
                    backgroundColor: Palette().pink,
                    foregroundColor: Palette().white,
                    width: 200,
                    height: 45,
                    fontSize: ResponsiveSizing.scaleHeight(context, 20),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget buildFreeContent(BuildContext context) {
    return Column(
      children: [
        ResponsiveSizing.responsiveWidthGap(context, 10),
        translatedText(context, 'discover_the_full_potential', 18, Palette().pink,
            textAlign: TextAlign.center),
        AnimatedBuilder(
          animation: _scaleAnimationLeftButton,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimationLeftButton.value,
            child: child,
          ), child:
        Padding(
            padding: EdgeInsets.all(20),child:
        TripleButtonWin(
          svgAsset: 'assets/time_to_party_assets/premium_cards_icon.svg',
          onPressed: () async {
            await Future.delayed(Duration(milliseconds: 150));
            if(widget.isGameOpened){
              AnimatedAlertDialog.showExitGameDialog(
                  context,
                  false,
                  '',
                  [], // Pusta lista Stringów
                  [], // Pusta lista Colorów
                  true
              );

            } else GoRouter.of(context).push('/card_advertisement');
          },
        )
        )
          ,
        ),
        ResponsiveSizing.responsiveWidthGap(context, 10),
        translatedText(context, 'buy_unlimited_version', 20, Palette().pink, textAlign: TextAlign.center),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

}
