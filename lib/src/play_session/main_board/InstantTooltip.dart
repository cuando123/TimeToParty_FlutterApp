import 'package:flutter/material.dart';

class InstantTooltip extends StatefulWidget {
  final Widget child;
  final String message;

  const InstantTooltip({super.key, required this.child, required this.message});

  @override
  _InstantTooltipState createState() => _InstantTooltipState();
}

class _InstantTooltipState extends State<InstantTooltip> {
  OverlayEntry? _overlayEntry;
  final GlobalKey _tooltipKey = GlobalKey();


  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  String formatMessage(String message) {
    final words = message.split(' ');
    final buffer = StringBuffer();
    String currentLine = '';

    for (var word in words) {
      // Sprawdź, czy dodanie tego słowa przekroczy limit długości
      if ((currentLine + (currentLine.isEmpty ? '' : ' ') + word).length > 22) {
        buffer.writeln(currentLine); // Dodaj obecną linię do bufora
        currentLine = word; // Zacznij nową linię od tego słowa
      } else {
        // W przeciwnym razie dodaj słowo do obecnej linii
        currentLine += (currentLine.isEmpty ? '' : ' ') + word;
      }
    }

    if (currentLine.isNotEmpty) {
      buffer.write(currentLine); // Dodaj ostatnią linię do bufora
    }

    return buffer.toString();
  }

  void _showTooltip(TapDownDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(details.localPosition);

    var screen = MediaQuery.of(context).size;

    double tooltipWidth = 150;  // dostosowane wartości
    double tooltipHeight = 100;

    var left = offset.dx - tooltipWidth / 2;
    if (left < 0) left = 10;
    if (left + tooltipWidth > screen.width) left = screen.width - tooltipWidth - 10;

    var top = offset.dy - tooltipHeight;
    if (top < 0) top = offset.dy + size.height;

    _overlayEntry = OverlayEntry(
        builder: (context) {
          final tooltipRenderBox = _tooltipKey.currentContext?.findRenderObject() as RenderBox?;
          final tooltipWidth = tooltipRenderBox?.size.width ?? 150;

          var left = offset.dx - tooltipWidth / 2;
          const edgeMargin = 25.0; // Dodatkowy margines dla lewej i prawej krawędzi ekranu

          if (left < edgeMargin) left = edgeMargin;
          if (left + tooltipWidth > screen.width - edgeMargin) left = screen.width - tooltipWidth - edgeMargin;

          return Positioned(
            left: left,
            top: top,
            child: Material(
              color: Colors.transparent,
              child: Container(
                key: _tooltipKey,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                  ],
                ),
                child: Text(formatMessage(widget.message),
                  style: TextStyle(fontSize: 14, fontFamily: 'HindMadurai'),
                ),
              ),
            ),
          );
        }
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _showTooltip,
      onTapUp: (details) => _hideTooltip(),
      onTapCancel: _hideTooltip,
      child: widget.child,
    );
  }
}
