import 'package:flutter/material.dart';

import './screens/home/home.dart';
import './screens/translation_view/translation_view.dart';

const String HOME = '/';
const String TRANSLATION_VIEW = 'translation-view';

Route<dynamic> generateRoute(RouteSettings settings) {
  WidgetBuilder builder;

  switch (settings.name) {
    case HOME:
      print('home again');
      builder = (BuildContext _) => HomePage();
      break;
    case TRANSLATION_VIEW:
      String word = settings.arguments;
      builder = (BuildContext _) => TranslationView(word);
      break;
    default:
      throw Exception('Invalid route: ${settings.name}');
  }

  return MaterialPageRoute(builder: builder, settings: settings);
}
