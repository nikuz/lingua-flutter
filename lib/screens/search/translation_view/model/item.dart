import 'package:equatable/equatable.dart';

class Translation extends Equatable {
  final int id;
  final String word;
  final String translation;
  final String pronunciation;
  final String image;
  final List<dynamic> raw;
  final String createdAt;

  const Translation({
    this.id,
    this.word,
    this.translation,
    this.pronunciation,
    this.image,
    this.raw,
    this.createdAt,
  });

  @override
  List<Object> get props => [
    id,
    word,
    translation,
    pronunciation,
    image,
    raw,
    createdAt,
  ];

  @override
  String toString() => '{ id: $id, word: $word, translation: $translation }';
}
