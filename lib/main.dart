import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

import './blocs/delegate.dart';
import './widgets/translations/bloc/bloc.dart';

import './screens/home/home.dart';

void main() async {
  BlocSupervisor.delegate = MyBlocDelegate();
  runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<TranslationsBloc>(
            builder: (context) => TranslationsBloc(httpClient: http.Client()),
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
      home: Scaffold(
        body: SafeArea(
          child: HomePage(),
        ),
      ),
    );
  }
}



