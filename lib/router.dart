import 'package:flutter/material.dart';

import './screens/home/home.dart';
import './screens/translation_view/translation_view.dart';
import './screens/translation_view/images_picker.dart';
import './screens/games/games.dart';

const String HOME = '/';
const String TRANSLATION_VIEW = 'translation-view';
const String TRANSLATION_VIEW_IMAGES_PICKER = 'translation-view/images';
const String GAMES = 'games';

Route<dynamic> generateRoute(RouteSettings settings) {
  WidgetBuilder builder;

  switch (settings.name) {
    case HOME:
      builder = (BuildContext _) => HomePage();
      break;
    case TRANSLATION_VIEW:
      String word = settings.arguments;
      builder = (BuildContext _) => TranslationView(word);
      break;
    case TRANSLATION_VIEW_IMAGES_PICKER:
      String word = settings.arguments;
      builder = (BuildContext _) => TranslationViewImagePicker(word);
      break;
    case GAMES:
      builder = (BuildContext _) => GamesPage();
      break;
    default:
      throw Exception('Invalid route: ${settings.name}');
  }

  return MaterialPageRoute(builder: builder, settings: settings);
}
