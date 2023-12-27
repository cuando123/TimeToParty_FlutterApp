import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../main.dart';
import '../app_lifecycle/translated_text.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../instruction_dialog/instruction_dialog.dart';
import '../play_session/alerts_and_dialogs.dart';
import '../style/palette.dart';

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
                        showExitDialog(context);
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

  static void showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final audioController = context.watch<AudioController>();
        return AlertDialog(
          backgroundColor: Palette().white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: translatedText(
              context, 'would_you_like_exit', 20, Palette().pink,
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
              translatedText(
                  context, 'redirected_to_the_website', 16, Palette().menudark,
                  textAlign: TextAlign.center),
              ResponsiveSizing.responsiveHeightGap(context, 10),
              Center(
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
                  onPressed: () async {
                    audioController.playSfx(SfxType.button_back_exit);
                    Navigator.pop(context);
                    String url = 'https://frydoapps.com/contact-apps';
                    if (await canLaunchUrlString(url)) {
                      await launchUrlString(url,
                          mode: LaunchMode.externalApplication);
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
                    audioController.playSfx(SfxType.button_back_exit);
                    Navigator.of(context).pop();
                  },
                  child: translatedText(
                      context, 'cancel', 16, Palette().bluegrey,
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

class GlobalLoading {
  Future<void> privacy_policy_function(BuildContext context) async {
    Provider.of<LoadingStatus>(context, listen: false).isLoading = true;
    const url =
        'https://frydoapps.com/wp-content/uploads/2023/04/Privacy_Policy_for_Applications_and_Games.pdf';
    const fileName = 'Privacy_Policy_for_Applications_and_Games.pdf';

    try {
      final file = await downloadAndCachePdf(url, fileName);
      _openPdfViewer(context, file, "Polityka prywatności");
    } catch (e) {
      print('Błąd: $e');
      _connectionProblemDialog(context);
    }

    Provider.of<LoadingStatus>(context, listen: false).isLoading = false;
  }

  Future<void> eula_function(BuildContext context) async {
    Provider.of<LoadingStatus>(context, listen: false).isLoading = true;

    const url =
        'https://frydoapps.com/wp-content/uploads/2023/04/EndUserLicenseAgreement_EULA.pdf';
    const fileName = 'EndUserLicenseAgreement_EULA.pdf';
    try {
      final file = await downloadAndCachePdf(url, fileName);
      _openPdfViewer(context, file, "Umowa licencyjna EULA");
    } catch (e) {
      _connectionProblemDialog(context);
    }

    Provider.of<LoadingStatus>(context, listen: false).isLoading = false;
  }

  Future<io.File> downloadAndCachePdf(String url, String fileName) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final directory = await getTemporaryDirectory();
      final file = io.File('${directory.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else {
      throw Exception('Błąd pobierania pliku PDF.');
    }
  }

  void _connectionProblemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Palette().white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: translatedText(
              context, 'download_error_network', 16, Palette().menudark,
              textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SvgPicture.asset(
                    'assets/time_to_party_assets/line_instruction_screen.svg'),
              ),
              SizedBox(height: ResponsiveSizing.scaleHeight(context, 10)),
              Center(
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
                    final audioController = context.watch<AudioController>();
                    audioController.playSfx(SfxType.button_back_exit);
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openPdfViewer(BuildContext context, io.File file, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: PDFView(
            filePath: file.path,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: true,
            pageFling: true,
            onError: (error) {
              print(error.toString());
            },
            onPageError: (page, error) {
              print('$page: ${error.toString()}');
            },
            onViewCreated: (controller) {},
            onPageChanged: (page, total) {},
          ),
        ),
      ),
    );
  }
}

class GlobalLoadingIndicator extends StatelessWidget {
  const GlobalLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LoadingStatus>(
      builder: (context, loadingStatus, child) {
        if (loadingStatus.isLoading) {
          return Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: CircularProgressIndicator(color: Palette().pink),
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
