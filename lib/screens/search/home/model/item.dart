import 'package:equatable/equatable.dart';

class TranslationsItem extends Equatable {
  final int? id;
  final String? word;
  final String? translation;
  final String? pronunciation;
  final String? image;
  final String? createdAt;
  final String? updatedAt;

  const TranslationsItem({
    this.id,
    this.word,
    this.translation,
    this.pronunciation,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    word,
    translation,
    pronunciation,
    image,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() => '{ id: $id, word: $word, translation: $translation }';
}
