import 'package:auto_route/auto_route.dart';
import './router.gr.dart';

abstract class Routes {
  static const landing = '/';
  static const home = '/home';
  static const search = 'search';
  static const games = 'games';
  static const settings = 'settings';
  static const translationView = '/translation_view';
  static const translationViewImages = '/translation_view/images';
  static const terms = '/terms';
}

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      path: Routes.landing,
      page: LandingRoute.page,
      maintainState: false,
    ),
    CustomRoute(
      path: Routes.home,
      page: RootRoute.page,
      transitionsBuilder: TransitionsBuilders.fadeIn,
      children: [
        AutoRoute(
          path: Routes.search,
          page: SearchRoute.page,
        ),
        AutoRoute(
          path: Routes.games,
          page: GamesRoute.page,
          maintainState: false,
        ),
        AutoRoute(
          path: Routes.settings,
          page: SettingsRoute.page,
          maintainState: false,
        ),
      ],
    ),
    AutoRoute(
      path: Routes.translationView,
      page: TranslationViewRoute.page,
    ),
    AutoRoute(
      path: Routes.translationViewImages,
      page: TranslationViewImagePickerRoute.page,
    ),
    AutoRoute(
      path: Routes.terms,
      page: TermsRoute.page,
    ),
  ];
}