import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lingua_flutter/widgets/tab_navigator/tab_navigator.dart';

import './router.dart';

class Root extends StatelessWidget {
  const Root({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final keyboardIsVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: keyboardIsVisible ? 0 : TabNavigatorConstants.height),
          child: const AutoRouter(),
        ),

        const TabNavigator(
          children: [
            TabNavigatorItem(
              label: 'Search',
              icon: Icons.search,
              path: Routes.search,
            ),
            TabNavigatorItem(
              label: 'Play',
              icon: Icons.games,
              path: Routes.games,
            ),
            TabNavigatorItem(
              label: 'Settings',
              icon: Icons.settings,
              path: Routes.settings,
            ),
          ],
        ),
      ],
    );
  }
}