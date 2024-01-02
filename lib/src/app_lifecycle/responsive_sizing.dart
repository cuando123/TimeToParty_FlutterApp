import 'package:flutter/cupertino.dart';

class ResponsiveSizing {

  static double referenceWidth = 360;
  static double referenceHeight = 800;

  static double scaleWidth(BuildContext context, double width) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    return (screenWidth / referenceWidth) * width;
  }

  static double scaleHeight(BuildContext context, double height) {
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    return (screenHeight / referenceHeight) * height;
  }

  static double responsiveHeightWithCondition(BuildContext context, double smallHeight, double bigHeight, double condition) {
    return MediaQuery.of(context).size.height < condition ? scaleHeight(context, smallHeight) : scaleHeight(context, bigHeight);
  }

  static double responsiveWidthWithCondition(BuildContext context, double smallWidth, double bigWidth, double condition) {
    return MediaQuery.of(context).size.width < condition ? scaleWidth(context, smallWidth) : scaleWidth(context, bigWidth);
  }

  static SizedBox responsiveHeightGapWithCondition(BuildContext context, double smallHeight, double bigHeight, double condition) {
    double finalHeight = MediaQuery.of(context).size.height < condition ? smallHeight : bigHeight;
    return SizedBox(height: scaleHeight(context, finalHeight));
  }

  static SizedBox responsiveWidthGapWithCondition(BuildContext context, double smallWidth, double bigWidth, double condition) {
    double finalWidth = MediaQuery.of(context).size.width < condition ? smallWidth : bigWidth;
    return SizedBox(width: scaleWidth(context, finalWidth));
  }

  static SizedBox responsiveHeightGap(BuildContext context, double height) {
    return SizedBox(height: scaleHeight(context, height));
  }

  static SizedBox responsiveWidthGap(BuildContext context, double width) {
    return SizedBox(width: scaleWidth(context, width));
  }

  static EdgeInsets responsiveMarginWithCondition(BuildContext context, double smallMargin, double bigMargin, double condition) {
    double finalMargin = MediaQuery.of(context).size.height < condition ? scaleHeight(context, smallMargin) : scaleHeight(context, bigMargin);
    return EdgeInsets.only(top: finalMargin);
  }
}