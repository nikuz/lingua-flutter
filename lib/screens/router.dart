import 'package:auto_route/auto_route.dart';
import 'package:lingua_flutter/models/translation.dart';

import './app.dart';
import './search/search.dart';
import './translation_view/translation_view.dart';
import './translation_view/pages/images_picker.dart';
import './games/games.dart';
import './settings/settings.dart';

class Routes {
  static const home = '/';
  static const search = 'search';
  static const translationView = 'translation_view';
  static const translationImages = 'translation_view/images';
  static const games = 'games';
  static const settings = 'settings';
}

@MaterialAutoRouter(
  routes: <AutoRoute>[
    AutoRoute(
      path: Routes.home,
      page: App,
      children: [
        CustomRoute(
          path: Routes.search,
          page: Search,
          initial: true,
          transitionsBuilder: TransitionsBuilders.noTransition,
        ),
        AutoRoute<TranslationContainer>(
          path: Routes.translationView,
          page: TranslationView,
        ),
        AutoRoute(
          path: Routes.translationImages,
          page: TranslationViewImagePicker,
        ),
        CustomRoute(
          path: Routes.games,
          page: Games,
          transitionsBuilder: TransitionsBuilders.noTransition,
        ),
        CustomRoute(
          path: Routes.settings,
          page: Settings,
          transitionsBuilder: TransitionsBuilders.noTransition,
        ),
      ],
    ),
  ],
)

class $AppRouter {}