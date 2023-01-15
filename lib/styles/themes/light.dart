import 'dart:ui';

import '../colors.dart';
import './theme.dart';
import './theme_colors.dart';

final myThemeDataLight = MyTheme(
  brightness: Brightness.light,
  colors: MyThemeColors(
    primary: myColors.black,
    primaryPale: myColors.darkGrey,
    secondary: myColors.white,
    secondaryPale: myColors.grey,
    focus: myColors.blue,
    background: myColors.paleGrey,
    focusBackground: myColors.blue,
    focusForeground: myColors.springBud,
    cardBackground: myColors.white,
    grey: myColors.grey,
    divider: myColors.dividerDark,
  ),
);