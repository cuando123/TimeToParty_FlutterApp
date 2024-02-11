import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../app_lifecycle/responsive_sizing.dart';
import '../app_lifecycle/translated_text.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../in_app_purchase/services/iap_service.dart';
import '../play_session/alerts_and_dialogs.dart';
import '../play_session/custom_style_buttons.dart';
import '../style/palette.dart';
import '../win_game/triple_button_win.dart';

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
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.1), weight: 0.05),
      TweenSequenceItem(tween: ConstantTween<double>(1.1), weight: 0.05),
      TweenSequenceItem(tween: Tween<double>(begin: 1.1, end: 1.0), weight: 0.05),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 0.85),
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
              bodyLarge: TextStyle(fontSize: ResponsiveSizing.scaleHeight(context, 16)),
            ),
      ),
      child: Builder(
        builder: (context) {
          return AlertDialog(
            title:
                Center(child: translatedText(context, 'game_rules', 24, Palette().pink, textAlign: TextAlign.center)),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                children: [
                  Image.asset('assets/time_to_party_assets/line_instruction_screen.png'),
                  SizedBox(height: ResponsiveSizing.scaleHeight(context, 16)), // gap
                  Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      trackVisibility: true,
                      thickness: 6.0,
                      radius: Radius.circular(5),
                      child: Container(
                        padding: EdgeInsets.all(1),
                        child: ListView(
                          padding: const EdgeInsets.only(right: 10.0),
                          children: [
                            translatedText(context, 'game_introduction', ResponsiveSizing.scaleHeight(context, 24), Palette().pink),
                            ResponsiveSizing.responsiveHeightGap(context, 10),
                            translatedText(context, 'instruction_dialog_general', 16, Palette().menudark),
                            ResponsiveSizing.responsiveHeightGap(context, 10),
                            Image.asset('assets/time_to_party_assets/cards_instruction_linear.png'),
                            ResponsiveSizing.responsiveHeightGap(context, 10),
                            translatedText(context, 'game_purpose', ResponsiveSizing.scaleHeight(context, 24), Palette().pink),
                            ResponsiveSizing.responsiveHeightGap(context, 10),
                            translatedText(context, 'instruction_dialog_players_teams', 16, Palette().menudark),
                            ResponsiveSizing.responsiveHeightGap(context, 10),
                            translatedText(context, 'teams_and_roles', ResponsiveSizing.scaleHeight(context, 24), Palette().pink),
                            ResponsiveSizing.responsiveHeightGap(context, 10),
                            translatedText(context, 'instruction_dialog_colors_flags', 16, Palette().menudark),
                            ResponsiveSizing.responsiveHeightGap(context, 10),
                            Image.asset('assets/time_to_party_assets/instruction_flags_field.png', height: ResponsiveSizing.scaleHeight(context, 70)),
                            ResponsiveSizing.responsiveHeightGap(context, 10),
                            translatedText(context, 'mechanics', ResponsiveSizing.scaleHeight(context, 24), Palette().pink),
                            ResponsiveSizing.responsiveHeightGap(context, 10),
                            translatedText(context, 'instruction_dialog_random_team', 16, Palette().menudark),
                            translatedText(context, 'instruction_dialog_main_generals', 16, Palette().menudark),
                            translatedText(context, 'instruction_dialog_screen', 16, Palette().menudark),
                            ResponsiveSizing.responsiveHeightGap(context, 10),
                            translatedText(context, 'scoring', ResponsiveSizing.scaleHeight(context, 24), Palette().pink),
                            ResponsiveSizing.responsiveHeightGap(context, 10),
                            translatedText(context, 'instruction_dialog_skip_words', 16, Palette().menudark),
                            translatedText(context, 'instruction_dialog_mistakes', 16, Palette().menudark),
                            ResponsiveSizing.responsiveHeightGap(context, 10),
                            Image.asset('assets/time_to_party_assets/instruction_cards_linear_2.png'),
                            ResponsiveSizing.responsiveHeightGap(context, 10),
                            translatedText(context, 'instruction_dialog_device', 16, Palette().menudark),
                            translatedText(context, 'instruction_dialog_words_forms', 16, Palette().menudark),
                            ResponsiveSizing.responsiveHeightGap(context, 10),
                            Wrap(
                              alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                translatedText(context, 'taboo_words', ResponsiveSizing.scaleHeight(context, 24), Palette().pink),
                                ResponsiveSizing.responsiveWidthGap(context, 10),
                                Image.asset('assets/time_to_party_assets/field_taboo.png', height: ResponsiveSizing.scaleHeight(context, 60)),
                              ],
                            ),
                            ResponsiveSizing.responsiveHeightGap(context, 10),
                            translatedText(context, 'instruction_dialog_taboo_fields', 16, Palette().menudark),
                            ResponsiveSizing.responsiveHeightGap(context, 10),
                            Wrap(
                              alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                translatedText(context, 'rymes', ResponsiveSizing.scaleHeight(context, 24), Palette().pink),
                                ResponsiveSizing.responsiveWidthGap(context, 10),
                                Image.asset('assets/time_to_party_assets/field_sheet.png', height: ResponsiveSizing.scaleHeight(context, 60)),
                              ],
                            ),
                            ResponsiveSizing.responsiveHeightGap(context, 10),
                            translatedText(context, 'instruction_dialog_rymes', 16, Palette().menudark),
                            ResponsiveSizing.responsiveHeightGap(context, 10),
                            Wrap(
                              alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                translatedText(context, 'pantomime', ResponsiveSizing.scaleHeight(context, 24), Palette().pink),
                                ResponsiveSizing.responsiveWidthGap(context, 10),
                                Image.asset('assets/time_to_party_assets/field_pantomime.png', height: ResponsiveSizing.scaleHeight(context, 60)),
                              ],
                            ),
                            ResponsiveSizing.responsiveHeightGap(context, 10),
                            translatedText(context, 'instruction_dialog_pantomime', 16, Palette().menudark),
                            ResponsiveSizing.responsiveHeightGap(context, 10),
                            Wrap(
                              alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                translatedText(context, 'alphabet', ResponsiveSizing.scaleHeight(context, 24), Palette().pink),
                                ResponsiveSizing.responsiveWidthGap(context, 10),
                                Image.asset('assets/time_to_party_assets/field_letters.png', height: ResponsiveSizing.scaleHeight(context, 60)),
                              ],
                            ),
                            ResponsiveSizing.responsiveHeightGap(context, 10),
                            translatedText(context, 'instruction_dialog_20_words', 16, Palette().menudark),
                            ResponsiveSizing.responsiveHeightGap(context, 10),
                            Wrap(
                              alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                translatedText(context, 'famous_people', ResponsiveSizing.scaleHeight(context, 24), Palette().pink),
                                ResponsiveSizing.responsiveWidthGap(context, 10),
                                Image.asset('assets/time_to_party_assets/field_microphone.png', height: ResponsiveSizing.scaleHeight(context, 60)),
                              ],
                            ),
                            ResponsiveSizing.responsiveHeightGap(context, 10),
                            translatedText(context, 'instruction_dialog_famous_people', 16, Palette().menudark),
                            ResponsiveSizing.responsiveHeightGap(context, 10),
                            Wrap(
                              alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                translatedText(context, 'checkbox', ResponsiveSizing.scaleHeight(context, 24), Palette().pink),
                                ResponsiveSizing.responsiveWidthGap(context, 10),
                                Image.asset('assets/time_to_party_assets/field_arrows.png', height: ResponsiveSizing.scaleHeight(context, 60)),
                              ],
                            ),
                            ResponsiveSizing.responsiveHeightGap(context, 10),
                            translatedText(context, 'instruction_dialog_choice', 16, Palette().menudark),
                            ResponsiveSizing.responsiveHeightGap(context, 10),
                            translatedText(context, 'summary', ResponsiveSizing.scaleHeight(context, 24), Palette().pink),
                            ResponsiveSizing.responsiveHeightGap(context, 10),
                            translatedText(context, 'instruction_dialog_have_fun', 16, Palette().menudark),
                            Consumer<IAPService?>(
                              builder: (context, purchaseController, child) {
                                if (purchaseController!.isPurchased) {
                                  return Container(); // Zawartość dla użytkowników, którzy dokonali zakupu
                                } else {
                                  return buildFreeContent(context); // Zawartość dla użytkowników bez zakupu
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actionsPadding: EdgeInsets.symmetric(horizontal: 20), // Zmniejsz obramowanie przycisków
            actions: [
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: CustomStyledButton(
                    icon: null,
                    text: 'OK',
                    onPressed: () {
                      final audioController = context.read<AudioController>();
                      audioController.playSfx(SfxType.buttonBackExit);
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
        translatedText(context, 'discover_the_full_potential', 18, Palette().pink, textAlign: TextAlign.center),
        AnimatedBuilder(
          animation: _scaleAnimationLeftButton,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimationLeftButton.value,
            child: child,
          ),
          child: Padding(
              padding: EdgeInsets.all(20),
              child: TripleButtonWin(
                svgAsset: 'assets/time_to_party_assets/premium_cards_icon.png',
                onPressed: () {
                  Future.delayed(Duration(milliseconds: 150));
                  if (widget.isGameOpened) {
                    AnimatedAlertDialog.showExitGameDialog(
                        context,
                        false,
                        '',
                        [],
                        [],
                        true);
                  } else {
                    GoRouter.of(context).push('/card_advertisement');
                  }
                },
              )),
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
