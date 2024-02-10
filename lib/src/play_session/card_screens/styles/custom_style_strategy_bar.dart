import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';

class CustomStyleStrategy extends StyleStrategy {
  @override
  FortuneItemStyle getItemStyle(ThemeData theme, int index, int itemCount) {
    final colors = [Colors.purple, Colors.blue, Colors.pink, Colors.yellow];
    final backgroundColor = colors[index % colors.length];
    const textColor = Colors.white;
    const borderColor = Colors.deepPurpleAccent;

    return FortuneItemStyle(
      color: backgroundColor,
      borderColor: borderColor,
      borderWidth: 5,
      textStyle: theme.textTheme.titleLarge!.copyWith(
        color: textColor,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }
}
