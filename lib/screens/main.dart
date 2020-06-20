import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lingua_flutter/app_config.dart' as appConfig;

import './login/bloc/bloc.dart';
//import './login/bloc/events.dart';
import './login/bloc/state.dart';

//import './login/login.dart';
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
    'title': 'Search',
    'icon': Icons.search,
  },
  TabItem.games: {
    'title': 'Games',
    'icon': Icons.insert_emoticon,
  },
  TabItem.settings: {
    'title': 'Settings',
    'icon': Icons.settings,
  },
};

class BottomNavigation extends StatelessWidget {
  BottomNavigation({this.currentTab, this.onSelectTab});
  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectTab;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [
        _buildItem(tabItem: TabItem.search),
        _buildItem(tabItem: TabItem.games),
        _buildItem(tabItem: TabItem.settings),
      ],
      onTap: (index) => onSelectTab(
        TabItem.values[index],
      ),
    );
  }

  BottomNavigationBarItem _buildItem({TabItem tabItem}) {
    return BottomNavigationBarItem(
      icon: Icon(
        tabs[tabItem]['icon'],
        color: _getColor(tabItem),
      ),
      title: Text(
        tabs[tabItem]['title'],
        style: TextStyle(color: _getColor(tabItem)),
      ),
    );
  }

  Color _getColor(TabItem item) {
    return currentTab == item ? Colors.blue : Colors.grey;
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  bool apiUrlDownloaded = false;
  TabItem _currentTab = TabItem.search;
  Timer timer;

  Map<TabItem, GlobalKey<NavigatorState>> _navigatorKeys = {
    TabItem.search: GlobalKey<NavigatorState>(),
    TabItem.games: GlobalKey<NavigatorState>(),
    TabItem.settings: GlobalKey<NavigatorState>(),
  };

  @override
  void initState() {
    super.initState();
    if (kReleaseMode) {
      _setApiUrlUpdateTimer();
    } else {
      _setApiUrl(appConfig.getApiDebugUrl());
    }
    WidgetsBinding.instance.addObserver(this);
//    BlocProvider.of<LoginBloc>(context).add(LoginCheck());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kReleaseMode) {
      if (state == AppLifecycleState.resumed) {
        _setApiUrlUpdateTimer();
      } else {
        timer.cancel();
      }
    }
  }

  _setApiUrlUpdateTimer() {
    _getApiUrl();
    timer = new Timer.periodic(Duration(minutes: 1), (Timer t) => _getApiUrl());
  }

  _getApiUrl() async {
    final response = await http.get(appConfig.apiGetterUrl);
    if (response.statusCode == 200) {
      _setApiUrl(response.body);
    } else {
      throw Exception('Can\'t get API url');
    }
  }

  _setApiUrl(String apiUrl) {
    final bool initialUpdate = appConfig.apiUrl == null;
    if (apiUrl != appConfig.apiUrl) {
      appConfig.apiUrl = apiUrl;
    }
    if (initialUpdate) {
      setState(() {
        apiUrlDownloaded = true;
      });
    }
  }

  @override
  void dispose() {
    timer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          Widget page = Center(
            child: CircularProgressIndicator(),
          );
          Widget bottomNavigation;

//          if (!(state is LoginUninitialized)) {
//            if (state.token == null) {
//              page = LoginPage();
//            } else
            if (_currentTab == TabItem.search) {
              page = SearchNavigator(navigatorKey: _navigatorKeys[TabItem.search]);
            } else if (_currentTab == TabItem.games) {
              page = GamesNavigator(navigatorKey: _navigatorKeys[TabItem.games]);
            } else if (_currentTab == TabItem.settings) {
              page = SettingsNavigator(navigatorKey: _navigatorKeys[TabItem.settings]);
            }
//          }

//          if (state.token != null) {
            bottomNavigation = BottomNavigation(
              currentTab: _currentTab,
              onSelectTab: _selectTab,
            );
//          }

          if (apiUrlDownloaded) {
            return Scaffold(
              body: page,
              bottomNavigationBar: bottomNavigation,
            );
          }

          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
    );
  }

  void _selectTab(TabItem tabItem) {
    if (tabItem == _currentTab) {
      // pop to first route
      _navigatorKeys[tabItem].currentState.popUntil((route) => route.isFirst);
    } else {
      print(tabItem);
      setState(() => _currentTab = tabItem);
    }
  }
}



