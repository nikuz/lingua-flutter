import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lingua_flutter/providers/connectivity.dart';
import 'package:lingua_flutter/screens/router.gr.dart';
import 'package:lingua_flutter/screens/settings/bloc/settings_cubit.dart';
import 'package:lingua_flutter/screens/settings/bloc/settings_state.dart';
import 'package:lingua_flutter/screens/search/bloc/search_cubit.dart';
import 'package:lingua_flutter/screens/translation_view/bloc/translation_view_cubit.dart';

class App extends StatefulWidget {
  final SharedPreferences prefs;

  const App(this.prefs, {Key? key}) : super(key: key);

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
    return MultiBlocProvider(
      providers: [
        BlocProvider<SearchCubit>(
          create: (context) => SearchCubit(),
        ),
        BlocProvider<TranslationViewCubit>(
          create: (context) => TranslationViewCubit(),
        ),
        BlocProvider<SettingsCubit>(
          create: (context) => SettingsCubit(widget.prefs),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
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
            darkTheme: ThemeData.dark(),
            themeMode: themeMode,
            routerDelegate: _appRouter.delegate(),
            routeInformationParser: _appRouter.defaultRouteParser(),
          );
        },
      ),
    );
  }
}