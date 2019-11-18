import 'package:equatable/equatable.dart';

abstract class TranslationEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class TranslationRequest extends TranslationEvent {
  final String word;

  TranslationRequest([this.word]) : assert(word != null);
}

class TranslationClear extends TranslationEvent {}

class TranslationRequestImage extends TranslationEvent {
  final String word;

  TranslationRequestImage([this.word]) : assert(word != null);
}

class TranslationSelectImage extends TranslationEvent {
  final String source;

  TranslationSelectImage([this.source]) : assert(source != null);
}

class TranslationUpdate extends TranslationEvent {
  final String word;

  TranslationUpdate([this.word]) : assert(word != null);
}
