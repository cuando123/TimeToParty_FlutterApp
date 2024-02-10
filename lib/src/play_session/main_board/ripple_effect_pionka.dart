import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PionekWithRipple extends StatelessWidget {
  final String assetPath;
  final Animation<double> animation;

  double screenWidth;

  PionekWithRipple({super.key, required this.assetPath, required this.animation, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        SvgPicture.asset(assetPath, width: screenWidth / 15.09, height: screenWidth / 15.09),
        Positioned(left: -50, top: -50, right: -50, bottom: -50, child: RippleEffect(animation: animation)),
      ],
    );
  }
}

class RippleEffect extends StatelessWidget {
  final Animation<double> animation;

  const RippleEffect({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 20 + (animation.value * 100), // zakładając, że początkowa wielkość pionka to 50
              height: 20 + (animation.value * 100),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.yellow.withOpacity(1 - animation.value),
              ),
            )
          ],
        );
      },
    );
  }
}
