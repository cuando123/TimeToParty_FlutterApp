import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../style/palette.dart';

class CustomStyledButton extends StatelessWidget {
  final String? svgAsset;
  final String? imageAsset;
  final IconData? icon;
  final String text;
  final VoidCallback onPressed;

  const CustomStyledButton({
    super.key,
    this.svgAsset,
    this.imageAsset,
    this.icon,
    required this.text,
    required this.onPressed, 
  });

  @override
  Widget build(BuildContext context) {
    Widget leadingWidget;

    if (svgAsset != null) {
      leadingWidget = SvgPicture.asset(svgAsset!, width: 32, height: 32);
    } else if (imageAsset != null) {
      leadingWidget = Image.asset(imageAsset!, width: 32, height: 32);
    } else if (icon != null) {
      leadingWidget = Icon(icon, size: 32);
    } else {
      leadingWidget = SizedBox.shrink();
    }

    return ElevatedButton.icon(
      icon: leadingWidget,
      label: Text(
        text,
        style: TextStyle(
          fontFamily: 'HindMadurai',
          fontSize: 20,
          color: Palette().white,
        ),
        textAlign: TextAlign.center,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Palette().pink,
        foregroundColor: Palette().white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        minimumSize: Size(200, 51),
      ),
      onPressed: onPressed,
    );
  }
}
