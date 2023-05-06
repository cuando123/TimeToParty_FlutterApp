import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_lifecycle/TranslationProvider.dart';

Widget translatedText(BuildContext context, String translationKey, double fontSize, Color textColor) {
  return Consumer<TranslationProvider>(
    builder: (context, translationProvider, child) {
      String translated = translationProvider.getTranslationText(translationKey);
      return letsText(context, translated, fontSize, textColor);
    },
  );
}

Future<String> getTranslatedString(BuildContext context, String translationKey) async {
  TranslationProvider translationProvider = Provider.of<TranslationProvider>(context, listen: false);
  dynamic translation = await translationProvider.getTranslationText(translationKey);
  return translation as String;
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

class ResponsiveText {

  static double referenceWidth = 360;
  static double referenceHeight = 800;

  static double scaleWidth(BuildContext context, double width) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (screenWidth / referenceWidth) * width;
  }

  static double scaleHeight(BuildContext context, double height) {
    final screenHeight = MediaQuery.of(context).size.height;
    return (screenHeight / referenceHeight) * height;
  }

  static Text customText(BuildContext context, String text, Color textColor,
      TextAlign textAlign, double fontSize) {
    return Text(
      text,
      style: TextStyle(
        color: textColor,
        fontFamily: 'HindMadurai',
        fontSize: fontSize,
        fontWeight: FontWeight.normal,
      ),
      textAlign: textAlign,
    );
  }
}