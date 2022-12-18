import 'package:auto_route/auto_route.dart';
import 'package:lingua_flutter/models/translation.dart';

import './root.dart';
import './landing/landing.dart';
import './search/search.dart';
import './translation_view/translation_view.dart';
import './translation_view/pages/images_picker.dart';
import './games/games.dart';
import './settings/settings.dart';

abstract class Routes {
  static const landing = '/landing';
  static const home = '/home';
  static const search = 'home/search';
  static const translationView = 'home/translation_view';
  static const translationImages = 'home/translation_view/images';
  static const games = 'home/games';
  static const settings = 'home/settings';
}

@MaterialAutoRouter(
  routes: <AutoRoute>[
    CustomRoute(
      path: Routes.landing,
      page: Landing,
      initial: true,
      transitionsBuilder: TransitionsBuilders.noTransition,
    ),
    CustomRoute(
      path: Routes.home,
      page: Root,
      transitionsBuilder: TransitionsBuilders.noTransition,
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