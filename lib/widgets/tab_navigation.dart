import 'package:flutter/material.dart';

enum TabItemName {
  search,
  games,
  settings,
}

class BottomNavigation extends StatelessWidget {
  final TabItemName currentTab;
  final ValueChanged<TabItemName> onSelectTab;

  BottomNavigation({
    required this.currentTab,
    required this.onSelectTab,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        // BottomNavigationBarItem(
        //   icon: Icon(Icons.insert_emoticon),
        //   label: 'Games',
        // ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        )
      ],
      currentIndex: currentTab.index,
      iconSize: 25,
      selectedItemColor: Colors.blue,
      unselectedFontSize: 15,
      selectedFontSize: 15,
      onTap: (index) => onSelectTab(
        TabItemName.values[index],
      ),
    );
  }
}