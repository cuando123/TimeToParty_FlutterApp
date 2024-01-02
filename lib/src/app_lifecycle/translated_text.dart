import 'package:flutter/material.dart';
import 'package:game_template/src/app_lifecycle/responsive_sizing.dart';
import 'package:provider/provider.dart';
import '../app_lifecycle/TranslationProvider.dart';

Widget translatedText(BuildContext context, String translationKey, double fontSize, Color textColor, {TextAlign? textAlign, bool useShadows = false}) {
  return Consumer<TranslationProvider>(
    builder: (context, translationProvider, child) {
      String translated = translationProvider.getTranslationText(translationKey);
      return letsText(context, translated, fontSize, textColor, textAlign: textAlign, useShadows: useShadows);
    },
  );
}

Widget wordText(BuildContext context, String wordKey, double fontSize, Color textColor, {TextAlign? textAlign, int? index}) {
  return Consumer<TranslationProvider>(
    builder: (context, translationProvider, child) {
      String word = translationProvider.getWord(wordKey);
      List<String> words = word.split(';'); // Dzielenie tekstu na słowa

      if (index != null && index >= 0 && index < words.length) {
        // Zwracanie widgetu Text tylko dla wybranego słowa
        return letsText(context, words[index], fontSize, textColor, textAlign: textAlign);
      } else {
        // Zwracanie wszystkich słów, jeśli indeks nie jest podany lub jest nieprawidłowy
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (String word in words)
              letsText(context, word, fontSize, textColor, textAlign: textAlign),
          ],
        );
      }
    },
  );
}

List<String> getWordsList(BuildContext context, String wordKey) {
  TranslationProvider translationProvider = Provider.of<TranslationProvider>(context, listen: false);
  String word = translationProvider.getWord(wordKey);
  List<String> words = word.split(';'); // Dzielenie tekstu na słowa
  return words;
}

String getTranslatedString(BuildContext context, String translationKey) {
  TranslationProvider translationProvider = Provider.of<TranslationProvider>(context, listen: false);
  return translationProvider.getTranslationText(translationKey);
}

TextSpan translatedTextSpan(BuildContext context, String translationKey, double fontSize, Color textColor, {TextAlign? textAlign}) {
  String translated = Provider.of<TranslationProvider>(context, listen: false).getTranslationText(translationKey);
  return TextSpan(
    text: translated,
    style: TextStyle(fontSize: fontSize, color: textColor, fontFamily: 'HindMadurai'),
  );
}

Text letsText(BuildContext context, String text, double fontSize, Color textColor, {TextAlign? textAlign, bool useShadows = false}) {
  return Text(
    text,
    style: TextStyle(
      fontFamily: 'HindMadurai',
      fontSize: ResponsiveSizing.scaleHeight(context, fontSize),
      color: textColor,
      shadows: useShadows ? [
        Shadow(
          offset: Offset(1.0, 1.0),
          blurRadius: 3.0,
          color: Colors.black.withOpacity(0.5),
        ),
      ] : [],
    ),
    textAlign: textAlign,
  );
}