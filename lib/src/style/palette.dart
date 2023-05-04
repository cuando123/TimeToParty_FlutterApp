
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A palette of colors to be used in the game.
///
/// The reason we're not going with something like Material Design's
/// `Theme` is simply that this is simpler to work with and yet gives
/// us everything we need for a game.
///
/// Games generally have more radical color palettes than apps. For example,
/// every level of a game can have radically different colors.
/// At the same time, games rarely support dark mode.
///
/// Colors taken from this fun palette:
/// https://lospec.com/palette-list/crayola84
///
/// Colors here are implemented as getters so that hot reloading works.
/// In practice, we could just as easily implement the colors
/// as `static const`. But this way the palette is more malleable:
/// we could allow players to customize colors, for example,
/// or even get the colors from the network.
class Palette {
  Color get pen => const Color(0xff1d75fb);
  Color get darkPen => const Color(0xFF0050bc);
  Color get redPen => const Color(0xFFd10841);
  Color get inkFullOpacity => const Color(0xff352b42);
  Color get ink => const Color(0xee352b42);
  Color get backgroundMain => Colors.transparent;
  Color get backgroundLevelSelection => const Color(0xffa2dcc7);
  Color get backgroundPlaySession => const Color(0xffffebb5);
  Color get backgroundTransparent => Colors.transparent;
  Gradient get backgroundLoadingSessionGradient => LinearGradient(
    begin: Alignment.bottomRight,
    end: Alignment.topLeft,
    stops: [0.0, 0.46, 1.0],
    colors: [
      Color(0xff1E1E1E),
      Color(0xff24173C),
      Color(0xff674D80),
    ],
  );
  Gradient get drawerGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF604779), // 0.0
      Color(0xFF2E1F46), // 0.5
      Color(0xFF1F1D23), // 1.0
    ],
  );
  Color get background4 => const Color(0xffffd7ff);
  Color get backgroundSettings => const Color(0xffbfc8e3);
  Color get trueWhite => const Color(0xffffffff);
  Color get pink => const Color(0xFFCB48EF);
  Color get white => const Color(0xFFE5E5E5);
  Color get bluegrey => const Color(0xFFB0B5E9);
  Color get menudark => const Color(0xFF221933);
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

class LogoWidget_notitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height < 650
              ? 1
              : ResponsiveText.scaleHeight(context, 20)),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/time_to_party_assets/all_stars_title.svg',
            width: ResponsiveText.scaleWidth(context, 261),
            height: ResponsiveText.scaleHeight(context, 126),
          ),
        ],
      ),);
  }
}