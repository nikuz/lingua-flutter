import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lingua_flutter/utils/sizes.dart';

import './settings/home/bloc/bloc.dart';
import './settings/home/bloc/events.dart';

import './search/router.dart';
import './games/router.dart';
import './settings/router.dart';

enum TabItem {
  search,
  games,
  settings,
}

Map<TabItem, Map<String, dynamic>> tabs = {
  TabItem.search: {
    'index': 0,
    'title': 'Search',
    'icon': Icons.search,
  },
  TabItem.games: {
    'index': 1,
    'title': 'Games',
    'icon': Icons.insert_emoticon,
  },
  TabItem.settings: {
    'index': 2,
    'title': 'Settings',
    'icon': Icons.settings,
  },
};

class BottomNavigation extends StatelessWidget {
  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectTab;

  BottomNavigation({this.currentTab, this.onSelectTab});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [
        _buildItem(tabItem: TabItem.search),
        _buildItem(tabItem: TabItem.games),
        _buildItem(tabItem: TabItem.settings),
      ],
      currentIndex: currentTab.index,
      iconSize: SizeUtil.vmax(25),
      selectedItemColor: Colors.blue,
      unselectedFontSize: SizeUtil.vmax(15),
      selectedFontSize: SizeUtil.vmax(15),
      onTap: (index) => onSelectTab(
        TabItem.values[index],
      ),
    );
  }

  BottomNavigationBarItem _buildItem({TabItem tabItem}) {
    return BottomNavigationBarItem(
      icon: Icon(tabs[tabItem]['icon']),
      label: tabs[tabItem]['title'],
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  TabItem _currentTab = TabItem.search;
  SettingsBloc _settingsBloc;

  Map<TabItem, GlobalKey<NavigatorState>> _navigatorKeys = {
    TabItem.search: GlobalKey<NavigatorState>(),
    TabItem.games: GlobalKey<NavigatorState>(),
    TabItem.settings: GlobalKey<NavigatorState>(),
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _settingsBloc = BlocProvider.of<SettingsBloc>(context);
    _settingsBloc.add(SettingsGet());
  }

  @override
  void didChangePlatformBrightness() {
    final Brightness brightness = WidgetsBinding.instance.window.platformBrightness;
    _settingsBloc.add(SettingsChange(
      type: 'bool',
      id: 'autoDarkMode',
      value: brightness == Brightness.dark,
      savePrefs: true,
    ));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeUtil().init(context);
    Widget page = Center(
      child: CircularProgressIndicator(),
    );
    Widget bottomNavigation;

    if (_currentTab == TabItem.search) {
      page = SearchNavigator(navigatorKey: _navigatorKeys[TabItem.search]);
    } else if (_currentTab == TabItem.games) {
      page = GamesNavigator(navigatorKey: _navigatorKeys[TabItem.games]);
    } else if (_currentTab == TabItem.settings) {
      page = SettingsNavigator(navigatorKey: _navigatorKeys[TabItem.settings]);
    }

    bottomNavigation = BottomNavigation(
      currentTab: _currentTab,
      onSelectTab: _selectTab,
    );

    return Scaffold(
      body: page,
      bottomNavigationBar: bottomNavigation,
    );
  }

  void _selectTab(TabItem tabItem) {
    if (tabItem == _currentTab) {
      // pop to first route
      _navigatorKeys[tabItem].currentState.popUntil((route) => route.isFirst);
    } else {
      setState(() => _currentTab = tabItem);
    }
  }
}



