import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../style/palette.dart';
import '../app_lifecycle/translated_text.dart';

class InstructionDialog extends StatelessWidget {
  const InstructionDialog({super.key});

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
                        Row(
                          children: [
                            translatedText(
                                context, 'taboo_words', 24, Palette().pink),
                            ResponsiveSizing.responsiveWidthGap(context, 10),
                            SvgPicture.asset(
                                'assets/time_to_party_assets/field_star_blue_dark.svg'),
                          ],
                        ),
                        ResponsiveSizing.responsiveWidthGap(context, 10),
                        translatedText(context, 'instruction_dialog_taboo_fields',
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
                            16, Palette().menudark),
                        ResponsiveSizing.responsiveWidthGap(context, 10),
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
                      ],
                    ),
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
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Palette().pink, // color
                      foregroundColor: Palette().white, // textColor
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
                      final audioController = context.read<AudioController>();
                      audioController.playSfx(SfxType.button_back_exit);
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
