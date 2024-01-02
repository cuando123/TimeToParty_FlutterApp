import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_lifecycle/responsive_sizing.dart';
import '../app_lifecycle/translated_text.dart';

class CustomStyledButton extends StatelessWidget {
  final String? svgAsset;
  final String? imageAsset;
  final IconData? icon;
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final double width;
  final double height;
  final double fontSize;

  const CustomStyledButton({
    super.key,
    this.svgAsset,
    this.imageAsset,
    this.icon,
    required this.text,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    this.width = 200, // Domyślna szerokość
    this.height = 45, // Domyślna wysokość
    this.fontSize = 20, // Domyślny rozmiar czcionki
  });

  @override
  Widget build(BuildContext context) {
    double iconSize = ResponsiveSizing.scaleHeight(context, 32); // Poprawiona linia
    double imageSize = ResponsiveSizing.scaleHeight(context, 28);

    Widget leadingWidget;

    if (svgAsset != null) {
      leadingWidget = SvgPicture.asset(svgAsset!, width: imageSize, height: imageSize);
    } else if (imageAsset != null) {
      leadingWidget = Image.asset(imageAsset!, width: imageSize, height: imageSize);
    } else if (icon != null) {
      leadingWidget = Icon(icon, size: iconSize, color: foregroundColor);
    } else {
      leadingWidget = SizedBox.shrink();
    }

    return ElevatedButton.icon(
      icon: leadingWidget,
      label: Text(
        text,
        style: TextStyle(
          fontFamily: 'HindMadurai',
          fontSize: fontSize,
          color: foregroundColor,
        ),
        textAlign: TextAlign.center,
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: foregroundColor, backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        minimumSize: Size(
            ResponsiveSizing.scaleWidth(context, width),
            ResponsiveSizing.responsiveHeightWithCondition(context, 50, height, 650)
        ),
      ),
      onPressed: onPressed,
    );
  }
}