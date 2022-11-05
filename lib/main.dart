import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './blocs/observer.dart';
import './screens/search/home/bloc/bloc.dart';
import './screens/search/translation_view/bloc/bloc.dart';
import './screens/settings/home/bloc/bloc.dart';
import './screens/settings/home/bloc/state.dart';

import './screens/main.dart';

void main() async {
  Bloc.observer = MyBlocObserver();
  WidgetsFlutterBinding.ensureInitialized();
  final http.Client httpClient = http.Client();
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<TranslationsBloc>(
          create: (context) => TranslationsBloc(httpClient: httpClient),
        ),
        BlocProvider<TranslationBloc>(
          create: (context) => TranslationBloc(httpClient: httpClient),
        ),
        BlocProvider<SettingsBloc>(
          create: (context) => SettingsBloc(prefs: prefs),
        ),
      ],
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return MaterialApp(
          title: 'Lingua',
          theme: ThemeData(fontFamily: 'Montserrat'),
          darkTheme: ThemeData.dark(),
          themeMode: (
            state is SettingsLoaded && (state.settings['darkModeEnabled'] || state.settings['autoDarkMode'])
                ? ThemeMode.dark
                : ThemeMode.light
          ),
          home: MainScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

