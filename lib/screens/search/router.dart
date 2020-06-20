import 'package:flutter/material.dart';

import './home/home.dart';
import './translation_view/translation_view.dart';
import './translation_view/images_picker.dart';
import './translation_view/own_translation.dart';

class SearchNavigatorRoutes {
  static const String home = '/';
  static const String translation_view = '/translation-view';
  static const String translation_view_images_picker = '/translation-view/images';
  static const String translation_view_own_translation = '/translation-view/own-translation';
}

class SearchNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  SearchNavigator({ this.navigatorKey }) : assert(navigatorKey != null);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: SearchNavigatorRoutes.home,
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    WidgetBuilder builder;

    switch (settings.name) {
      case SearchNavigatorRoutes.home:
        builder = (BuildContext _) => SearchHomePage();
        break;
      case SearchNavigatorRoutes.translation_view:
        String word = settings.arguments;
        builder = (BuildContext _) => TranslationView(word);
        break;
      case SearchNavigatorRoutes.translation_view_images_picker:
        String word = settings.arguments;
        builder = (BuildContext _) => TranslationViewImagePicker(word);
        break;
      case SearchNavigatorRoutes.translation_view_own_translation:
        String translation = settings.arguments;
        builder = (BuildContext _) => TranslationViewOwnTranslation(translation);
        break;
      default:
        throw Exception('Invalid route: ${settings.name}');
    }

    return MaterialPageRoute(builder: builder, settings: settings);
  }
}
