import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:game_template/src/app_lifecycle/responsive_sizing.dart';

import '../style/palette.dart';

class TripleButtonWin extends StatelessWidget {
  final String? svgAsset;
  final String? imageAsset;
  final IconData? iconData;
  final VoidCallback onPressed;

  const TripleButtonWin({
    super.key,
    this.svgAsset,
    this.imageAsset,
    this.iconData,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ResponsiveSizing.scaleWidth(context, 85),
      height: ResponsiveSizing.scaleHeight(context, 60),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Palette().pink,
            Palette().pink,
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Color(0xFF5E0EAD),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            offset: Offset(4, 4),
            blurRadius: 10,
            spreadRadius: -3,
          ),
          BoxShadow(
            color: Colors.deepPurpleAccent.withOpacity(0.7),
            offset: Offset(-6, -4),
            blurRadius: 10,
            spreadRadius: -3,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          splashColor: Colors.white.withOpacity(0.5), // Kolor falowania
          highlightColor: Colors.pinkAccent.withOpacity(0.5), // Kolor podczas wciśnięcia
          child: Center(
            child: _buildButtonContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (svgAsset != null) {
      return SvgPicture.asset(svgAsset!, width: 32, height: 32);
    } else if (imageAsset != null) {
      return Image.asset(imageAsset!, width: 32, height: 32);
    } else if (iconData != null) {
      return Icon(iconData, color: Colors.white, size: 32);
    } else {
      return SizedBox.shrink(); // Jeśli wszystkie są null, nie pokazuj niczego
    }
  }
}
