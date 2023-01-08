import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lingua_flutter/screens/router.gr.dart';

class Root extends StatelessWidget {
  const Root({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: AutoTabsScaffold(
        routes: const [
          SearchRoute(),
          // GamesRoute(),
          SettingsRoute(),
        ],
        animationDuration: Duration.zero,
        bottomNavigationBuilder: (_, tabsRouter) {
          return BottomNavigationBar(
            elevation: 15,
            currentIndex: tabsRouter.activeIndex,
            onTap: tabsRouter.setActiveIndex,
            items: const [
              BottomNavigationBarItem(
                label: 'Search',
                icon: Icon(Icons.search),
              ),
              // BottomNavigationBarItem(
              //   label: 'Play',
              //   icon: Icon(Icons.games),
              // ),
              BottomNavigationBarItem(
                label: 'Settings',
                icon: Icon(Icons.settings),
              ),
            ],
          );
        },
      ),
    );
  }
}