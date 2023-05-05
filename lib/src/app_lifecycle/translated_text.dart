import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_lifecycle/TranslationProvider.dart';

Widget translatedText(String translationKey) {
  return Consumer<TranslationProvider>(
    builder: (context, translationProvider, child) {
      return FutureBuilder<String>(
        future: translationProvider.getTranslationText(translationKey),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Text(snapshot.data ?? '');
          } else {
            return CircularProgressIndicator();
          }
        },
      );
    },
  );
}