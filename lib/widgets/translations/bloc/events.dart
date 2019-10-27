import 'package:equatable/equatable.dart';

abstract class TranslationsEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class TranslationsRequest extends TranslationsEvent {}
