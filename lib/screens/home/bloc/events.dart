import 'package:equatable/equatable.dart';

abstract class TranslationsEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class TranslationsRequest extends TranslationsEvent {}

class TranslationsRequestMore extends TranslationsEvent {}

class TranslationsSearch extends TranslationsEvent {
  final String text;

  TranslationsSearch(this.text) : assert(text != null);
}

class TranslationsItemRemove extends TranslationsEvent {
  final int id;

  TranslationsItemRemove(this.id) : assert(id != null);
}
