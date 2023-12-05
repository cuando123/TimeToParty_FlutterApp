import 'package:flutter/material.dart';

import '../app_lifecycle/translated_text.dart';
import '../style/palette.dart';

class CustomStyledButton extends StatelessWidget {
  final IconData? icon;
  final String text;
  final VoidCallback onPressed;

  const CustomStyledButton({super.key, required this.icon, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
        icon: icon != null ? Icon(icon, size: 32) : SizedBox.shrink(),
      label: Text(
        text,
        style: TextStyle(
          fontFamily: 'HindMadurai',
          fontSize: ResponsiveSizing.scaleHeight(context, 20),
          color: Palette().white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Palette().pink,
        foregroundColor: Palette().white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        minimumSize: Size(
          ResponsiveSizing.scaleWidth(context, 200),
          ResponsiveSizing.responsiveHeightWithCondition(context, 51, 41, 650),
        ),
      ),
      onPressed: onPressed,
    );
  }
}
