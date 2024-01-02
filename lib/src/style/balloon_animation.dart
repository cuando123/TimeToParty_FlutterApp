import 'package:flutter/cupertino.dart';
import 'dart:math';

import '../app_lifecycle/responsive_sizing.dart';
import '../app_lifecycle/translated_text.dart';

class BalloonAnimation extends StatefulWidget {
  const BalloonAnimation({super.key});

  @override
  _BalloonAnimationState createState() => _BalloonAnimationState();
}

class _BalloonAnimationState extends State<BalloonAnimation> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers = [];
  late final List<Animation<double>> _animations = [];
  late Random random = Random();

  // Add your balloon image paths here
  List<String> balloonImages = [
    'assets/time_to_party_assets/balloons/balloon_blue.png',
    'assets/time_to_party_assets/balloons/balloon_green.png',
    'assets/time_to_party_assets/balloons/balloon_pink.png',
    'assets/time_to_party_assets/balloons/balloon_red.png',
    'assets/time_to_party_assets/balloons/balloon_yellow.png',
  ];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 5; i++) { // Create 5 balloons
      var controller = AnimationController(
        duration: Duration(seconds: 1+i), // each balloon will have slightly longer duration
        vsync: this,
      )..forward();
      _controllers.add(controller);

      var animation = CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOutSine,
      );
      _animations.add(animation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _animations.asMap().entries.map((entry) {
        int idx = entry.key;
        Animation<double> animation = entry.value;
        double startPos = random.nextDouble(); // Random start position
        return Positioned(
          bottom: 0,
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.translate(
                  offset: Offset(
                    startPos * MediaQuery.of(context).size.width + (MediaQuery.of(context).size.width / 4) * sin(animation.value * 2 * pi),
                    -animation.value * MediaQuery.of(context).size.height,
                  ),
                  child: Transform.rotate(
                    angle: sin(animation.value * 2 * pi) / 4,
                    child: child,
                  )
              );
            },
            child: Image.asset(balloonImages[idx % balloonImages.length],
              height: ResponsiveSizing.scaleHeight(context, 56),),
          ),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}