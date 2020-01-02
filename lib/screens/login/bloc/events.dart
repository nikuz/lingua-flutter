import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginCheck extends LoginEvent {}

class LoginRequest extends LoginEvent {}
