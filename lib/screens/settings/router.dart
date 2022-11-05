import 'package:flutter/material.dart';

import './home/home.dart';

class SettingsNavigatorRoutes {
  static const String home = '/';
}

class SettingsNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  SettingsNavigator({ required this.navigatorKey });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: SettingsNavigatorRoutes.home,
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    WidgetBuilder builder;

    switch (settings.name) {
      case SettingsNavigatorRoutes.home:
        builder = (BuildContext _) => SettingsHomePage();
        break;
      default:
        throw Exception('Invalid route: ${settings.name}');
    }

    return MaterialPageRoute(builder: builder, settings: settings);
  }
}
