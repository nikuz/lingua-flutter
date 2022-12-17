import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/providers/connectivity.dart';

import './screens/router.gr.dart';
import './screens/settings/bloc/settings_cubit.dart';
import './screens/settings/bloc/settings_state.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  final _appRouter = AppRouter();
  late Brightness _brightness;
  late StreamSubscription _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _brightness = WidgetsBinding.instance.window.platformBrightness;
    _connectivitySubscription = initiateNetworkChangeSubscription();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {
      _brightness = WidgetsBinding.instance.window.platformBrightness;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        ThemeMode themeMode = ThemeMode.light;

        if (state.autoDarkMode) {
          themeMode = _brightness == Brightness.light
              ? ThemeMode.light
              : ThemeMode.dark;
        } if (state.darkMode) {
          themeMode = ThemeMode.dark;
        }

        return MaterialApp.router(
          title: 'Lingua',
          theme: ThemeData(fontFamily: 'Montserrat'),
          darkTheme: ThemeData.dark(),
          themeMode: themeMode,
          routerDelegate: _appRouter.delegate(),
          routeInformationParser: _appRouter.defaultRouteParser(),
        );
      },
    );
  }
}