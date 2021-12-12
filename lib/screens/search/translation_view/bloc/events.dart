import 'package:equatable/equatable.dart';

abstract class TranslationEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class TranslationRequest extends TranslationEvent {
  final String word;

  TranslationRequest(this.word);
}

class TranslationClear extends TranslationEvent {}

class TranslationRequestImage extends TranslationEvent {
  final String word;

  TranslationRequestImage(this.word);
}

class TranslationSelectImage extends TranslationEvent {
  final String source;

  TranslationSelectImage(this.source);
}

class TranslationSetOwn extends TranslationEvent {
  final String translation;

  TranslationSetOwn(this.translation);
}

class TranslationUpdate extends TranslationEvent {
  final String word;
  final String? image;

  TranslationUpdate({
    required this.word,
    this.image,
  });
}

class TranslationSave extends TranslationEvent {
  final String word;
  final String translation;
  final String pronunciationURL;
  final String image;
  final List<dynamic> raw;
  final int version;

  TranslationSave({
    required this.word,
    required this.translation,
    required this.pronunciationURL,
    required this.image,
    required this.raw,
    required this.version,
  });
}
