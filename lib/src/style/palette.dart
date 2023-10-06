import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:game_template/src/style/palette.dart';
import 'package:game_template/src/style/palette.dart';
import '../app_lifecycle/translated_text.dart';

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
  Color get nothing => const Color(0xFF391D50);
  Color get borderSpinningWheel => const Color(0xFF3A3114);
  Color get grey => const Color(0xFF5A5C60);
  Color get darkGrey => const Color(0xFF3D3E41);
}

class LogoWidget_notitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height < 650
              ? 1
              : ResponsiveSizing.scaleHeight(context, 20)),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/time_to_party_assets/all_stars_title.svg',
            width: ResponsiveSizing.scaleWidth(context, 261),
            height: ResponsiveSizing.scaleHeight(context, 126),
          ),
        ],
      ),
    );
  }
}

class LogoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height < 650
              ? 1
              : ResponsiveSizing.scaleHeight(context, 20)),
      child: Column(
        children: [
          SizedBox(height: 30),
          SvgPicture.asset(
            'assets/time_to_party_assets/all_stars_title.svg',
            width: ResponsiveSizing.scaleWidth(context, 300),
            //height: ResponsiveText.scaleHeight(context, 146),
          ),
          SizedBox(height: 10),
          SvgPicture.asset(
            'assets/time_to_party_assets/time_to_party_logo.svg',
            width: ResponsiveSizing.scaleWidth(context, 257),
            //height: ResponsiveSizing.scaleHeight(context, 134),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final Color disabledColor;

  const CustomElevatedButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.style,
    this.disabledColor = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonTheme = ElevatedButtonTheme.of(context);
    final style = this.style ?? buttonTheme.style ?? theme.elevatedButtonTheme.style ?? theme.textButtonTheme.style;

    final effectiveStyle = onPressed != null ? style : style?.copyWith(backgroundColor: MaterialStateProperty.all(disabledColor));

    return ElevatedButton(
      onPressed: onPressed,
      child: child,
      style: effectiveStyle,
    );
  }
}

class ImageModel {
  final String assetName;
  final double topPercentage;
  final double leftPercentage;
  final double widthPercentage;
  final double heightPercentage;
  final double rotation;

  ImageModel({
    required this.assetName,
    required this.topPercentage,
    required this.leftPercentage,
    required this.widthPercentage,
    required this.heightPercentage,
    required this.rotation
  });
}


class CustomBackground extends StatelessWidget {
  final Widget? child;

  CustomBackground({this.child});

  final List<ImageModel> layout1 = [
    ImageModel(
        assetName: 'assets/time_to_party_assets/sheet_vector.svg',
        topPercentage: 70, // 5% wysokości ekranu
        leftPercentage: 80, // 10% szerokości ekranu
        widthPercentage: 10,
        heightPercentage: 10,
        rotation: pi
    ),
    ImageModel(
        assetName: 'assets/time_to_party_assets/masks_vector.svg',
        topPercentage: 60, // 5% wysokości ekranu
        leftPercentage: 40, // 10% szerokości ekranu
        widthPercentage: 10,
        heightPercentage: 10,
        rotation: pi
    ),
    ImageModel(
        assetName: 'assets/time_to_party_assets/grey_star.svg',
        topPercentage: 10, // 5% wysokości ekranu
        leftPercentage: 20, // 10% szerokości ekranu
        widthPercentage: 10,
        heightPercentage: 10,
        rotation: pi
    ),
    ImageModel(
        assetName: 'assets/time_to_party_assets/grey_star.svg',
        topPercentage: 90, // 5% wysokości ekranu
        leftPercentage: 10, // 10% szerokości ekranu
        widthPercentage: 15,
        heightPercentage: 15,
        rotation: pi
    ),
    // ... pozostałe obrazki
  ];

  final List<ImageModel> layout2 = [
    ImageModel(
        assetName: 'assets/time_to_party_assets/masks_vector.svg',
        topPercentage: 5, // 5% wysokości ekranu
        leftPercentage: 10, // 10% szerokości ekranu
        widthPercentage: 20,
        heightPercentage: 20,
        rotation: pi
    ),
    ImageModel(
        assetName: 'assets/time_to_party_assets/grey_star.svg',
        topPercentage: 5, // 5% wysokości ekranu
        leftPercentage: 10, // 10% szerokości ekranu
        widthPercentage: 20,
        heightPercentage: 20,
        rotation: pi
    ),
    // ... pozostałe obrazki
  ];

  final List<ImageModel> layout3 = [
    ImageModel(
        assetName: 'assets/time_to_party_assets/masks_vector.svg',
        topPercentage: 5, // 5% wysokości ekranu
        leftPercentage: 10, // 10% szerokości ekranu
        widthPercentage: 10,
        heightPercentage: 10,
        rotation: pi/4
    ),
    ImageModel(
        assetName: 'assets/time_to_party_assets/grey_star.svg',
        topPercentage: 5, // 5% wysokości ekranu
        leftPercentage: 10, // 10% szerokości ekranu
        widthPercentage: 20,
        heightPercentage: 20,
        rotation: pi/4
    ),
    // ... pozostałe obrazki
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Tło gradientowe
        Container(
          decoration: BoxDecoration(
            gradient: Palette().backgroundLoadingSessionGradient,
          ),
        ),
        // Obrazki
        ..._buildRandomImages(context),
        // Dziecko (jeśli zostało dostarczone)
        if (child != null) child!,
      ],
    );
  }

  List<Widget> _buildRandomImages(BuildContext context) {
    // Losowanie jednego z trzech układów
    Random random = Random();
    Size screenSize = MediaQuery.of(context).size;
    int chosenLayout =0; // losuje 0, 1 lub 2
    //int chosenLayout = random.nextInt(3); // losuje 0, 1 lub 2
    print('chosen layout $chosenLayout');
    List<ImageModel> layout;
    switch (chosenLayout) {
      case 0:
        layout = layout1;
        break;
      case 1:
        layout = layout2;
        break;
      case 2:
        layout = layout3;
        break;
      default:
        layout = layout1;  // Domyślna wartość, na wszelki wypadek.
        break;
    }

    // Konwersja wybranego układu na listę widgetów
    return layout.map((imageModel) {
      double randomRotation = (random.nextDouble() * 2 - 1) * imageModel.rotation;
      return Positioned(
        top: imageModel.topPercentage * screenSize.height / 100,
        left: imageModel.leftPercentage * screenSize.width / 100,
        child: Transform.rotate(
          angle: randomRotation,
          child: SizedBox(
            width: imageModel.widthPercentage * screenSize.width / 100,
            height: imageModel.heightPercentage * screenSize.height / 100,
            child: SvgPicture.asset(
              imageModel.assetName,
              colorFilter: ColorFilter.mode(Colors.white10, BlendMode.dstIn),
            ),
          ),
        ),
      );
    }).toList();
  }
}
