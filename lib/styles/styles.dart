import 'package:flutter/material.dart';

import './colors.dart';
import './variables.dart';
import './themes/themes.dart';

export './themes/theme.dart';

class Styles {
  const Styles();

  static const colors = MyColors();
  static const variables = MyVariables();
  static Function(BuildContext) theme = getTheme;
}