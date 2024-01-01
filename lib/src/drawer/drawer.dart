
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../main.dart';
import '../app_lifecycle/translated_text.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../instruction_dialog/instruction_dialog.dart';
import '../play_session/alerts_and_dialogs.dart';
import '../style/palette.dart';
import 'global_loading_indicator.dart';

class CustomAppDrawer extends StatefulWidget {
  const CustomAppDrawer({super.key});

  @override
  CustomAppDrawerState createState() => CustomAppDrawerState();
}

class CustomAppDrawerState extends State<CustomAppDrawer> {
  @override
  Widget build(BuildContext context) {
    final audioController = context.read<AudioController>();
    return Stack(
      children: [
        Drawer(
          child: Container(
            width: ResponsiveSizing.scaleWidth(context, 288),
            decoration: BoxDecoration(gradient: Palette().drawerGradient),
            child: Scrollbar(
              thumbVisibility: false,
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  ResponsiveSizing.responsiveHeightGap(context, 10),
                  Material(
                    child: Container(
                      height: ResponsiveSizing.responsiveHeightWithCondition(
                          context, 40, 96, 650),
                      margin: ResponsiveSizing.responsiveMarginWithCondition(
                          context, 50, 64, 650),
                      decoration: BoxDecoration(),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: () async {
                          audioController.playSfx(SfxType.button_back_exit);
                          await Future.delayed(Duration(milliseconds: 150));
                          await GoRouter.of(context).push('/card_advertisement');
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/time_to_party_assets/premium_cards_icon.svg', // Podmień na ścieżkę do swojego obrazka SVG
                              height: ResponsiveSizing.scaleWidth(
                                  context, 43), // Dostosuj wysokość obrazka
                              width: ResponsiveSizing.scaleWidth(
                                  context, 43), // Dostosuj szerokość obrazka
                            ),
                            ResponsiveSizing.responsiveWidthGap(context,
                                10), // Odstęp między obrazkiem a tekstem
                            translatedText(
                                context, 'premium_cards', 20, Palette().white),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ResponsiveSizing.responsiveWidthGapWithCondition(
                      context, 1, 30, 650),
                  Divider(
                    color: Palette().white,
                  ),
                  //Zasady gry
                  Material(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () {
                        audioController.playSfx(SfxType.button_infos);
                        Future.delayed(Duration(milliseconds: 150), () {
                          showDialog<void>(
                            context: context,
                            builder: (context) {
                              return InstructionDialog();
                            },
                          );
                        });
                      },
                      child: ListTile(
                        leading: Icon(
                          Icons.question_mark,
                          color: Palette().white,
                        ),
                        title: translatedText(
                            context, 'game_rules', 14, Palette().white),
                      ),
                    ),
                  ),
                  Divider(
                    color: Palette().white,
                  ),
                  //Polityka prywatnosci
                  Material(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      child: ListTile(
                          leading: Icon(
                            Icons.privacy_tip,
                            color: Palette().white,
                          ),
                          title: translatedText(
                              context, 'privacy_policy', 14, Palette().white),
                          onTap: () async {
                            audioController.playSfx(SfxType.button_back_exit);
                            await globalLoading
                                .privacy_policy_function(context);
                          }),
                    ),
                  ),
                  //Umowa licencyjna
                  Material(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () async {
                        audioController.playSfx(SfxType.button_back_exit);
                        await globalLoading.eula_function(context);
                      },
                      child: ListTile(
                        leading: Icon(
                          Icons.zoom_in,
                          color: Palette().white,
                        ),
                        title: translatedText(context,
                            'end_user_license_agreement', 14, Palette().white),
                      ),
                    ),
                  ),
                  Divider(
                    color: Palette().white,
                  ),
                  //Zmień język
                  Material(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () async {
                        audioController.playSfx(SfxType.button_back_exit);
                        await Future.delayed(Duration(milliseconds: 150));
                        GoRouter.of(context).go('/language_selector');
                      },
                      child: ListTile(
                        leading: Icon(
                          Icons.language,
                          color: Palette().white,
                        ),
                        title: translatedText(
                            context, 'select_language', 14, Palette().white),
                      ),
                    ),
                  ),
                  //Ustawienia
                  Material(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () async {
                        audioController.playSfx(SfxType.button_back_exit);
                        await Future.delayed(Duration(milliseconds: 150));
                        GoRouter.of(context).go('/settings');
                      },
                      child: ListTile(
                        leading: Icon(
                          Icons.settings,
                          color: Palette().white,
                        ),
                        title: translatedText(
                            context, 'settings', 14, Palette().white),
                      ),
                    ),
                  ),
                  Divider(
                    color: Palette().white,
                  ),
                  //TO_DO Przywróć platnosci
                  Material(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () async {
                        audioController.playSfx(SfxType.button_back_exit);
                        await Future.delayed(Duration(milliseconds: 150));
                      },
                      child: ListTile(
                        leading: Icon(
                          Icons.settings_backup_restore,
                          color: Palette().white,
                        ),
                        title: translatedText(
                            context, 'restore_purchases', 14, Palette().white),
                      ),
                    ),
                  ),
                  //Napisz do nas
                  Material(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () async {
                        audioController.playSfx(SfxType.button_back_exit);
                        await Future.delayed(Duration(milliseconds: 150));
                        AnimatedAlertDialog.showExitDialog(context);
                      },
                      child: ListTile(
                        leading: Icon(
                          Icons.edit,
                          color: Palette().white,
                        ),
                        title: translatedText(
                            context, 'contact_us', 14, Palette().white),
                      ),
                    ),
                  ),
                  //Udostępnij
                  Material(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () async {
                        audioController.playSfx(SfxType.button_back_exit);
                        await Future.delayed(Duration(milliseconds: 150));
                        await _shareContent(context);
                      },
                      child: ListTile(
                        leading: Icon(
                          Icons.share,
                          color: Palette().white,
                        ),
                        title: translatedText(
                            context, 'share', 14, Palette().white),
                      ),
                    ),
                  ),
                  //Oceń w Google play
                  Material(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () async {
                        audioController.playSfx(SfxType.button_back_exit);
                        await Future.delayed(Duration(milliseconds: 150));
                        AnimatedAlertDialog.showRateDialog(context);
                      },
                      child: ListTile(
                        leading: Icon(
                          Icons.star,
                          color: Palette().white,
                        ),
                        title: translatedText(context, 'rate_us_google_play',
                            14, Palette().white),
                      ),
                    ),
                  ),
                  //Ver 1.0
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: letsText(context, "ver 1.0", 12, Palette().white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        GlobalLoadingIndicator(),
      ],
    );
  }

  Future<void> _shareContent(BuildContext context) async {
    String message =
        getTranslatedString(context, 'look_what_we_played_notification');
    String subject =
        getTranslatedString(context, 'lets_play_time_to_party');

    await Share.share(
        '${message}https://play.google.com/store/apps/details?id=NAZWA_TWOJEJ_APLIKACJI',
        subject: subject);
  }

}


