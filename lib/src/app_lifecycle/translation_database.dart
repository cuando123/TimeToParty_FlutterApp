import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TranslationDatabase {
  Future<Database> initDatabase() async {
    var dbPath = join(await getDatabasesPath(), 'db_awesome.db');

      ByteData data = await rootBundle.load("assets/time_to_party_assets/db_awesome.db");
      List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(dbPath).writeAsBytes(bytes, flush: true);

    return openDatabase(dbPath);
  }
  Future<String> getTranslationText(String key, String languageKey) async { // Dodano parametr key
    Database database = await initDatabase(); // Użyj metody initDatabase

    // Zapytanie SQL do pobrania tekstu dla danego klucza języka
    String query = 'SELECT string_value FROM Menu_translations WHERE key = ? AND language = ?';
    List<String> queryArgs = [key, languageKey]; // Zaktualizowano queryArgs

    // Wykonaj zapytanie
    List<Map<String, dynamic>> result = await database.rawQuery(query, queryArgs);

    // Zamknij bazę danych
    await database.close();

    // Sprawdź, czy zwrócono jakieś wyniki
    if (result.isNotEmpty) {
      // Pobierz pierwszy wynik
      Map<String, dynamic> row = result.first;

      // Zwróć wartość tekstu
      return row['string_value'] as String;
    }

    // Jeśli nie znaleziono tekstu, zwróć pusty ciąg znaków
    return '';
  }
}