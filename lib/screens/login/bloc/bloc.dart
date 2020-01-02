import 'dart:async';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'events.dart';
import 'state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final http.Client httpClient;

  LoginBloc({@required this.httpClient}) : assert(httpClient is http.Client);

  @override
  LoginState get initialState => LoginUninitialized();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
//    final currentState = state;
    if (event is LoginCheck) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      yield LoginChecked(prefs.getString('auth_token'));
    }
  }
}
