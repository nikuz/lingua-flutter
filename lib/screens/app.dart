import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lingua_flutter/styles/styles.dart';
import 'package:lingua_flutter/widgets/tab_navigator/tab_navigator.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MyTheme theme = Styles.theme(context);

    return Scaffold(
      backgroundColor: theme.colors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: TabNavigatorConstants.height),
              child: AutoRouter(),
            ),

            TabNavigator(
              children: [
                TabNavigatorItem(
                  label: 'Search',
                  icon: Icons.search,
                  path: 'search',
                ),
                TabNavigatorItem(
                  label: 'Settings',
                  icon: Icons.settings,
                  path: 'settings',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}