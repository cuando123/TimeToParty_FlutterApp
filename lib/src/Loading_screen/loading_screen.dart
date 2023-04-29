import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui';

import 'package:flutter_svg/flutter_svg.dart';
import '../style/palette.dart';

class LoaderWidget extends StatelessWidget {
  const LoaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final mediaQueryData = MediaQuery.of(context);
    final screenHeight = mediaQueryData.size.height;
    final screenWidth = mediaQueryData.size.width;
    print("Pixel Ratio: $pixelRatio");
    print("Screen Height: $screenHeight");
    print("Screen Width: $screenWidth");
    final StarBoxWidth = 60 / screenWidth * mediaQueryData.size.width;
    final StarBoxHeight = 60 / screenHeight * mediaQueryData.size.height;
    final TextBoxWidth = 281 / screenWidth * mediaQueryData.size.width;
    final TextBoxHeight = 146 / screenHeight * mediaQueryData.size.height;
    final TextBoxWidthStars = 307 / screenWidth * mediaQueryData.size.width;
    final TextBoxHeightStars = 144 / screenHeight * mediaQueryData.size.height;
    return Container(
      decoration: BoxDecoration(
        gradient: Palette().backgroundLoadingSessionGradient,
      ),
      child: Stack(children: <Widget>[
        // blue star
        Positioned(
          top: 234 / screenHeight * mediaQueryData.size.height,
          left: 53 / screenWidth * mediaQueryData.size.width,
          child: Transform.rotate(
            angle: -20 * 3.14 / 180,
            child: Container(
              width: StarBoxWidth,
              height: StarBoxHeight,
              child: SvgPicture.asset(
                'assets/time_to_party_assets/blue_star.svg',
              ),
            ),
          ),
        ),
        // yellow star
        Positioned(
          top: 205 / screenHeight * mediaQueryData.size.height,
          left: 103 / screenWidth * mediaQueryData.size.width,
          child: Transform.rotate(
            angle: -20 * 3.14 / 180,
            child: Container(
              width: StarBoxWidth,
              height: StarBoxHeight,
              child: SvgPicture.asset(
                'assets/time_to_party_assets/yellow_star.svg',
              ),
            ),
          ),
        ),
        // grey star
        Positioned(
          top: 208 / screenHeight * mediaQueryData.size.height,
          left: 167 / screenWidth * mediaQueryData.size.width,
          child: Transform.rotate(
            angle: -20 * 3.14 / 180,
            child: Container(
              width: StarBoxWidth,
              height: StarBoxHeight,
              child: SvgPicture.asset(
                'assets/time_to_party_assets/grey_star.svg',
              ),
            ),
          ),
        ),
        // black star
        Positioned(
          top: 191 / screenHeight * mediaQueryData.size.height,
          left: 215 / screenWidth * mediaQueryData.size.width,
          child: Transform.rotate(
            angle: -20 * 3.14 / 180,
            child: Container(
              width: StarBoxWidth,
              height: StarBoxHeight,
              child: SvgPicture.asset(
                'assets/time_to_party_assets/black_star.svg',
              ),
            ),
          ),
        ),
        // pink star
        Positioned(
          top: 205 / screenHeight * mediaQueryData.size.height,
          left: 286 / screenWidth * mediaQueryData.size.width,
          child: Transform.rotate(
            angle: -20 * 3.14 / 180,
            child: Container(
              width: StarBoxWidth,
              height: StarBoxHeight,
              child: SvgPicture.asset(
                'assets/time_to_party_assets/pink_star.svg',
              ),
            ),
          ),
        ),
        // title logo
        Positioned(
          top: 285 / mediaQueryData.size.height * screenHeight,
          left: 59 / mediaQueryData.size.width * screenWidth,
          child: Container(
            width: TextBoxWidth,
            height: TextBoxHeight,
            child: SvgPicture.asset(
              'assets/time_to_party_assets/time_to_party_logo.svg',
            ),
          ),
        ),
        // Loading bar slider

       Stack(children: [
         Positioned(
             top: 510 / mediaQueryData.size.height * screenHeight,
             left: 20,
             child: LoadingBar()),
         Positioned(
           top: 550 / mediaQueryData.size.height * screenHeight,
           left: 0,
           child: Container(
             width: screenWidth,
             height: 10,
             child: ClipRect(
               child: BackdropFilter(
                 filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                 child: Container(
                   decoration: BoxDecoration(
                     gradient: LinearGradient(
                       colors: [
                         Color.fromRGBO(87, 33, 183, 1.0),
                         Color.fromRGBO(214, 104, 205, 0.9),
                       ],
                       begin: Alignment.topLeft,
                       end: Alignment.bottomRight,
                     ),
                   ),
                 ),
               ),
             ),
           ),
         ),
       ]
       ),
        // stars blur
        Stack(children: <Widget>[
          Positioned(
            top: 285 / mediaQueryData.size.height * screenHeight,
            left: 43 / mediaQueryData.size.width * screenWidth,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(
                width: TextBoxWidthStars,
                height: TextBoxHeightStars,
                child: SvgPicture.asset(
                    'assets/time_to_party_assets/time_to_party_logo_stars.svg'),
              ),
            ),
          ),
        ]),
      ]),
    );
  }
}

class LoadingBar extends StatefulWidget {
  @override
  _LoadingBarState createState() => _LoadingBarState();
}

class _LoadingBarState extends State<LoadingBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final screenHeight = mediaQueryData.size.height;
    final screenWidth = mediaQueryData.size.width;
    return Container(
      width: screenWidth,
      height: 1.81,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 328,
              height: 9.04,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(87, 33, 183, 1.0),
                    Color.fromRGBO(214, 104, 205, 0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(
                width: 328,
                height: 9.04,
                color: Colors.transparent,
              ),
            ),
          ),
          // Biały pasek
          Container(
            width: screenWidth - (0.1 * mediaQueryData.size.width),
            height: 1.81,
            color: Colors.white,
          ),
          // Przesuwający się pasek
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return ClipPath(
                clipper: _LoadingBarClipper(_animationController.value, barWidthRatio: 0.05),
              child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                 child: Container(
                  width: screenWidth - (0.1 * mediaQueryData.size.width),
                  height: 1.81,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(
                            67, 33, 183, 0.7), // Zmiana wartości "Opacity" na 0.7
                        Color.fromRGBO(
                            214, 104, 205, 0.7), // Zmiana wartości "Opacity" na 0.7
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LoadingBarClipper extends CustomClipper<Path> {
  final double progress;
  final double barWidthRatio; // Dodajemy nową zmienną

  _LoadingBarClipper(this.progress, {this.barWidthRatio = 0.25})
      : assert(progress >= 0 && progress <= 1),
        assert(barWidthRatio > 0 && barWidthRatio <= 1);

  @override
  Path getClip(Size size) {
    final path = Path();
    final barWidth = size.width * barWidthRatio;
    final startX = size.width * progress - barWidth;
    final endX = startX + size.width * barWidthRatio + barWidth; // Zaktualizuj wartość endX
    path.moveTo(startX, 0);
    path.lineTo(endX, 0);
    path.lineTo(endX, size.height);
    path.lineTo(startX, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
