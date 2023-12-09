
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';

class ImagePainter extends CustomPainter {
  final ui.Image image;

  ImagePainter({required this.image});

  @override
  void paint(Canvas canvas, Size size) {
    paintImage(canvas: canvas, rect: Offset.zero & size, image: image, fit: BoxFit.contain);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}