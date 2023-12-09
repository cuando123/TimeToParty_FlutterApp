import 'package:flutter/cupertino.dart';

class PulsatingText extends StatefulWidget {
  final String text;
  final TextStyle textStyle;
  final double size;

  const PulsatingText({
    super.key,
    required this.text,
    required this.textStyle,
    required this.size,
  });

  @override
  _PulsatingTextState createState() => _PulsatingTextState();
}

class _PulsatingTextState extends State<PulsatingText> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 4), // Całkowity czas trwania cyklu animacji
      vsync: this,
    )..repeat(); // Powtarza animację w nieskończoność

    // Inicjalizacja animacji pulsowania używając TweenSequence
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.1), // Zwiększa skalę
          weight: 0.05),
      TweenSequenceItem(
          tween: ConstantTween<double>(1.1), // Utrzymuje skalę
          weight: 0.05),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.1, end: 1.0), // Zmniejsza skalę
          weight: 0.05),
      TweenSequenceItem(
          tween: ConstantTween<double>(1.0), // Utrzymuje skalę
          weight: 0.85),
    ]).animate(_pulseController);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) => Transform.scale(
        scale: _pulseAnimation.value,
        alignment: Alignment.center, // Zapewnia skalowanie wokół środka widgetu
        child: Text(
          widget.text,
          style: widget.textStyle.copyWith(fontSize: widget.size),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
}