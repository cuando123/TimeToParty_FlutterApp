import 'dart:math';

import 'package:flutter/material.dart';

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
      child: Transform.scale(
        scale: (index == actualIndex) ? 1.0 : 0.8,  // Skaluj poboczne karty do 90% rozmiaru
        child: AnimatedContainer(
        duration: sliderDuration,
        margin: (index == actualIndex)
            ? const EdgeInsets.symmetric(horizontal: 8, vertical: 16)
            : const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
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
      ),),
    );
  }

  Widget _buildImageWidget(String imagePath, BoxFit fitMode, bool isAssets) {
      return isAssets
          ? Image.asset(imagePath, fit: fitMode)
          : Image.network(imagePath, fit: fitMode);
  }

  List<BoxShadow>? _getSlideBoxShadow(index, actualIndex) =>
      (index == actualIndex) ? currentItemShadow : sideItemsShadow;

  double _getSlideTurn(int currentIndex, actualCurrentIndex) => (currentIndex < actualCurrentIndex)
      ? -pi / turns
      : (currentIndex > actualCurrentIndex)
          ? pi / turns
          : 0;
}
