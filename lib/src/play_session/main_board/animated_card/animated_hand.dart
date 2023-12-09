import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

class AnimatedHandArrow extends StatefulWidget {
  const AnimatedHandArrow({super.key});

  @override
  _AnimatedHandArrowState createState() => _AnimatedHandArrowState();
}

class _AnimatedHandArrowState extends State<AnimatedHandArrow> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _translationAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _translationAnimation = Tween<double>(
      begin: -0.15, // Przesunięcie o 25% szerokości ekranu w lewo
      end: 0.15, // Przesunięcie o 25% szerokości ekranu w prawo
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rotationAnimation = Tween<double>(
      begin: -15, // Obrót o -10 stopni
      end: 15, // Obrót o 10 stopni
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_translationAnimation, _rotationAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_translationAnimation.value * MediaQuery.of(context).size.width, 0),
          child: Transform.rotate(
            angle: _rotationAnimation.value * (pi / 180), // Konwersja na radiany
            child: child,
          ),
        );
      },
      child: SvgPicture.asset('assets/time_to_party_assets/hand_arrow.svg', height: 50),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}