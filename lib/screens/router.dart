import 'package:auto_route/auto_route.dart';
import 'package:lingua_flutter/models/translation.dart';

import './root.dart';
// import './landing/landing.dart';
import './search/search.dart';
import './translation_view/translation_view.dart';
import './translation_view/pages/images_picker.dart';
import './games/games.dart';
import './settings/settings.dart';

abstract class Routes {
  static const landing = '/landing';
  static const home = '/home';
  static const search = 'search';
  static const translationView = 'translation_view';
  static const translationViewImages = 'translation_view/images';
  static const games = 'games';
  static const settings = 'settings';
}

@MaterialAutoRouter(
  routes: <AutoRoute>[
    // CustomRoute(
    //   path: Routes.landing,
    //   page: Landing,
    //   initial: true,
    //   transitionsBuilder: TransitionsBuilders.noTransition,
    // ),
    CustomRoute(
      path: Routes.home,
      page: Root,
      initial: true,
      transitionsBuilder: TransitionsBuilders.noTransition,
      children: [
        AutoRoute(
          path: Routes.search,
          page: Search,
        ),
        AutoRoute(
          path: Routes.games,
          page: Games,
        ),
        AutoRoute(
          path: Routes.settings,
          page: Settings,
        ),
      ],
    ),
    AutoRoute<TranslationContainer>(
      path: Routes.translationView,
      page: TranslationView,
    ),
    AutoRoute(
      path: Routes.translationViewImages,
      page: TranslationViewImagePicker,
    ),
  ],
)

class $AppRouter {}