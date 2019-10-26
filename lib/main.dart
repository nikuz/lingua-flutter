import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/blocs/settings_bloc.dart';

import './blocs/blocs.dart';

void main() async {
  BlocSupervisor.delegate = MyBlocDelegate();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lingua',
      home: Scaffold(
        body: BlocProvider(
          builder: (context) => SettingsBloc()..add(SettingsGetApiUrl()),
          child: HomePage(),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is SettingsSetApiUrl) {
          return Center(
            child: Text(state.apiURL),
          );
        }

        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

