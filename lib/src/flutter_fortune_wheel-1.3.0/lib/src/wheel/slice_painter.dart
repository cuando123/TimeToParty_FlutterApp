part of 'wheel.dart';

/// Draws a slice of a circle. The slice's arc starts at the right (3 o'clock)
/// and moves clockwise as far as specified by angle.
class _CircleSlicePainter extends CustomPainter {
  final Color fillColor;
  final Color? strokeColor;
  final Gradient? gradient;
  final double strokeWidth;
  final double angle;

  const _CircleSlicePainter({
    this.gradient,
    this.fillColor = Colors.transparent, // domyślnie przezroczysty, jeśli używany jest gradient
    this.strokeColor,
    this.strokeWidth = 1,
    this.angle = _math.pi / 2,
  }) : assert(angle > 0 && angle < 2 * _math.pi),
        assert(gradient == null || fillColor == Colors.transparent); // Asercja, że kiedy jest gradient, kolor wypełnienia musi być przezroczysty

  @override
  void paint(Canvas canvas, Size size) {
    final radius = _math.min(size.width, size.height) / 2;
    final path = _CircleSlice.buildSlicePath(radius, angle);

    Paint paint = Paint()..style = PaintingStyle.fill;

    // Jeśli dostępny jest gradient, użyj go. W przeciwnym razie użyj koloru wypełnienia.
    if (gradient != null) {
      paint.shader = gradient!.createShader(Rect.fromCircle(center: Offset(0, 0), radius: radius));
    } else {
      paint.color = fillColor;
    }

    // wypełnij obszar segmentu
    canvas.drawPath(path, paint);

    // draw slice border
    if (strokeWidth > 0) {
      canvas.drawPath(
        path,
        Paint()
          ..color = strokeColor!
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke,
      );

      canvas.drawPath(
        Path()
          ..arcTo(
              Rect.fromCircle(
                center: Offset(0, 0),
                radius: radius,
              ),
              0,
              angle,
              false),
        Paint()
          ..color = strokeColor!
          ..strokeWidth = strokeWidth * 2
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_CircleSlicePainter oldDelegate) {
    return angle != oldDelegate.angle ||
        fillColor != oldDelegate.fillColor ||
        strokeColor != oldDelegate.strokeColor ||
        strokeWidth != oldDelegate.strokeWidth ||
        gradient != oldDelegate.gradient; // dodaj sprawdzanie gradientu
  }

}
