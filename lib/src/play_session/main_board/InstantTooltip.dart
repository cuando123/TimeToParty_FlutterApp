import 'package:flutter/material.dart';

class InstantTooltip extends StatefulWidget {
  final Widget child;
  final String message;

  InstantTooltip({required this.child, required this.message});

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
    for (int i = 0; i < words.length; i++) {
      buffer.write(words[i]);
      if ((i + 1) % 4 == 0 && i != words.length - 1) {
        buffer.write('\n');
      } else if (i != words.length - 1) {
        buffer.write(' ');
      }
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
                  boxShadow: [
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
