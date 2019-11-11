import 'package:equatable/equatable.dart';

abstract class TranslationEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class TranslationRequest extends TranslationEvent {
  final String word;

  TranslationRequest([this.word]) : assert(word != null);
}
