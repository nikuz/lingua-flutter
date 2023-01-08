import 'package:auto_route/auto_route.dart';
import 'package:lingua_flutter/models/translation.dart';

import './root.dart';
import './landing/landing.dart';
import './search/search.dart';
import './translation_view/translation_view.dart';
import './translation_view/pages/images_picker.dart';
import './games/games.dart';
import './settings/settings.dart';
import './terms/terms.dart';

abstract class Routes {
  static const landing = '/landing';
  static const home = '/home';
  static const search = 'search';
  static const translationView = 'translation_view';
  static const translationViewImages = 'translation_view/images';
  static const games = 'games';
  static const settings = 'settings';
  static const terms = 'terms';
}

@MaterialAutoRouter(
  routes: <AutoRoute>[
    AutoRoute(
      path: Routes.landing,
      page: Landing,
      initial: true,
      maintainState: false,
    ),
    AutoRoute(
      path: Routes.home,
      page: Root,
      children: [
        AutoRoute(
          path: Routes.search,
          page: Search,
        ),
        AutoRoute(
          path: Routes.games,
          page: Games,
          maintainState: false,
        ),
        AutoRoute(
          path: Routes.settings,
          page: Settings,
          maintainState: false,
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
    AutoRoute(
      path: Routes.terms,
      page: Terms,
    ),
  ],
)

class $AppRouter {}