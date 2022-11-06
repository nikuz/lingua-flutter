import 'package:flutter/material.dart';

import './theme.dart';
import './light.dart';
import './dark.dart';

MyTheme getTheme(BuildContext context) {
  Brightness brightness = Theme.of(context).brightness;
  MyTheme theme = myThemeDataLight;

  if (brightness == Brightness.dark) {
    theme = myThemeDataDark;
  }

  return theme;
}