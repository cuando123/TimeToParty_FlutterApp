import 'dart:io';
import 'package:flutter/services.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class TranslationDatabase {
  Future<Database> initDatabase() async {
    var dbPath = join(await getDatabasesPath(), "db_awesome.db");

    ByteData data = await rootBundle.load("assets/time_to_party_assets/db_awesome.db");
    List<int> bytes =
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(dbPath).writeAsBytes(bytes, flush: true);

    return openDatabase(dbPath);
  }

  Future<Map<String, String>> getAllTranslationsForLanguage(String language) async {
    Database database = await initDatabase();

    final queryResult = await database.rawQuery(
        'SELECT key, string_value FROM Menu_translations WHERE language = ?', [language]);

    final translationsMap = <String, String>{};
    for (final row in queryResult) {
      translationsMap[row['key'] as String] = row['string_value'] as String;
    }
    return translationsMap;
  }

  Future<Map<String, String>> fetchWordsByLanguage(String language, bool isPurchased) async {
    Database database = await initDatabase();

    final maps = await database.query(
      'Cards',
      columns: ['Key', 'words'], // pobieramy kolumny "Key" oraz "words"
      where: isPurchased ? 'language = ?' : 'language = ? AND IsPurchased = "No"',
      whereArgs: [language],
    );

    Map<String, String> wordsMap = {};
    for (final row in maps) {
      wordsMap[row['Key'] as String] = row['words'] as String;
    }

   // print('Pobrano ${maps.length} rekordów dla języka $language, isPurchased: $isPurchased');
  //  await saveMapToFileAndSendEmail(wordsMap);

    return wordsMap;
  }
/*
  Future<void> saveMapToFileAndSendEmail(Map<String, String> wordsMap) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/wordsMap.txt');
    String content = wordsMap.entries.map((e) => '${e.key}: ${e.value}').join('\n');
    await file.writeAsString(content);
    print('Mapa słów zapisana do pliku: ${file.path}');

    String username = 'dawid.lubomski95@gmail.com'; // Użyj swojego adresu e-mail
    String password = 'tudscaaihjaeslaz'; // Użyj swojego hasła

    final smtpServer = gmail(username, password); // Tworzenie serwera SMTP dla Gmail

    // Tworzenie wiadomości e-mail
    final message = Message()
      ..from = Address(username)
      ..recipients.add('dawid.lubomski95@gmail.com') // Adres e-mail odbiorcy
      ..subject = 'Twoja mapa słów :: ${DateTime.now()}'
      ..text = 'Załączona jest twoja mapa słów.'
      ..attachments = [FileAttachment(file)]; // Załącz plik

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }*/
}