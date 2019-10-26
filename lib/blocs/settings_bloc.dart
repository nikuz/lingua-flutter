import 'dart:async';
import 'package:http/http.dart' as http;

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../app_config.dart';

// events

abstract class SettingsEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SettingsGetApiUrl extends SettingsEvent {}

// state

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

class SettingsUninitialized extends SettingsState {}

class SettingsSetApiUrl extends SettingsState {
  final String apiURL;

  const SettingsSetApiUrl({@required this.apiURL}) : assert(apiURL != null);

  @override
  List<Object> get props => [apiURL];

  @override
  String toString() => '$apiURL';
}

// bloc

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  @override
  SettingsState get initialState => SettingsUninitialized();

  @override
  Stream<SettingsState> mapEventToState(SettingsEvent event) async* {
    if (event is SettingsGetApiUrl) {
      final apiUrl = await _fetchApiUrl();
      yield SettingsSetApiUrl(apiURL: apiUrl);
    }
  }

  Future<String> _fetchApiUrl() async {
    final response = await http.get(AppConfig.apiGetterUrl);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('error fetching posts');
    }
  }
}
