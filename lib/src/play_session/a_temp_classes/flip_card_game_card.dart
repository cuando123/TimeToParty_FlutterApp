import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class GameCard extends StatelessWidget {
  final String assetPath1;
  final String assetPath2;

  const GameCard(this.assetPath1, this.assetPath2, {super.key});

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }

}

class FlipCard extends StatefulWidget {
  final GameCard card;
  final bool isFlipped;
  final bool showGlow;

  const FlipCard({super.key, required this.card, required this.isFlipped, this.showGlow = false});

  @override
  _FlipCardState createState() => _FlipCardState();
}


class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    if (widget.isFlipped) {
      _controller.value = 0.5; // jeśli karta ma być odwrócona
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double value = _controller.value;
        bool isFaceUp = value < 0.5;
        final Matrix4 transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001) // punkt perspektywy
          ..rotateY(pi * value);
        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: Stack(
            children: [
              Container(
                child: isFaceUp
                    ? SvgPicture.asset(widget.card.assetPath1)
                    : SvgPicture.asset(widget.card.assetPath2),
              ),
              if (widget.showGlow) ...[
                Container(
                  width: 100,
                  height: 100,  // Ustawiłem też wysokość, aby widoczny był efekt
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,  // Rozpoczęcie gradientu ze środka
                      radius: 0.7,  // Określa "rozciągnięcie" gradientu, 0.5 to połowa szerokości i wysokości
                      colors: const [Colors.white, Colors.transparent],
                      stops: const [0.1, 1.0],
                    ),
                  ),
                )
              ],
            ],
          ),
        );
      },
    );
  }


  @override
  void didUpdateWidget(covariant FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}