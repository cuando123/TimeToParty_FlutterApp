import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

import '../../app_lifecycle/translated_text.dart';

class SvgButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String assetName; // Ścieżka do pliku SVG

  const SvgButton({super.key, 
    required this.onPressed,
    required this.assetName,
  });

  @override
  _SvgButtonState createState() => _SvgButtonState();
}

class _SvgButtonState extends State<SvgButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _animation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if(mounted) {
        _controller.forward();}
        widget.onPressed();
      },
      child: ScaleTransition(
        scale: _animation,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
          ),
          child: SvgPicture.asset(widget.assetName,
              height: ResponsiveSizing.scaleHeight(context, 75), width: double.maxFinite),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}