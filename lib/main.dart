import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './blocs/observer.dart';
import './screens/search/bloc/search_cubit.dart';
import './screens/translation_view/bloc/translation_view_cubit.dart';
import './screens/settings/bloc/settings_cubit.dart';
import './screens/settings/bloc/settings_state.dart';

import './screens/router.gr.dart';

void main() async {
  Bloc.observer = MyBlocObserver();
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(
    MultiBlocProvider(
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
      child: App(),
    ),
  );
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  final _appRouter = AppRouter();
  late Brightness _brightness;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _brightness = WidgetsBinding.instance.window.platformBrightness;
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

