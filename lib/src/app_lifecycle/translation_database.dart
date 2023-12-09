import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
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

    final queryResult = await database.rawQuery('SELECT key, string_value FROM Menu_translations WHERE language = ?', [language]);

    final translationsMap = <String, String>{};
    for (final row in queryResult) {
      translationsMap[row['key'] as String]  = row['string_value'] as String;
    }
    return translationsMap;
  }

  Future<Map<String, String>> fetchWordsByLanguage(String language) async {
    Database database = await initDatabase();
    print("Lanugage: $language");

    final maps = await database.query(
      'Cards',
      columns: ['Key', 'words'], // pobieramy kolumny "Key" oraz "words"
      where: 'language = ?',
      whereArgs: [language],
    );

    // Konwersja List<Map<String, dynamic>> na mapę, gdzie kluczem jest "Key" a wartością "words"
    Map<String, String> wordsMap = {};
    for (final row in maps) {
      wordsMap[row['Key'] as String] = row['words'] as String;
    }
    print('wordsmap: $wordsMap');

    return wordsMap;
  }

}