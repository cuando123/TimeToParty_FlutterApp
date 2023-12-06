import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SlideWidget extends StatelessWidget {
  const SlideWidget({
    super.key,
    required this.index,
    required this.actualIndex,
    required this.sliderDuration,
    required this.isAssets,
    required this.imageLink,
    required this.imageFitMode,
    required this.imageRadius,
    required this.sidesOpacity,
    required this.turns,
    required this.currentItemShadow,
    required this.sideItemsShadow,
    required this.onSlideClick,
  });

  final Function onSlideClick;
  final int index;
  final int actualIndex;
  final Duration sliderDuration;
  final bool isAssets;
  final String imageLink;
  final BoxFit imageFitMode;
  final double imageRadius;
  final double sidesOpacity;
  final double turns;
  final List<BoxShadow>? currentItemShadow;
  final List<BoxShadow>? sideItemsShadow;

  @override
  Widget build(BuildContext context) {
    final imageWidget = _buildImageWidget(imageLink, imageFitMode, isAssets);

    return AnimatedRotation(
      turns: _getSlideTurn(index, actualIndex),
      duration: sliderDuration,
      child: AnimatedContainer(
        duration: sliderDuration,
        margin: (index == actualIndex)
            ? const EdgeInsets.symmetric(horizontal: 8, vertical: 16)
            : const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(imageRadius),
          boxShadow: _getSlideBoxShadow(index, actualIndex),
        ),
        child: AnimatedOpacity(
          duration: sliderDuration,
          opacity: (index == actualIndex) ? 1 : sidesOpacity,
          child: InkWell(
            onTap: () => onSlideClick(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(imageRadius),
              child: imageWidget, // Tutaj wstawiamy wybrany widget obrazu
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imagePath, BoxFit fitMode, bool isAssets) {
    // Sprawdź, czy ścieżka kończy się na '.svg'
    bool isSvg = imagePath.toLowerCase().endsWith('.svg');

    if (isSvg) {
      // Użyj SvgPicture dla plików SVG
      return isAssets
          ? SvgPicture.asset(imagePath, fit: fitMode)
          : SvgPicture.network(imagePath, fit: fitMode);
    } else {
      // Użyj standardowego widgetu obrazu dla innych formatów
      return isAssets
          ? Image.asset(imagePath, fit: fitMode)
          : Image.network(imagePath, fit: fitMode);
    }
  }


  List<BoxShadow>? _getSlideBoxShadow(index, actualIndex) =>
      (index == actualIndex) ? currentItemShadow : sideItemsShadow;

  double _getSlideTurn(int currentIndex, actualCurrentIndex) => (currentIndex < actualCurrentIndex)
      ? -pi / turns
      : (currentIndex > actualCurrentIndex)
          ? pi / turns
          : 0;
}
