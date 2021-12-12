import 'package:flutter/material.dart';

import './home/home.dart';

class GamesNavigatorRoutes {
  static const String home = '/';
}

class GamesNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  GamesNavigator({ required this.navigatorKey }) : assert(navigatorKey != null);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: GamesNavigatorRoutes.home,
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    WidgetBuilder builder;

    switch (settings.name) {
      case GamesNavigatorRoutes.home:
        builder = (BuildContext _) => GamesHomePage();
        break;
      default:
        throw Exception('Invalid route: ${settings.name}');
    }

    return MaterialPageRoute(builder: builder, settings: settings);
  }
}
