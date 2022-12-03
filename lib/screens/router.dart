import 'package:auto_route/auto_route.dart';
import 'package:lingua_flutter/models/translation.dart';

import './app.dart';
import './search/search.dart';
import './translation_view/translation_view.dart';
import './translation_view/pages/images_picker.dart';
import './translation_view/pages/own_translation.dart';
import './settings/settings.dart';

class Routes {
  static const home = '/';
  static const search = 'search';
  static const translation_view = 'translation_view';
  static const translation_images = 'translation_view/images';
  static const translation_own = 'translation_view/own';
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
        AutoRoute<Translation>(
          path: Routes.translation_view,
          page: TranslationView,
        ),
        AutoRoute(
          path: Routes.translation_images,
          page: TranslationViewImagePicker,
        ),
        AutoRoute(
          path: Routes.translation_own,
          page: TranslationViewOwnTranslation,
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