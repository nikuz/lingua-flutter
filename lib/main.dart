import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

import './blocs/delegate.dart';
import './widgets/translations_list/bloc/bloc.dart';
import './screens/translation_view/bloc/bloc.dart';

import './router.dart';

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

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lingua',
      initialRoute: HOME,
      onGenerateRoute: generateRoute,
      theme: ThemeData(fontFamily: 'Montserrat'),
    );
  }
}



