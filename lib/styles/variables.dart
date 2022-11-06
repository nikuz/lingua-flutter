import 'package:flutter/material.dart';

const double _defaultFontSize = 16;

class MyVariables {
  const MyVariables();

  // Font family
  final String defaultFontFamily = 'Montserrat';

  // Font size
  final double defaultFontSize = _defaultFontSize;
  final double bodyFontSizeLarge = _defaultFontSize * 1.125;  // 18
  final double bodyFontSizeSmall = _defaultFontSize * 0.875;  // 14
  final double bodyFontSizeTiny = _defaultFontSize * 0.625;   // 10

  // Timing
  final Duration timingT1 = const Duration(milliseconds: 500);
  final Duration timingT2 = const Duration(milliseconds: 300);
  final Duration timingT3 = const Duration(milliseconds: 250);
  final Duration timingT4 = const Duration(milliseconds: 200);
  final Duration timingT5 = const Duration(milliseconds: 100);
  final Duration timingT6 = const Duration(milliseconds: 0);

  // Easing
  final Curve ease = Curves.ease;
  final Curve easeIn = Curves.easeInQuart;
  final Curve easeOut = Curves.easeOutQuart;
  final Curve easeInOut = Curves.easeInOutQuart;
}