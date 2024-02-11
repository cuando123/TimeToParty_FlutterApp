import 'dart:math';

import 'package:flutter/material.dart';
import '../app_lifecycle/responsive_sizing.dart';

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
        stops: const [0.0, 0.46, 1.0],
        colors: const [
          Color(0xff1E1E1E),
          Color(0xff24173C),
          Color(0xff674D80),
        ],
      );
  Gradient get drawerGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [
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
  Color get yellowInd => const Color(0xFFF8EC7D);
  Color get yellowIndBorder => const Color(0xFFFFC344);
}

class LogoWidget_notitle extends StatelessWidget {
  const LogoWidget_notitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height < 650 ? 1 : ResponsiveSizing.scaleHeight(context, 20)),
      child: Column(
        children: [
          Image.asset(
            'assets/time_to_party_assets/all_stars_title.png',
            width: ResponsiveSizing.scaleWidth(context, 290),
            height: ResponsiveSizing.scaleHeight(context, 146),
          ),
        ],
      ),
    );
  }
}

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height < 650 ? 1 : ResponsiveSizing.scaleHeight(context, 20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          Image.asset(
            'assets/time_to_party_assets/all_stars_title.png',
            width: ResponsiveSizing.scaleWidth(context, 290),
            //height: ResponsiveText.scaleHeight(context, 146),
          ),
          SizedBox(height: 10),
          Image.asset(
            alignment: Alignment.centerLeft,
            'assets/time_to_party_assets/time_to_party_logo.png',
            width: ResponsiveSizing.scaleWidth(context, 300),
            //height: ResponsiveSizing.scaleHeight(context, 134),
          ),
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
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.disabledColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonTheme = ElevatedButtonTheme.of(context);
    final style = this.style ?? buttonTheme.style ?? theme.elevatedButtonTheme.style ?? theme.textButtonTheme.style;

    final effectiveStyle =
        onPressed != null ? style : style?.copyWith(backgroundColor: MaterialStateProperty.all(disabledColor));

    return ElevatedButton(
      onPressed: onPressed,
      style: effectiveStyle,
      child: child,
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

  ImageModel(
      {required this.assetName,
      required this.topPercentage,
      required this.leftPercentage,
      required this.widthPercentage,
      required this.heightPercentage,
      required this.rotation});
}

class CustomBackground extends StatefulWidget {
  final Widget? child;

  const CustomBackground({super.key, this.child});

  @override
  _CustomBackgroundState createState() => _CustomBackgroundState();
}

class _CustomBackgroundState extends State<CustomBackground> {
  List<ImageModel>? chosenLayout;
  List<double>? chosenRotations;

  final List<ImageModel> layout1 = [
    ImageModel(
        assetName: 'assets/time_to_party_assets/sheet_vector.png',
        topPercentage: 60, // 5% wysokości ekranu
        leftPercentage: 80, // 10% szerokości ekranu
        widthPercentage: 10,
        heightPercentage: 10,
        rotation: pi),
    ImageModel(
        assetName: 'assets/time_to_party_assets/masks_vector.png',
        topPercentage: 55, // 5% wysokości ekranu
        leftPercentage: 7, // 10% szerokości ekranu
        widthPercentage: 10,
        heightPercentage: 10,
        rotation: pi),
    ImageModel(
        assetName: 'assets/time_to_party_assets/grey_star.png',
        topPercentage: 15, // 5% wysokości ekranu
        leftPercentage: 25, // 10% szerokości ekranu
        widthPercentage: 10,
        heightPercentage: 10,
        rotation: pi),
    ImageModel(
        assetName: 'assets/time_to_party_assets/grey_star.png',
        topPercentage: 85, // 5% wysokości ekranu
        leftPercentage: 80, // 10% szerokości ekranu
        widthPercentage: 10,
        heightPercentage: 10,
        rotation: pi),
    ImageModel(
        assetName: 'assets/time_to_party_assets/microphone_vector.png',
        topPercentage: 70, // 5% wysokości ekranu
        leftPercentage: 5, // 10% szerokości ekranu
        widthPercentage: 6,
        heightPercentage: 6,
        rotation: pi),
    ImageModel(
        assetName: 'assets/time_to_party_assets/letters_vector.png',
        topPercentage: 15, // 5% wysokości ekranu
        leftPercentage: 65, // 10% szerokości ekranu
        widthPercentage: 10,
        heightPercentage: 10,
        rotation: pi),
  ];

  final List<ImageModel> layout2 = [
    ImageModel(
        assetName: 'assets/time_to_party_assets/sheet_vector.png',
        topPercentage: 80, // 5% wysokości ekranu
        leftPercentage: 8, // 10% szerokości ekranu
        widthPercentage: 10,
        heightPercentage: 10,
        rotation: pi),
    ImageModel(
        assetName: 'assets/time_to_party_assets/masks_vector.png',
        topPercentage: 58, // 5% wysokości ekranu
        leftPercentage: 80, // 10% szerokości ekranu
        widthPercentage: 10,
        heightPercentage: 10,
        rotation: pi),
    ImageModel(
        assetName: 'assets/time_to_party_assets/grey_star.png',
        topPercentage: 58, // 5% wysokości ekranu
        leftPercentage: 15, // 10% szerokości ekranu
        widthPercentage: 10,
        heightPercentage: 10,
        rotation: pi),
    ImageModel(
        assetName: 'assets/time_to_party_assets/grey_star.png',
        topPercentage: 85, // 5% wysokości ekranu
        leftPercentage: 80, // 10% szerokości ekranu
        widthPercentage: 10,
        heightPercentage: 10,
        rotation: pi),
    ImageModel(
        assetName: 'assets/time_to_party_assets/microphone_vector.png',
        topPercentage: 15, // 5% wysokości ekranu
        leftPercentage: 65, // 10% szerokości ekranu
        widthPercentage: 6,
        heightPercentage: 6,
        rotation: pi),
    ImageModel(
        assetName: 'assets/time_to_party_assets/letters_vector.png',
        topPercentage: 15, // 5% wysokości ekranu
        leftPercentage: 20, // 10% szerokości ekranu
        widthPercentage: 10,
        heightPercentage: 10,
        rotation: pi),
  ];

  final List<ImageModel> layout3 = [
    ImageModel(
        assetName: 'assets/time_to_party_assets/sheet_vector.png',
        topPercentage: 20, // 5% wysokości ekranu
        leftPercentage: 70, // 10% szerokości ekranu
        widthPercentage: 10,
        heightPercentage: 10,
        rotation: pi),
    ImageModel(
        assetName: 'assets/time_to_party_assets/masks_vector.png',
        topPercentage: 15, // 5% wysokości ekranu
        leftPercentage: 20, // 10% szerokości ekranu
        widthPercentage: 12,
        heightPercentage: 12,
        rotation: pi),
    ImageModel(
        assetName: 'assets/time_to_party_assets/grey_star.png',
        topPercentage: 60, // 5% wysokości ekranu
        leftPercentage: 15, // 10% szerokości ekranu
        widthPercentage: 10,
        heightPercentage: 10,
        rotation: pi),
    ImageModel(
        assetName: 'assets/time_to_party_assets/grey_star.png',
        topPercentage: 60, // 5% wysokości ekranu
        leftPercentage: 80, // 10% szerokości ekranu
        widthPercentage: 12,
        heightPercentage: 12,
        rotation: pi),
    ImageModel(
        assetName: 'assets/time_to_party_assets/microphone_vector.png',
        topPercentage: 90, // 5% wysokości ekranu
        leftPercentage: 85, // 10% szerokości ekranu
        widthPercentage: 6,
        heightPercentage: 6,
        rotation: pi),
    ImageModel(
        assetName: 'assets/time_to_party_assets/letters_vector.png',
        topPercentage: 85, // 5% wysokości ekranu
        leftPercentage: 10, // 10% szerokości ekranu
        widthPercentage: 10,
        heightPercentage: 10,
        rotation: pi),
  ];

  @override
  void initState() {
    super.initState();
    // Losowanie jednego z trzech układów
    Random random = Random();
    int layoutIndex = random.nextInt(3); // losuje 0, 1 lub 2
    print('chosen layout $layoutIndex');
    switch (layoutIndex) {
      case 0:
        chosenLayout = layout1;
        break;
      case 1:
        chosenLayout = layout2;
        break;
      case 2:
        chosenLayout = layout3;
        break;
      default:
        chosenLayout = layout1; // Domyślna wartość, na wszelki wypadek.
        break;
    }
    chosenRotations = chosenLayout!.map((imageModel) {
      return (random.nextDouble() * 2 - 1) * imageModel.rotation;
    }).toList();
  }

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
        if (widget.child != null) widget.child!,
      ],
    );
  }

  List<Widget> _buildRandomImages(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return chosenLayout!.asMap().entries.map((entry) {
      int index = entry.key;
      ImageModel imageModel = entry.value;

      double rotation = chosenRotations![index];

      return Positioned(
        top: imageModel.topPercentage * screenSize.height / 100,
        left: imageModel.leftPercentage * screenSize.width / 100,
        child: Transform.rotate(
          angle: rotation,
          child: SizedBox(
            width: imageModel.widthPercentage * screenSize.width / 100,
            height: imageModel.heightPercentage * screenSize.height / 100,
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.1), BlendMode.dstIn),
              child: Image.asset(
              imageModel.assetName
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}
