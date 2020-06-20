import 'package:meta/meta.dart';
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

class TranslationSetOwn extends TranslationEvent {
  final String translation;

  TranslationSetOwn([this.translation]) : assert(translation != null);
}

class TranslationUpdate extends TranslationEvent {
  final String word;
  final String image;

  TranslationUpdate({
    @required this.word,
    this.image,
}) : assert(word != null);
}

class TranslationSave extends TranslationEvent {
  final String word;
  final String translation;
  final String pronunciationURL;
  final String image;
  final List<dynamic> raw;

  TranslationSave({
    @required this.word,
    @required this.translation,
    @required this.pronunciationURL,
    @required this.image,
    @required this.raw,
  }) : assert(word != null && translation != null && pronunciationURL != null && image != null && raw != null);
}
