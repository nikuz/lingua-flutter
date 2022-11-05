import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lingua_flutter/widgets/tab_navigation.dart';

import './settings/home/bloc/bloc.dart';
import './settings/home/bloc/events.dart';

import './search/router.dart';
import './games/router.dart';
import './settings/router.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  TabItemName _currentTab = TabItemName.search;
  late SettingsBloc _settingsBloc;

  Map<TabItemName, GlobalKey<NavigatorState>> _navigatorKeys = {
    TabItemName.search: GlobalKey<NavigatorState>(),
    TabItemName.games: GlobalKey<NavigatorState>(),
    TabItemName.settings: GlobalKey<NavigatorState>(),
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
    Widget page = Center(
      child: CircularProgressIndicator(),
    );

    final key = _navigatorKeys[_currentTab];

    if (key != null) {
      switch (_currentTab) {
        case TabItemName.search:
          page = SearchNavigator(navigatorKey: key);
          break;
        case TabItemName.games:
          page = GamesNavigator(navigatorKey: key);
          break;
        case TabItemName.settings:
          page = SettingsNavigator(navigatorKey: key);
          break;
        default:
      }
    }

    return Scaffold(
      body: page,
      bottomNavigationBar: BottomNavigation(
        currentTab: _currentTab,
        onSelectTab: _selectTab,
      ),
    );
  }

  void _selectTab(TabItemName tabItem) {
    setState(() => _currentTab = tabItem);
  }
}



