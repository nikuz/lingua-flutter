import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lingua_flutter/app_config.dart' as appConfig;
import 'package:lingua_flutter/helpers/db.dart';
import 'package:lingua_flutter/utils/sizes.dart';
import 'package:lingua_flutter/utils/connectivity.dart';
import 'package:lingua_flutter/widgets/api_key_screen.dart';

import './settings/home/bloc/bloc.dart';
import './settings/home/bloc/events.dart';
import './settings/home/bloc/state.dart';
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
        size: SizeUtil.vmax(25),
      ),
      title: Text(
        tabs[tabItem]['title'],
        style: TextStyle(
          color: _getColor(tabItem),
          fontSize: SizeUtil.vmax(15),
        ),
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
  bool apiKeySet = appConfig.kIsWeb ? false : true;
  TabItem _currentTab = TabItem.search;
  Timer _getApiUrlTimer;
  var _networkChangeSubscription;
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
    _networkChangeSubscription = initiateNetworkChangeSubscription();
    subscribeToNetworkChange('main', (bool result) {
      if (result) {
        _setApiUrlUpdateTimer();
      } else if (_getApiUrlTimer != null) {
        _getApiUrlTimer.cancel();
      }
    });
    //    BlocProvider.of<LoginBloc>(context).add(LoginCheck());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setApiUrlUpdateTimer();
    } else {
      _getApiUrlTimer.cancel();
    }
  }

  @override
  void didChangePlatformBrightness() {
    final Brightness brightness = WidgetsBinding.instance.window.platformBrightness;
    print(brightness);
    _settingsBloc.add(SettingsChange(
      type: 'bool',
      id: 'autoDarkMode',
      value: brightness == Brightness.dark,
      savePrefs: true,
    ));
  }

  @override
  void dispose() {
    _getApiUrlTimer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _networkChangeSubscription.cancel();
    unsubscribeFromNetworkChange('main');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeUtil().init(context);
    return MultiBlocListener(
      listeners: [
        BlocListener<SettingsBloc, SettingsState>(
          listener: (context, state) async {
            if (state is SettingsLoaded) {
              if (state.settings['offlineMode']) {
                await dbOpen();
                setState(() {
                  apiUrlDownloaded = true;
                });
              } else {
                setState(() {
                  apiUrlDownloaded = true;
                });
              }
              if (_getApiUrlTimer == null) {
                _setApiUrlUpdateTimer();
              }
            }
          },
        ),
        BlocListener<LoginBloc, LoginState>(
          listener: (context, state) {},
        ),
      ],
      child: BlocBuilder<LoginBloc, LoginState>(
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

            if (apiUrlDownloaded && !apiKeySet) {
              return ApiKeyScreen(() {
                setState(() {
                  apiKeySet = true;
                });
              });
            }

            if (apiUrlDownloaded) {
              return Scaffold(
                body: page,
                bottomNavigationBar: bottomNavigation,
              );
            }

            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
      ),
    );
  }

  void _setApiUrlUpdateTimer() {
    _getApiUrl();
    _getApiUrlTimer = new Timer.periodic(Duration(minutes: 1), (Timer t) => _getApiUrl());
  }

  void _getApiUrl() async {
    // if (kReleaseMode) {
    //   final response = await http.get(appConfig.apiGetterUrl);
    //   if (response.statusCode == 200) {
    //     _setApiUrl(response.body);
    //   } else {
    //     throw Exception('Can\'t get API url');
    //   }
    // } else {
    //   _setApiUrl(appConfig.getApiDebugUrl());
    // }
    String apiKey = await appConfig.getApiKey();
    if (apiKey != null && !apiKeySet) {
      setState(() {
        apiKeySet = true;
      });
    }
  }

  // void _setApiUrl(String apiUrl) {
  //   final bool initialUpdate = appConfig.apiUrl == null;
  //   if (apiUrl != appConfig.apiUrl) {
  //     appConfig.apiUrl = apiUrl;
  //   }
  //   if (initialUpdate) {
  //     setState(() {
  //       apiUrlDownloaded = true;
  //     });
  //   }
  // }

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



