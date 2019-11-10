import 'package:flutter/material.dart';

import './screens/home/home.dart';
import './screens/translation_view/translation_view.dart';

const String HOME = '/';
const String TRANSLATION_VIEW = '/translation-view';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    WidgetBuilder builder;

    print(settings.name);
    print(TRANSLATION_VIEW);
    print(settings.name == TRANSLATION_VIEW);

    switch (settings.name) {
      case HOME:
        print('home again');
        builder = (BuildContext _) => HomePage();
        break;
      case TRANSLATION_VIEW:
        String word = settings.arguments;
        print(word);
        builder = (BuildContext _) => TranslationView(word);
        break;
      default:
        throw Exception('Invalid route: ${settings.name}');
    }

    return MaterialPageRoute(builder: builder, settings: settings);
  }
}
