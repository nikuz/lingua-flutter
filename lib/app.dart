import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lingua_flutter/app_config.dart' as config;
import 'package:lingua_flutter/providers/connectivity.dart';
import 'package:lingua_flutter/screens/router.gr.dart';
import 'package:lingua_flutter/screens/settings/bloc/settings_cubit.dart';
import 'package:lingua_flutter/screens/settings/bloc/settings_state.dart';
import 'package:lingua_flutter/screens/search/bloc/search_cubit.dart';
import 'package:lingua_flutter/screens/translation_view/bloc/translation_view_cubit.dart';

class App extends StatelessWidget {
  final SharedPreferences prefs;

  const App(this.prefs, {super.key});

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
          create: (context) => SettingsCubit(prefs),
        ),
      ],
      child: const AppView(),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> with WidgetsBindingObserver {
  final _appRouter = AppRouter();
  late SettingsCubit _settingsCubit;
  late Brightness _brightness;
  late StreamSubscription _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _settingsCubit = context.read<SettingsCubit>();
    WidgetsBinding.instance.addObserver(this);
    _brightness = WidgetsBinding.instance.window.platformBrightness;
    _connectivitySubscription = initiateNetworkChangeSubscription();
    _setSettingsBrightness();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {
      _brightness = WidgetsBinding.instance.window.platformBrightness;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _setSettingsBrightness();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _setSettingsBrightness() {
    final state = _settingsCubit.state;
    if (state.autoDarkMode) {
      if (state.darkMode && _brightness == Brightness.light) {
        _settingsCubit.setDarkMode(false);
      } else if (!state.darkMode && _brightness == Brightness.dark) {
        _settingsCubit.setDarkMode(true);
      }
    }
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
          title: config.appName,
          darkTheme: ThemeData.dark(),
          themeMode: themeMode,
          routerDelegate: _appRouter.delegate(),
          routeInformationParser: _appRouter.defaultRouteParser(),
          // debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}