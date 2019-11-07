import 'package:equatable/equatable.dart';

abstract class TranslationsEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class TranslationsRequest extends TranslationsEvent {}

class TranslationsRefreshRequest extends TranslationsEvent {}

class TranslationsItemRemove extends TranslationsEvent {
  final int id;

  TranslationsItemRemove(this.id) : assert(id != null);
}
