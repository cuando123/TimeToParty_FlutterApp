import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:game_template/src/main_menu/main_menu_screen.dart';

class InstructionDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        textTheme: ThemeData().textTheme.copyWith(
              titleLarge: TextStyle(
                  fontFamily: 'HindMadurai',
                  color: Color(0xFFCB48EF),
                fontSize: 24,
              ),
              bodyLarge: TextStyle(fontSize: 16),
            ),
      ),
      child: Builder(
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(child: Text('Zasady gry')),
            content: Container(
              width: double.maxFinite,
              child: Column(
                children: [
                  SvgPicture.asset(
                      'assets/time_to_party_assets/line_instruction_screen.svg'),
                  SizedBox(height: 16), // gap
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Text('Treść instrukcji gry'),
                      ],
                    ),
                  ), // Dodaj swoją linię SVG tutaj
                ],
              ),
            ),
            actionsPadding: EdgeInsets.symmetric(
                horizontal: 20), // Zmniejsz obramowanie przycisków
            actions: [
              Expanded(
                child: Center(
                  heightFactor: 1.5,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFCB48EF), // color
                      foregroundColor: Colors.white, // textColor
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      minimumSize: Size(MediaQuery.of(context).size.width * 0.5,
                          MediaQuery.of(context).size.height * 0.05),
                      textStyle:
                          TextStyle(fontFamily: 'HindMadurai', fontSize: 20),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
