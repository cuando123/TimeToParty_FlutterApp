import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../app_lifecycle/loading_status.dart';
import '../app_lifecycle/responsive_sizing.dart';
import '../app_lifecycle/translated_text.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../style/palette.dart';

class GlobalLoading {
  Future<void> privacy_policy_function(BuildContext context) async {
    Provider.of<LoadingStatus>(context, listen: false).isLoading = true;
    const url = 'https://frydoapps.com/wp-content/uploads/2023/04/Privacy_Policy_for_Applications_and_Games.pdf';
    const fileName = 'Privacy_Policy_for_Applications_and_Games.pdf';

    try {
      final file = await downloadAndCachePdf(url, fileName);
      _openPdfViewer(context, file, "Privacy policy");
    } catch (e) {
      print('Error: $e');
      _connectionProblemDialog(context);
    }

    Provider.of<LoadingStatus>(context, listen: false).isLoading = false;
  }

  Future<void> eula_function(BuildContext context) async {
    Provider.of<LoadingStatus>(context, listen: false).isLoading = true;

    const url = 'https://frydoapps.com/wp-content/uploads/2023/04/EndUserLicenseAgreement_EULA.pdf';
    const fileName = 'EndUserLicenseAgreement_EULA.pdf';
    try {
      final file = await downloadAndCachePdf(url, fileName);
      _openPdfViewer(context, file, "End-User License Agreement (EULA)");
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
    final audioController = Provider.of<AudioController>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Palette().white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: translatedText(context, 'download_error_network', 16, Palette().menudark, textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SvgPicture.asset('assets/time_to_party_assets/line_instruction_screen.svg'),
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
                    minimumSize:
                        Size(MediaQuery.of(context).size.width * 0.5, MediaQuery.of(context).size.height * 0.05),
                    textStyle:
                        TextStyle(fontFamily: 'HindMadurai', fontSize: ResponsiveSizing.scaleHeight(context, 20)),
                  ),
                  onPressed: () {
                    audioController.playSfx(SfxType.buttonBackExit);
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
