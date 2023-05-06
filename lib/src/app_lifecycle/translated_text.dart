import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_lifecycle/TranslationProvider.dart';

Widget translatedText(BuildContext context, String translationKey, double fontSize, Color textColor, {TextAlign? textAlign}) {
  return Consumer<TranslationProvider>(
    builder: (context, translationProvider, child) {
      String translated = translationProvider.getTranslationText(translationKey);
      return letsText(context, translated, fontSize, textColor, textAlign: textAlign);
    },
  );
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

Text letsText(BuildContext context, String text, double fontSize, Color textColor, {TextAlign? textAlign}) {
  return Text(
    text,
    style: TextStyle(
      fontFamily: 'HindMadurai',
      fontSize: ResponsiveText.scaleHeight(context, fontSize),
      color: textColor,
    ),
    textAlign: textAlign,
  );
}

class ResponsiveText {

  static double referenceWidth = 360;
  static double referenceHeight = 800;

  static double scaleWidth(BuildContext context, double width) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    return (screenWidth / referenceWidth) * width;
  }

  static double scaleHeight(BuildContext context, double height) {
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    return (screenHeight / referenceHeight) * height;
  }
}