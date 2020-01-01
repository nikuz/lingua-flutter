import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

import './blocs/delegate.dart';
import './screens/search/home/bloc/bloc.dart';
import './screens/search/translation_view/bloc/bloc.dart';

import './screens/search/router.dart';
import './screens/games/router.dart';
import './screens/settings/router.dart';

void main() async {
  BlocSupervisor.delegate = MyBlocDelegate();
  final http.Client httpClient = http.Client();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<TranslationsBloc>(
          builder: (context) => TranslationsBloc(httpClient: httpClient),
        ),
        BlocProvider<TranslationBloc>(
          builder: (context) => TranslationBloc(httpClient: httpClient),
        ),
      ],
      child: App(),
    ),
  );
}

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
    'title': 'Games',
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

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  TabItem _currentTab = TabItem.search;
  Map<TabItem, GlobalKey<NavigatorState>> _navigatorKeys = {
    TabItem.search: GlobalKey<NavigatorState>(),
    TabItem.games: GlobalKey<NavigatorState>(),
    TabItem.settings: GlobalKey<NavigatorState>(),
  };

  @override
  Widget build(BuildContext context) {
    Widget page = Container();

    if (_currentTab == TabItem.search) {
      page = SearchNavigator(navigatorKey: _navigatorKeys[TabItem.search]);
    } else if (_currentTab == TabItem.games) {
      page = GamesNavigator(navigatorKey: _navigatorKeys[TabItem.games]);
    } else if (_currentTab == TabItem.settings) {
      page = SettingsNavigator(navigatorKey: _navigatorKeys[TabItem.settings]);
    }

    return MaterialApp(
      title: 'Lingua',
      theme: ThemeData(fontFamily: 'Montserrat'),
      home: WillPopScope(
        onWillPop: () async {
          final isFirstRouteInCurrentTab =
          !await _navigatorKeys[_currentTab].currentState.maybePop();
          if (isFirstRouteInCurrentTab) {
            // if not on the 'main' tab
            if (_currentTab != TabItem.search) {
              // select 'main' tab
              _selectTab(TabItem.search);
              // back button handled by app
              return false;
            }
          }
          // let system handle back button if we're on the first route
          return isFirstRouteInCurrentTab;
        },
        child: Scaffold(
          body: page,
          bottomNavigationBar: BottomNavigation(
            currentTab: _currentTab,
            onSelectTab: _selectTab,
          ),
        ),
      ),
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



