import '../colors.dart';

import './theme.dart';
import './theme_colors.dart';

final myThemeDataDark = MyTheme(
  colors: MyThemeColors(
    primary: myColors.white,
    primaryPale: myColors.grey,
    secondary: myColors.black,
    secondaryPale: myColors.black.withOpacity(0.8),
    focus: myColors.green,
    background: myColors.darkGrey,
    focusBackground: myColors.fakeBlack,
    cardBackground: myColors.fakeBlack,
    grey: myColors.grey,
    divider: myColors.dividerLight,
  ),
);
