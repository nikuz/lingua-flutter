import 'dart:ui';

import '../colors.dart';
import './theme.dart';
import './theme_colors.dart';

final myThemeDataDark = MyTheme(
  brightness: Brightness.dark,
  colors: MyThemeColors(
    primary: myColors.white,
    primaryPale: myColors.grey,
    secondary: myColors.black,
    secondaryPale: myColors.black.withOpacity(0.8),
    focus: myColors.green,
    background: myColors.fakeBlack,
    focusBackground: myColors.darkGrey,
    focusForeground: myColors.orange,
    cardBackground: myColors.darkGrey,
    grey: myColors.grey,
    divider: myColors.dividerLight,
  ),
);
