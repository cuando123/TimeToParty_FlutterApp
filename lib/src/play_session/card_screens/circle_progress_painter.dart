import 'dart:math';

import 'package:flutter/cupertino.dart';

class CircleProgressPainter extends CustomPainter {
  final int segments;
  final double progress;

  CircleProgressPainter({required this.segments, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paintBackground = Paint()
      ..color = Color(0xFFE0E0E0)
      ..strokeWidth = 9
      ..style = PaintingStyle.stroke;

    final Paint paintProgress = Paint()
      ..color = Color(0xFF4FD5AA)
      ..strokeWidth = 9
      ..style = PaintingStyle.stroke;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2;

    double segmentAngle = 2 * pi / segments;
    double gapAngle = segmentAngle * 0.1; // 10% gap, you can adjust
    double fillAngle = segmentAngle - gapAngle;

    // Rysowanie tła
    for (int i = 0; i < segments; i++) {
      double start = i * segmentAngle - pi / 2;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, fillAngle, false, paintBackground);
    }

    // Rysowanie postępu
    double filledSegments = segments * progress;
    for (int i = 0; i < filledSegments; i++) {
      double start = i * segmentAngle - pi / 2;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, fillAngle, false, paintProgress);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}