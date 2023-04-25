import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF604779), // 0.0
              Color(0xFF2E1F46), // 0.5
              Color(0xFF1F1D23), // 1.0
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(),
              child: Text('Menu'),
            ),
            ListTile(
              leading: Icon(
                Icons.question_mark,
                color: Color(0xFFE5E5E5),
              ),
              title: Text(
                'Zasady gry',
                style: TextStyle(
                  fontFamily: 'HindMadurai',
                  fontSize: 14,
                  color: Color(0xFFE5E5E5),
                ),
              ),
              onTap: () {
                // Naviguj do strony Polityki prywatności
              },
            ),
            Divider(
              color: Color(0xFFE5E5E5),
            ),
            ListTile(
                leading: Icon(
                  Icons.privacy_tip,
                  color: Color(0xFFE5E5E5), // Dodaj kolor ikony z theme
                ),
                title: Text(
                  'Polityka prywatności',
                  style: TextStyle(
                    fontFamily: 'HindMadurai',
                    fontSize: 14,
                    color: Color(0xFFE5E5E5), // Dodaj kolor tekstu z theme
                  ),
                ),
                onTap: () async {
                  final url =
                      'https://frydoapps.com/wp-content/uploads/2023/04/Privacy_Policy_for_Applications_and_Games.pdf';
                  final fileName =
                      'Privacy_Policy_for_Applications_and_Games.pdf';
                  try {
                    final file = await downloadAndCachePdf(url, fileName);
                    _openPdfViewer(context, file);
                  } catch (e) {
                    print('Błąd: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Błąd podczas pobierania pliku PDF.')),
                    );
                  }
                }),
            ListTile(
              leading: Icon(
                Icons.zoom_in,
                color: Color(0xFFE5E5E5), // Dodaj kolor ikony z theme
              ),
              title: Text(
                'Dane osobowe',
                style: TextStyle(
                  fontFamily: 'HindMadurai',
                  fontSize: 14,
                  color: Color(0xFFE5E5E5), // Dodaj kolor tekstu z theme
                ),
              ),
              onTap: () {
                // Naviguj do strony Polityki prywatności
              },
            ),
            Divider(
              color: Color(0xFFE5E5E5),
            ),
            ListTile(
              leading: Icon(
                Icons.language,
                color: Color(0xFFE5E5E5), // Dodaj kolor ikony z theme
              ),
              title: Text(
                'Zmień język',
                style: TextStyle(
                  fontFamily: 'HindMadurai',
                  fontSize: 14,
                  color: Color(0xFFE5E5E5), // Dodaj kolor tekstu z theme
                ),
              ),
              onTap: () {
                // Naviguj do strony Polityki prywatności
              },
            ),
            ListTile(
              leading: Icon(
                Icons.settings,
                color: Color(0xFFE5E5E5), // Dodaj kolor ikony z theme
              ),
              title: Text(
                'Ustawienia',
                style: TextStyle(
                  fontFamily: 'HindMadurai',
                  fontSize: 14,
                  color: Color(0xFFE5E5E5), // Dodaj kolor tekstu z theme
                ),
              ),
              onTap: () {
                // Naviguj do strony Polityki prywatności
              },
            ),
            Divider(
              color: Color(0xFFE5E5E5),
            ),
            ListTile(
              leading: Icon(
                Icons.settings_backup_restore,
                color: Color(0xFFE5E5E5), // Dodaj kolor ikony z theme
              ),
              title: Text(
                'Przywróć płatności',
                style: TextStyle(
                  fontFamily: 'HindMadurai',
                  fontSize: 14,
                  color: Color(0xFFE5E5E5), // Dodaj kolor tekstu z theme
                ),
              ),
              onTap: () {
                // Naviguj do strony Polityki prywatności
              },
            ),
            ListTile(
              leading: Icon(
                Icons.warning_amber,
                color: Color(0xFFE5E5E5), // Dodaj kolor ikony z theme
              ),
              title: Text(
                'Zgłoś błąd',
                style: TextStyle(
                  fontFamily: 'HindMadurai',
                  fontSize: 14,
                  color: Color(0xFFE5E5E5), // Dodaj kolor tekstu z theme
                ),
              ),
              onTap: () {
                // Naviguj do strony Polityki prywatności
              },
            ),
            ListTile(
              leading: Icon(
                Icons.edit,
                color: Color(0xFFE5E5E5), // Dodaj kolor ikony z theme
              ),
              title: Text(
                'Napisz do nas!',
                style: TextStyle(
                  fontFamily: 'HindMadurai',
                  fontSize: 14,
                  color: Color(0xFFE5E5E5), // Dodaj kolor tekstu z theme
                ),
              ),
              onTap: () {
                // Naviguj do strony Polityki prywatności
              },
            ),
            ListTile(
              leading: Icon(
                Icons.star,
                color: Color(0xFFE5E5E5), // Dodaj kolor ikony z theme
              ),
              title: Text(
                'Oceń nas w Google Play!',
                style: TextStyle(
                  fontFamily: 'HindMadurai',
                  fontSize: 14,
                  color: Color(0xFFE5E5E5), // Dodaj kolor tekstu z theme
                ),
              ),
              onTap: () {
                // Naviguj do strony Polityki prywatności
              },
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'ver 1.0',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPdfViewer(BuildContext context, io.File file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Polityka prywatności'),
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
}
