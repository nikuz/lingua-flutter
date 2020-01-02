import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
  String get token => null;
}

class LoginUninitialized extends LoginState {}

class LoginChecked extends LoginState {
  final String token;

  const LoginChecked(this.token);
}

