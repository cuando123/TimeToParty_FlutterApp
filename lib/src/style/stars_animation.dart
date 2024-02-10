import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_lifecycle/responsive_sizing.dart';

class StarsAnimation extends StatefulWidget {
  const StarsAnimation({super.key});

  @override
  _StarsAnimationState createState() => _StarsAnimationState();
}

class _StarsAnimationState extends State<StarsAnimation> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers = [];
  late final List<Animation<double>> _animations = [];
  late Random random = Random();

  List<String> StarsImages = [
    'assets/time_to_party_assets/blue_star.svg',
    'assets/time_to_party_assets/black_star.svg',
    'assets/time_to_party_assets/grey_star.svg',
    'assets/time_to_party_assets/pink_star.svg',
    'assets/time_to_party_assets/yellow_star.svg',
  ];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 5; i++) {
      // Create 5 Starss
      var controller = AnimationController(
        duration: Duration(seconds: 1 + i), // each Stars will have slightly longer duration
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
                    startPos * MediaQuery.of(context).size.width +
                        (MediaQuery.of(context).size.width / 4) * sin(animation.value * 2 * pi),
                    -animation.value * MediaQuery.of(context).size.height,
                  ),
                  child: Transform.rotate(
                    angle: sin(animation.value * 2 * pi) / 4,
                    child: child,
                  ));
            },
            child: SvgPicture.asset(
              StarsImages[idx % StarsImages.length],
              height: ResponsiveSizing.scaleHeight(context, 56),
            ),
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
