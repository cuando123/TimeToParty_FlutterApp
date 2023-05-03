import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../instruction_dialog/instruction_dialog.dart';
import '../style/palette.dart';

class CustomAppDrawer extends StatelessWidget {
  final void Function(BuildContext context)? privacyPolicyFunction;

  CustomAppDrawer({this.privacyPolicyFunction});
  @override
  Widget build(BuildContext context) {
    final _gap = SizedBox(height: ResponsiveText.scaleHeight(context, 10));
    return Drawer(
      child: Container(
        width: ResponsiveText.scaleWidth(context, 288),
        decoration: BoxDecoration(
          gradient: Palette().drawerGradient
        ),
        child:
        Scrollbar(
          thumbVisibility: false,
          child:
        ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // Tu jeszcze dodać trzeba reklame kart TODO??
            _gap,
            Material(
            child: Container(
              height:  MediaQuery.of(context).size.height < 650 ? ResponsiveText.scaleHeight(context, 40) : ResponsiveText.scaleHeight(context, 96),
              margin: EdgeInsets.only(top:  MediaQuery.of(context).size.height < 650 ? ResponsiveText.scaleHeight(context, 50) : ResponsiveText.scaleHeight(context, 64)),
              decoration: BoxDecoration(),
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () async {
                  await Future.delayed(Duration(milliseconds: 150));
                  GoRouter.of(context).push('/card_advertisement');
                },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/time_to_party_assets/premium_cards_icon.svg', // Podmień na ścieżkę do swojego obrazka SVG
                    height: ResponsiveText.scaleWidth(context, 43), // Dostosuj wysokość obrazka
                    width: ResponsiveText.scaleWidth(context, 43), // Dostosuj szerokość obrazka
                  ),
                  SizedBox(width:  ResponsiveText.scaleWidth(context, 10)), // Odstęp między obrazkiem a tekstem
                  letsText(context, "Karty premium!", 20, Palette().white),
                ],
              ),
            ),
            ),
            ),
            MediaQuery.of(context).size.height < 650 ? SizedBox(width:  ResponsiveText.scaleHeight(context, 1)) : SizedBox(width:  ResponsiveText.scaleHeight(context, 30)),
            Divider(
              color: Palette().white,
            ),
            //Zasady gry
            Material(
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () {
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
                  title: letsText(context, "Zasady gry", 14, Palette().white),
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
                    title: letsText(context, "Polityka prywatności", 14, Palette().white),
                    onTap: () async {
                      _privacy_policy_function(context);
                    }),
              ),
            ),
            //Umowa licencyjna
            Material(
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () async {
                  final url =
                      'https://frydoapps.com/wp-content/uploads/2023/04/EndUserLicenseAgreement_EULA.pdf';
                  final fileName = 'EndUserLicenseAgreement_EULA.pdf';
                  try {
                    final file = await downloadAndCachePdf(url, fileName);
                    _openPdfViewer(context, file, "Umowa licencyjna EULA");
                  } catch (e) {
                    _connectionProblemDialog(context);
                  }
                },
                child: ListTile(
                  leading: Icon(
                    Icons.zoom_in,
                    color: Palette().white,
                  ),
                  title: letsText(context, "Umowa licencyjna EULA", 14, Palette().white),
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
                  await Future.delayed(Duration(milliseconds: 150));
                  GoRouter.of(context).push('/language_selector');
                },
                child: ListTile(
                  leading: Icon(
                    Icons.language,
                    color: Palette().white,
                  ),
                  title: letsText(context, "Zmień język", 14, Palette().white),
                ),
              ),
            ),
            //Ustawienia
            Material(
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () async {
                  await Future.delayed(Duration(milliseconds: 150));
                  GoRouter.of(context).go('/settings');
                },
                child: ListTile(
                  leading: Icon(
                    Icons.settings,
                    color: Palette().white,
                  ),
                  title: letsText(context, "Ustawienia", 14, Palette().white),
                ),
              ),
            ),
            Divider(
              color: Palette().white,
            ),
            //Przywróć platnosci: TODO
            Material(
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () async {
                  await Future.delayed(Duration(milliseconds: 150));
                },
                child: ListTile(
                  leading: Icon(
                    Icons.settings_backup_restore,
                    color: Palette().white,
                  ),
                  title: letsText(context, "Przywróć płatności", 14, Palette().white),
                ),
              ),
            ),
            //Napisz do nas
            Material(
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () async {
                  await Future.delayed(Duration(milliseconds: 150));
                  showExitDialog(context);
                },
                child: ListTile(
                  leading: Icon(
                    Icons.edit,
                    color: Palette().white,
                  ),
                  title: letsText(context, "Napisz do nas!", 14, Palette().white),
                ),
              ),
            ),
            //Udostępnij
            Material(
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () async {
                  await Future.delayed(Duration(milliseconds: 150));
                  _shareContent();
                },
                child: ListTile(
                  leading: Icon(
                    Icons.share,
                    color: Palette().white,
                  ),
                  title: letsText(context, "Udostępnij", 14, Palette().white),
                ),
              ),
            ),
            //Oceń w Google play
            Material(
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () async {
                  await Future.delayed(Duration(milliseconds: 150));
                  _showRateDialog(context);
                },
                child: ListTile(
                  leading: Icon(
                    Icons.star,
                    color: Palette().white,
                  ),
                  title: letsText(context, "Oceń nas w Google Play!", 14, Palette().white),
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
        ),),
      ),
    );
  }

  void _shareContent() {
    Share.share(
        'Zobacz w co graliśmy ze znajomymi! Super gierka na imprezę, możemy kiedyś zagrać :) https://play.google.com/store/apps/details?id=NAZWA_TWOJEJ_APLIKACJI',
        subject: 'Zagrajmy w Time to Party!');
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
            onViewCreated: (PDFViewController controller) {},
            onPageChanged: (int? page, int? total) {},
          ),
        ),
      ),
    );
  }

  void _showRateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final _gap = SizedBox(height: ResponsiveText.scaleHeight(context, 10));
        return AlertDialog(
          backgroundColor: Palette().white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(
            'Twoja opinia ma znaczenie!',
            style: TextStyle(
              color: Color(0XFF391D50),
              fontFamily: 'HindMadurai',
              fontSize: ResponsiveText.scaleHeight(context, 18),
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Jeśli podoba Ci się aplikacja, daj nam  5 gwiazdek! Dla ciebie to jeden klik, a dla nas motywacja do działania :)',
                textAlign: TextAlign.center,
              ),
              _gap,
              Center(
                child: SvgPicture.asset(
                  'assets/time_to_party_assets/5_stars_rate.svg',
                ),
              ),
              _gap,
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette().pink, // color
                  foregroundColor: Palette().white, // textColor
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize: Size(MediaQuery.of(context).size.width,
                      ResponsiveText.scaleHeight(context, 40)),
                  textStyle: TextStyle(fontFamily: 'HindMadurai', fontSize: ResponsiveText.scaleHeight(context, 20)),
                ),
                onPressed: () async {
                  final String url =
                      'https://play.google.com/store/apps/details?id=<YOUR_APP_PACKAGE_NAME>';
                  if (await canLaunchUrlString(url)) {
                    await launchUrlString(url);
                  } else {
                    print('Could not launch $url');
                  }
                },
                child: Text('Oceń w Google Play!'),
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Anuluj'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _connectionProblemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Palette().white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(
            'Błąd podczas pobierania pliku. Sprawdź połączenie z Internetem.',
            style: TextStyle(
              color: Color(0XFF391D50),
              fontFamily: 'HindMadurai',
              fontSize: ResponsiveText.scaleHeight(context, 18),
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette().pink, // color
                  foregroundColor: Palette().white, // textColor
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize: Size(MediaQuery.of(context).size.width,
                      ResponsiveText.scaleHeight(context, 40)),
                  textStyle: TextStyle(fontFamily: 'HindMadurai', fontSize: ResponsiveText.scaleHeight(context, 20)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  void showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final _gap = SizedBox(height: ResponsiveText.scaleHeight(context, 10));
        return AlertDialog(
          backgroundColor: Palette().white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(
            'Czy chcesz opuścić aplikację?',
            style: TextStyle(
              color: Color(0XFF391D50),
              fontFamily: 'HindMadurai',
              fontSize: ResponsiveText.scaleHeight(context, 18),
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Zostaniesz przekierowany na stronę internetową.',
                textAlign: TextAlign.center,
              ),
              _gap,
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette().pink, // color
                  foregroundColor: Palette().white, // textColor
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize: Size(MediaQuery.of(context).size.width,
                      ResponsiveText.scaleHeight(context, 40)),
                  textStyle: TextStyle(fontFamily: 'HindMadurai', fontSize: ResponsiveText.scaleHeight(context, 20)),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  String url = 'https://frydoapps.com/contact-apps';
                  if (await canLaunchUrlString(url)) {
                    await launchUrlString(url,
                        mode: LaunchMode.externalApplication);
                  } else {
                    throw 'Nie można otworzyć $url';
                  }
                },
                child: Text('OK'),
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Anuluj'),
                ),
              ),
            ],
          ),
        );
      },
    );
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

  void _privacy_policy_function(BuildContext context) async {
    final url =
        'https://frydoapps.com/wp-content/uploads/2023/04/Privacy_Policy_for_Applications_and_Games.pdf';
    final fileName =
        'Privacy_Policy_for_Applications_and_Games.pdf';
    try {
      final file = await downloadAndCachePdf(url, fileName);
      _openPdfViewer(context, file, "Polityka prywatności");
    } catch (e) {
      print('Błąd: $e');
      _connectionProblemDialog(context);
    }
  }
  static void callPrivacyPolicyFunction(BuildContext context, CustomAppDrawer appDrawer) {
    appDrawer._privacy_policy_function(context);
  }

  Text letsText(BuildContext context, String text, double fontSize, Color textColor) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'HindMadurai',
        fontSize: ResponsiveText.scaleHeight(context, fontSize),
        color: textColor,
      ),
    );
  }
}
